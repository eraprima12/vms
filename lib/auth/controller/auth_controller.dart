// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:vms/auth/controller/fcm_token_listener.dart';
import 'package:vms/auth/model/user_model.dart';
import 'package:vms/auth/view/auth_page.dart';
import 'package:vms/constant.dart';
import 'package:vms/global/widget/popup_handler.dart';
import 'package:vms/menu/view/menu.dart';

class AuthController extends ChangeNotifier {
  UserModel? user =
      UserModel(uid: '', username: '', password: '', fcmToken: '');
  var popupHandler = PopupHandler();
  var context = navigatorKey.currentContext!;
  final formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  TextEditingController get usernameController => _usernameController;
  TextEditingController get passwordController => _passwordController;

  bool _loadingLogin = false;
  bool get loadingLogin => _loadingLogin;

  set loadingLogin(bool value) {
    _loadingLogin = value;
    notifyListeners();
  }

  logout() {
    localStorage.erase();
    pageMover.pushAndRemove(widget: const LoginPage());
  }

  getAndSetUserDetail({required String uid}) async {
    user = await getUserDetails(uid: uid);
  }

  initListener() async {
    String uid = localStorage.read(uidKey);
    getAndSetUserDetail(uid: uid);
    FCMTokenChangeListener tokenListener = FCMTokenChangeListener(
      uid: uid,
      currentToken: user!.fcmToken,
    );
    tokenListener.startListening();
  }

  Future<UserModel?> getUserDetails({required String uid}) async {
    try {
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection('admin').doc(uid).get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        String username = data['username'];
        String password = data['password'];
        String fcmToken = data['fcmToken'];
        UserModel userModel = UserModel(
          uid: uid,
          username: username,
          password: password,
          fcmToken: fcmToken,
        );

        return userModel;
      } else {
        throw 'Error while getting user';
      }
    } catch (e) {
      popupHandler.showErrorPopup(e.toString());
    }
    return null;
  }

  Future<void> checkCredentials() async {
    try {
      loadingLogin = true;
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('admin')
          .where('username', isEqualTo: usernameController.text)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        String storedPassword = userDoc.get('password');
        String uid = userDoc.id;
        loadingLogin = false;

        if (passwordController.text == storedPassword) {
          String currentToken = await updateToken(uid: uid);
          localStorage.write(tokenKey, currentToken);
          localStorage.write(uidKey, uid);
          pageMover.pushAndRemove(widget: const TabBarBottomNavPage());
        } else {
          loadingLogin = false;
          throw 'Wrong username/password';
        }
      } else {
        loadingLogin = false;
        throw 'Wrong username/password';
      }
    } catch (e) {
      loadingLogin = false;
      popupHandler.showErrorPopup(e.toString());
      // Handle errors or return false as needed
    }
  }

  Future<String> updateToken({required String uid}) async {
    try {
      String fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
      await FirebaseFirestore.instance
          .collection('admin')
          .doc(uid)
          .update({'fcmToken': fcmToken}).onError(
              (error, stackTrace) => throw 'Credential Failure');
      return fcmToken;
    } catch (e) {
      throw 'Credential Failure';
    }
  }
}

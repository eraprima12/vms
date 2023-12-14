// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:vms/admin/menu/view/menu.dart';
import 'package:vms/auth/controller/drivers_controller.dart';
import 'package:vms/auth/controller/fcm_token_listener.dart';
import 'package:vms/auth/model/driver_model.dart';
import 'package:vms/auth/model/master_model.dart';
import 'package:vms/auth/model/user_model.dart';
import 'package:vms/auth/view/auth_page.dart';
import 'package:vms/constant.dart';
import 'package:vms/driver/home/view/home.dart';
import 'package:vms/global/function/local_storage_handler.dart';
import 'package:vms/global/model/hexcolor.dart';
import 'package:vms/global/widget/popup_handler.dart';

class AuthController extends ChangeNotifier {
  User? user;
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

  bool _loadingMaster = false;
  bool get loadingMaster => _loadingMaster;
  set loadingMaster(bool value) {
    _loadingMaster = value;
    notifyListeners();
  }

  Future<Company?> getMasterSettings({required String uid}) async {
    try {
      loadingMaster = true;
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection('company').doc(uid).get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        Company master = Company.fromJson(data);
        primaryColor = master.primaryColor != ''
            ? HexColor.fromHex(master.primaryColor!)
            : primaryColor;

        secondaryColor = master.secondaryColor != ''
            ? HexColor.fromHex(master.secondaryColor!)
            : secondaryColor;

        thirdColor = master.thirdColor != ''
            ? HexColor.fromHex(master.thirdColor!)
            : thirdColor;

        splashLink = master.splashScreen!;
        loadingMaster = false;
        return master;
      } else {
        loadingMaster = false;
        throw 'Error while getting master';
      }
    } catch (e) {
      popupHandler.showErrorPopup(e.toString());
      return null;
    }
  }

  Future<void> saveMasterDataToFirestore(Company formData, File? file) async {
    loadingMaster = true;
    try {
      if (file != null) {
        var url = await uploadFileToFirebaseStorage(file);
        formData.splashScreen = url;
      }
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      String? companyUid = localStorage.read(companyUidKey) ?? '';
      DocumentReference masterDataCollection =
          firestore.collection('company').doc(companyUid);

      Map<String, dynamic> formDataMap = formData.toJson();

      await masterDataCollection.update(formDataMap);
      primaryColor = HexColor.fromHex(formData.primaryColor!);

      secondaryColor = HexColor.fromHex(formData.secondaryColor!);

      thirdColor = HexColor.fromHex(formData.thirdColor!);
      pageMover.pop();
      popupHandler.showSuccessPopup('Saving Master');
      loadingMaster = false;
      notifyListeners();
    } catch (error) {
      loadingMaster = false;
      popupHandler.showErrorPopup('Error Saving Master Data!');
    }
  }

  Future<String> uploadFileToFirebaseStorage(File file) async {
    try {
      Reference storageReference = FirebaseStorage.instance.ref().child(
          'splash/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}');
      UploadTask uploadTask = storageReference.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (error) {
      throw 'Error when uploading Master data';
    }
  }

  void main() async {
    File file = File(
        'path/to/your/file.jpg'); // Replace with the actual path to your file
    String downloadURL = await uploadFileToFirebaseStorage(file);

    if (downloadURL.isNotEmpty) {
      print('File uploaded successfully. Download URL: $downloadURL');
    } else {
      print('Failed to upload file.');
    }
  }

  logout() async {
    await localStorage.erase();
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
      currentToken: user!.token,
    );
    tokenListener.startListening();
  }

  Future<User?> getUserDetails({required String uid}) async {
    try {
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection('user').doc(uid).get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        User user = User.fromJson(data);

        return user;
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
          .collection('user')
          .where('username', isEqualTo: usernameController.text)
          .limit(1)
          .get();

      DocumentSnapshot userDoc = querySnapshot.docs.first;
      String storedPassword = userDoc.get('password');
      String uid = userDoc.id;
      loadingLogin = false;

      await getUserDetails(uid: uid);

      if (passwordController.text == storedPassword) {
        String currentToken = await updateToken(uid: uid);
        localStorage.write(tokenKey, currentToken);
        localStorage.write(uidKey, uid);
        localStorage.write(companyUidKey, user!.companyUid);
        pageMover.pushAndRemove(
            widget: user!.type == driverKey
                ? const HomeDriver()
                : const TabBarBottomNavPage());
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
          .collection('user')
          .doc(uid)
          .update({'token': fcmToken}).onError(
              (error, stackTrace) => throw 'Credential Failure');
      return fcmToken;
    } catch (e) {
      throw 'Credential Failure';
    }
  }
}

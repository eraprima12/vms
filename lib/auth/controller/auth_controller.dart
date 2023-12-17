// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:provider/provider.dart';
import 'package:vms/admin/menu/view/menu.dart';
import 'package:vms/auth/controller/drivers_controller.dart';
import 'package:vms/auth/controller/fcm_token_listener.dart';
import 'package:vms/auth/model/master_model.dart';
import 'package:vms/auth/model/user_model.dart';
import 'package:vms/auth/view/auth_page.dart';
import 'package:vms/constant.dart';
import 'package:vms/driver/bg_locator/bg_locator_provider.dart';
import 'package:vms/driver/home/view/home.dart';
import 'package:vms/driver/permission/view/permission_page.dart';
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
    Provider.of<BGLocatorProvider>(context, listen: false).onStop();
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
        if (user.type == driverKey) {
          var driverController =
              Provider.of<DriversController>(context, listen: false);

          var positionData = await driverController.getPosition(uid: user.uid);
          var vehicleData =
              await driverController.getVehicle(uid: user.vehicleUid);
          user.position = positionData[0];
          user.position.sort(
            (a, b) => b.dateTime.compareTo(a.dateTime),
          );
          user.position.sort((a, b) => b.dateTime.compareTo(a.dateTime));

          user.totalDistance =
              driverController.calculateTotalDistance(positionData[1]);
          user.distanceToday =
              driverController.calculateTotalDistance(positionData[2]);
          user.vehicle = vehicleData;
          if (user.vehicle != null) {
            user.nextServiceOdo = user.vehicle!.serviceOdoEvery -
                (user.vehicle!.odo - user.vehicle!.lastService!.serviceAtOdo);
          }
          user.tripHistory =
              driverController.separatePositionsByDateTime(positionData[0]);
        }

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

      user = await getUserDetails(uid: uid);

      if (passwordController.text == storedPassword) {
        String currentToken = await updateToken(uid: uid);
        localStorage.write(tokenKey, currentToken);
        localStorage.write(uidKey, uid);
        localStorage.write(companyUidKey, user!.companyUid);
        logger.f(user!.type + driverKey);
        putIsDriver(value: (user!.type == driverKey));
        logger.f(getIsDriver());
        if (getIsDriver()) {
          var permissonLocation =
              (await permission_handler.Permission.location.isGranted);
          var permissionNotification =
              (await permission_handler.Permission.notification.isGranted);
          var allowedPermission = '';
          if ((!permissonLocation || !permissionNotification)) {
            pageMover.pushAndRemove(
                widget: LocationPermissionPage(
              allowedPermission: allowedPermission,
            ));
          } else {
            pageMover.pushAndRemove(widget: const HomeDriver());
          }
        } else {
          pageMover.pushAndRemove(widget: const TabBarBottomNavPage());
        }
      } else {
        loadingLogin = false;
        throw 'Wrong username/password';
      }
    } catch (e) {
      loadingLogin = false;
      popupHandler.showErrorPopup('Wrong username/password');
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

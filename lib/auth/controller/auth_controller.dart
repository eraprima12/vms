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
import 'package:vms/auth/model/driver_model.dart';
import 'package:vms/auth/model/master_model.dart';
import 'package:vms/auth/model/user_model.dart';
import 'package:vms/auth/view/auth_page.dart';
import 'package:vms/constant.dart';
import 'package:vms/driver/bg_locator/bg_locator_provider.dart';
import 'package:vms/driver/home/view/home.dart';
import 'package:vms/driver/permission/view/permission_page.dart';
import 'package:vms/global/function/local_storage_handler.dart';
import 'package:vms/global/function/random_string_generator.dart';
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

  Future<void> addDriver(bool isEdit, User? data, String name, String password,
      String username, String vehicleUID, File? file) async {
    var driverController =
        Provider.of<DriversController>(context, listen: false);
    String avatarUrl = '';
    var double = driverController.driverData
        .where((element) => element.username == username)
        .toList();
    if (file != null) {
      avatarUrl = await uploadFileToFirebaseStorage(file, 'splash');
    }

    var companyUid = localStorage.read(companyUidKey);
    var uids = generateRandomString(length: 10);
    if (isEdit) {
      logger.f(name);
      await FirebaseFirestore.instance
          .collection('user')
          .doc(data!.uid)
          .update({
        'avatar': avatarUrl == '' ? data.avatar : avatarUrl,
        'company_uid': companyUid,
        'created_at': Timestamp.fromDate(data.createdAt),
        'is_online': data.isOnline,
        'name': name,
        'password': password,
        'token': data.token,
        'trigger_id': generateRandomString(length: 10),
        'type': 'driver',
        'uid': data.uid,
        'username': username,
        'vehicle_uid': vehicleUID,
      }).then((value) {
        Provider.of<DriversController>(context, listen: false)
            .getAndMapDriverData();
        pageMover.pop();
        popupHandler.showSuccessPopup('Success Edit Driver');
      });
    } else {
      if (double.isEmpty) {
        await FirebaseFirestore.instance.collection('user').doc(uids).set({
          'avatar': avatarUrl,
          'company_uid': companyUid,
          'created_at': Timestamp.fromDate(DateTime.now()),
          'is_online': false,
          'name': name,
          'password': password,
          'token': '',
          'trigger_id': '',
          'type': 'driver',
          'uid': uids,
          'username': username,
          'vehicle_uid': vehicleUID,
        }).then((value) {
          popupHandler.showSuccessPopup('Success Add Driver');
        });
        Provider.of<DriversController>(context, listen: false)
            .getAndMapDriverData();
      } else {
        popupHandler.showErrorPopup('Username already taken');
      }
    }
  }

  Future<void> saveMasterDataToFirestore(Company formData, File? file) async {
    loadingMaster = true;
    try {
      if (file != null) {
        var url = await uploadFileToFirebaseStorage(file, 'splash');
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

  Future<void> addVehicle(Vehicle? data, String licensePlate,
      int overSpeedLimit, int serviceOdoEvery, int odo, File? file) async {
    try {
      String url = '';
      if (file != null) {
        url = await uploadFileToFirebaseStorage(file, 'splash');
      }
      var uid = generateRandomString(length: 10);
      var companyUid = localStorage.read(companyUidKey);

      if (data == null) {
        Map<String, dynamic> vehicleData = {
          'avatar': url,
          'company_uid': companyUid,
          'created_at': Timestamp.now(),
          'license_plate': licensePlate,
          'odo': odo,
          'overspeed_limit': overSpeedLimit,
          'service_odo_every': serviceOdoEvery,
          'uid': uid,
        };
        await FirebaseFirestore.instance
            .collection('vehicle')
            .doc(uid)
            .set(vehicleData)
            .then((value) async {
          var uidService = generateRandomString(length: 10);
          await FirebaseFirestore.instance
              .collection('vehicle')
              .doc(uid)
              .collection('service')
              .doc(uidService)
              .set({
            'uid': uidService,
            'service_at_odo': odo,
            'vehicle_uid': uid,
            'created_at': Timestamp.now()
          });
        });
      } else {
        Map<String, dynamic> vehicleData = {
          'avatar': url != '' ? url : data.avatar,
          'company_uid': companyUid,
          'created_at': data.createdAt,
          'license_plate': licensePlate,
          'odo': odo,
          'overspeed_limit': overSpeedLimit,
          'service_odo_every': serviceOdoEvery,
          'uid': data.uid,
        };
        pageMover.pop();
        await FirebaseFirestore.instance
            .collection('vehicle')
            .doc(data.uid)
            .update(vehicleData);
      }
      Provider.of<DriversController>(context, listen: false).getListVehicle();
      popupHandler.showSuccessPopup('Vehicle data stored successfully!');
    } catch (e) {
      popupHandler.showErrorPopup('Error storing vehicle data: $e');
    }
  }

  Future<String> uploadFileToFirebaseStorage(File file, String path) async {
    try {
      Reference storageReference = FirebaseStorage.instance.ref().child(
          '$path/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}');
      UploadTask uploadTask = storageReference.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (error) {
      throw 'Error when uploading Master data';
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
          user.totalDistancePast7Days =
              driverController.distanceCoveragePast(positionData[0], 7);
          user.totalDistanceYesterday =
              driverController.distanceCoveragePast(positionData[0], 1);
          user.totalDistance =
              driverController.totalDistanceCoverage(positionData[0]);
          user.distanceToday =
              driverController.distanceCoveragePast(positionData[0], 0);
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

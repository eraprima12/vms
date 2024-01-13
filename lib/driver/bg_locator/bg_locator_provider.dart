import 'dart:convert';
import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';

import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vms/auth/model/user_model.dart';
import 'package:vms/constant.dart';
import 'package:vms/driver/bg_locator/location_callback_handler.dart';
import 'package:vms/global/function/random_string_generator.dart';

import 'location_service_repository.dart';

class BGLocatorProvider extends ChangeNotifier {
  ReceivePort port = ReceivePort();
  List<Widget> logStr = [];
  bool? isRunning;
  LocationDto? lastLocation;
  int totalData = 0;
  List<LatLng> listLatlong = [];
  bool? _isMocked;
  String lastSend = '';
  set isMocked(bool? value) {
    _isMocked = value;
    notifyListeners();
  }

  bool? get isMocked => _isMocked;

  initiate(context) async {
    try {
      if (IsolateNameServer.lookupPortByName(
              LocationServiceRepository.isolateName) !=
          null) {
        IsolateNameServer.removePortNameMapping(
            LocationServiceRepository.isolateName);
      }
      IsolateNameServer.registerPortWithName(
          port.sendPort, LocationServiceRepository.isolateName);
      port.listen(
        (dynamic data) async {
          if (data != null) {
            var temp = await localStorage.read(uidKey);
            if (temp != null) {
              await sendToGetStorage(LocationDto.fromJson(data));
              if (totalData == 1) {
                postGPSBuffer();
                totalData = 0;
              }
            }
          }
        },
      );
      await initPlatformState();
    } catch (e) {
      log('Started 2 times', name: 'Started 2 times');
    }
  }

  sendToGetStorage(LocationDto? locationDto) {
    var mocked = locationDto!.isMocked;
    if (!mocked) {
      _updateNotificationText(false, mocked);
      totalData++;
      final box = GetStorage();
      List bgLocationDto = jsonDecode(box.read(bgLocationKey) ?? '[]');
      bgLocationDto.add(locationDto.toJson());
      box.write(bgLocationKey, jsonEncode(bgLocationDto));
    }
  }

  clearGetStorage() async {
    final box = GetStorage();
    await box.remove(bgLocationKey);
  }

  List<LocationDto> getFromGetStorage() {
    final box = GetStorage();
    List<LocationDto> bgLocationDto = List<LocationDto>.from(jsonDecode(
      box.read(bgLocationKey) ?? '[]',
    ).map((x) => LocationDto.fromJson(x))).toList();
    return bgLocationDto;
  }

  List<PositionModel> buildParam(String uid) {
    var data = getFromGetStorage();
    List<PositionModel> listPosition = [];
    for (int i = 0; i < data.length; i++) {
      PositionModel temp = PositionModel(
        dateTime: DateTime.now(),
        geopoint: GeoPoint(data[i].latitude, data[i].longitude),
        speed: data[i].speed,
      );
      listPosition.add(temp);
    }
    return listPosition;
  }

  postGPSBuffer() async {
    try {
      var uid = localStorage.read(uidKey);
      var param = buildParam(uid);
      for (int i = 0; i < param.length; i++) {
        var positionUID = generateRandomString(length: 10);
        await FirebaseFirestore.instance
            .collection('user')
            .doc(uid)
            .collection('position')
            .doc(positionUID)
            .set({
          'created_at': Timestamp.fromDate(param[i].dateTime),
          'geopoint': param[i].geopoint,
          'uid': positionUID,
          'speed': param[i].speed
        });
      }
      var triggerID = generateRandomString(length: 10);
      await FirebaseFirestore.instance
          .collection('user')
          .doc(uid)
          .update({'trigger_id': triggerID});
      clearGetStorage();
    } catch (e) {
      logger.f(e);
      return Future.error('Terjadi Kesalahan');
    }
  }

  updateIsOnline(bool isOnline) async {
    var uid = localStorage.read(uidKey);
    await FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .update({'is_online': isOnline});
  }

  ///Gak guna
  // Future postGPSSingle(LocationDto data, LoginModel dataLogin) async {
  //   try {
  //     sendToGetStorage(data);
  //     var response = await DioHandler().postData(
  //       url: '$baseUrl$locationTrackUrl',
  //       header: {
  //         'Authorization': 'Bearer ${dataLogin.data!.detailDataLogin!.token}'
  //       },
  //       data: {
  //         'data_time_hp': DateFormat('yyyy-MM-dd HH:mm:ss')
  //             .format(DateTime.fromMillisecondsSinceEpoch(data.time.round())),
  //         'lat': data.latitude,
  //         'lon': data.longitude,
  //         'contact_id': dataLogin.data!.contactId,
  //         'speed': data.speed
  //       },
  //     );
  //   } catch (e) {
  //     sendToGetStorage(data);
  //     return Future.error('Terjadi kesalahan');
  //   }
  // }

  Future<void> _updateNotificationText(bool error, bool isMocked) async {
    if (isMocked) {
      await BackgroundLocator.updateNotificationText(
          title: 'Mock Location terdeteksi',
          msg: 'Anda menggunakan mock location',
          bigMsg: 'Lokasi anda terdeteksi kecurangan');
    } else {
      await BackgroundLocator.updateNotificationText(
          title: error ? 'Lokasi Error' : 'Lokasi dikirim ke server',
          msg: '${DateTime.now()}',
          bigMsg:
              error ? 'Terjadi Error' : 'Lokasi anda telah dikirim ke server');
    }
  }

  Future<void> onStop() async {
    await BackgroundLocator.unRegisterLocationUpdate();
    final isRunnings = await BackgroundLocator.isServiceRunning();
    isRunning = isRunnings;
    notifyListeners();
  }

  Future<void> _startLocator() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    Map<String, dynamic> data = {'countInit': 1};
    return await BackgroundLocator.registerLocationUpdate(
      LocationCallbackHandler.callback,
      initCallback: LocationCallbackHandler.initCallback,
      initDataCallback: data,
      disposeCallback: LocationCallbackHandler.disposeCallback,
      iosSettings: const IOSSettings(
        accuracy: LocationAccuracy.NAVIGATION,
        distanceFilter: 1,
        stopWithTerminate: true,
      ),
      autoStop: false,
      androidSettings: const AndroidSettings(
        accuracy: LocationAccuracy.NAVIGATION,
        interval: 10,
        distanceFilter: 1,
        wakeLockTime: 1440,
        client: LocationClient.google,
        androidNotificationSettings: AndroidNotificationSettings(
          notificationChannelName: 'VMS',
          notificationTitle: 'VMS Track lokasi dimulai',
          notificationMsg: 'Mengambil lat lon di background',
          notificationBigMsg: 'Mengambil lat lon di background',
          notificationIcon: '@mipmap/ic_launcher',
          notificationTapCallback: LocationCallbackHandler.notificationCallback,
        ),
      ),
    );
  }

  Future<bool> _checkLocationPermission() async {
    final access = await Permission.location.status;
    switch (access) {
      case PermissionStatus.denied:
        final permission = await Permission.location.request();
        if (permission == PermissionStatus.granted) {
          return true;
        } else {
          return false;
        }
      case PermissionStatus.restricted:
        final permission = await Permission.location.request();
        if (permission == PermissionStatus.granted) {
          return true;
        } else {
          return false;
        }
      case PermissionStatus.granted:
        return true;
      default:
        return false;
    }
  }

  onStart() async {
    try {
      if (await _checkLocationPermission()) {
        _startLocator();
        final isRunnings = await BackgroundLocator.isServiceRunning();
        isRunning = isRunnings;
        lastLocation = null;
        notifyListeners();
      } else {
        logger.f('error');
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> initPlatformState() async {
    await BackgroundLocator.initialize();
    final isRunnings = await BackgroundLocator.isServiceRunning();
    isRunning = isRunnings;

    notifyListeners();
  }
}

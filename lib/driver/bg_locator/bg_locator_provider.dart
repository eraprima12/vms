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
  final bool _checkOnly = false;
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
              if (totalData == 10) {
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
    totalData++;
    if (!_checkOnly) {
      if (locationDto != null) {
        final box = GetStorage();
        List bgLocationDto = jsonDecode(box.read(bgLocationKey) ?? '[]');
        bgLocationDto.add(locationDto.toJson());
        box.write(bgLocationKey, jsonEncode(bgLocationDto));
      }
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
          'created_at':
              (param[i].dateTime.millisecondsSinceEpoch / 1000).round(),
          'geopoint': param[i].geopoint,
          'uid': positionUID,
          'speed': param[i].speed
        });
      }
      _updateNotificationText(false);
      clearGetStorage();
    } catch (e) {
      return Future.error('Terjadi Kesalahan');
    }
  }

  ///Di Comment karena fungsi berguna untuk next nya
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

  Future<void> _updateNotificationText(bool error) async {
    // if (data.isMocked) {
    //   isMocked = true;
    //   await BackgroundLocator.updateNotificationText(
    //       title: 'Mock Location terdeteksi',
    //       msg: 'Anda menggunakan mock location',
    //       bigMsg: 'Lokasi anda terdeteksi kecurangan');
    // } else {
    //   isMocked = false;
    await BackgroundLocator.updateNotificationText(
        title: error ? 'Lokasi Error' : 'Lokasi dikirim ke server',
        msg: '${DateTime.now()}',
        bigMsg:
            error ? 'Terjadi Error' : 'Lokasi anda telah dikirim ke server');
    // }
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
        distanceFilter: 0,
        stopWithTerminate: true,
      ),
      autoStop: false,
      androidSettings: const AndroidSettings(
        accuracy: LocationAccuracy.NAVIGATION,
        interval: 30,
        distanceFilter: 10,
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
        var uid = await localStorage.read(uidKey);
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

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:vms/constant.dart';
import 'package:vms/driver/home/view/home.dart';
import 'package:vms/driver/permission/view/permission_page.dart';

class GPSLocationPermissionHandlerProvider extends ChangeNotifier {
  bool loadData = false;

  openAppSetting() async {
    await permission_handler.openAppSettings();
  }

  requestGPSService(context) async {
    try {
      if (await Geolocator.isLocationServiceEnabled()) {
        if (await permission_handler.Permission.location.isGranted) {
          pageMover.pushAndRemove(widget: const HomeDriver());
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute(
              builder: (_) => LocationPermissionPage(
                allowedPermission: 'Lokasi',
              ),
            ),
            (route) => false,
          );
        }
      } else {
        await Geolocator.openLocationSettings();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> isAcceptAll(context) async {
    LocationPermission permissionGranted = await Geolocator.checkPermission();
    var permissonLocation =
        (await permission_handler.Permission.location.isGranted);
    var permissionNotification =
        (await permission_handler.Permission.notification.isGranted);
    if (await Geolocator.isLocationServiceEnabled() &&
            permissionGranted == LocationPermission.whileInUse ||
        permissionGranted == LocationPermission.always) {
    } else if (!permissonLocation || !permissionNotification) {
      var allowedPermission = '';
      if (!permissonLocation) {
        allowedPermission += 'Lokasi,';
      }
      if (!permissionNotification) {
        allowedPermission += 'Notifikasi,';
      }
      pageMover.pushAndRemove(
          widget: LocationPermissionPage(allowedPermission: allowedPermission));
    } else if (await Geolocator.isLocationServiceEnabled()) {
      pageMover.pushAndRemove(widget: const HomeDriver());
    }
  }
}

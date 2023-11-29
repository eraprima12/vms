import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math' show cos, sqrt, asin, sin, pow, min, max;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:vms/auth/model/driver_model.dart';
import 'package:vms/global/function/date_function.dart';

class DriversController extends ChangeNotifier {
  bool _loadingGetUser = false;
  bool get loadingGetUser => _loadingGetUser;
  set loadingGetUser(bool value) {
    _loadingGetUser = value;
    notifyListeners();
  }

  List<LatLng> _latlnglist = [];
  List<LatLng> get latlnglist => _latlnglist;
  set latlnglist(List<LatLng> value) {
    _latlnglist = value;
    notifyListeners();
  }

  List<DriverModel> _driverData = [];
  List<DriverModel> get driverData => _driverData;
  set driverData(List<DriverModel> value) {
    _driverData = value;
    notifyListeners();
  }

  List<DriverModel> _highestDriverData = [];
  List<DriverModel> get highestDriverData => _highestDriverData;
  set highestDriverData(List<DriverModel> value) {
    _highestDriverData = value;
    notifyListeners();
  }

  List<DriverModel> _lowestDriverData = [];
  List<DriverModel> get lowestDriverData => _lowestDriverData;
  set lowestDriverData(List<DriverModel> value) {
    _lowestDriverData = value;
    notifyListeners();
  }

  double calculateTotalDistance(List<LatLng> points) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    double degreesToRadians(double degrees) {
      return degrees * (pi / 180);
    }

    double haversine(double a) {
      return pow(sin(a / 2), 2).toDouble();
    }

    double calculateDistanceBetweenPoints(LatLng point1, LatLng point2) {
      double lat1 = degreesToRadians(point1.latitude);
      double lon1 = degreesToRadians(point1.longitude);
      double lat2 = degreesToRadians(point2.latitude);
      double lon2 = degreesToRadians(point2.longitude);

      double dLat = lat2 - lat1;
      double dLon = lon2 - lon1;

      double a = haversine(dLat) + cos(lat1) * cos(lat2) * haversine(dLon);
      double c = 2 * asin(sqrt(a));

      return earthRadius * c; // Distance in kilometers
    }

    double totalDistance = 0;

    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += calculateDistanceBetweenPoints(points[i], points[i + 1]);
    }

    return totalDistance;
  }

  Future<Map<int, dynamic>> getPosition({required String uid}) async {
    try {
      List<PositionModel> res = [];
      List<LatLng> latlngList = [];
      List<LatLng> latlngListToday = [];
      var positionCollection = await FirebaseFirestore.instance
          .collection('driver')
          .doc(uid)
          .collection('position')
          .get();
      positionCollection.docs.map(
        (e) {
          var data = e.data();
          PositionModel position = PositionModel.fromMap(data);
          latlngList.add(
            LatLng(position.geopoint.latitude, position.geopoint.longitude),
          );
          if (isWithinCurrentDay(position.dateTime)) {
            latlngListToday.add(
              LatLng(position.geopoint.latitude, position.geopoint.longitude),
            );
          }
          res.add(position);
        },
      ).toList();
      return {0: res, 1: latlngList, 2: latlngListToday};
    } catch (e) {
      return {0: [], 1: [], 2: []};
    }
  }

  getAndMapDriverData() async {
    loadingGetUser = true;
    var driverList = await getDriverData();

    highestDriverData = List.from(driverList);
    lowestDriverData = List.from(driverList);
    lowestDriverData.sort((a, b) => a.distanceToday.compareTo(b.distanceToday));
    highestDriverData
        .sort((a, b) => b.distanceToday.compareTo(a.distanceToday));
    driverData = List.from(driverList);
    loadingGetUser = false;
  }

  getDriverStatistic(String licensePlate) {
    List<FlSpot> dataPoints = [];
    DateTime currentDate = DateTime.now();
    List<String> dataTime = [];
    for (int i = 6; i >= 0; i--) {
      DateTime date = currentDate.subtract(Duration(days: i));
      String formattedDate = DateFormat('MM-dd').format(date);
      double
          yValue = // Your y-value calculation here, e.g., some random value for demonstration
          double.parse(DateFormat('d').format(date)) + 20;
      dataTime.add(DateFormat('d').format(date));
      dataPoints.add(FlSpot(i.toDouble(), yValue));
    }

    return (dataPoints, dataTime);
  }

  LatLngBounds getBoundsFromLatLngList(List<LatLng> latLngList) {
    if (latLngList.isEmpty) {
      // Return a default bounds if the list is empty
      return LatLngBounds(
        const LatLng(0, 0),
        const LatLng(0, 0),
      );
    }

    double minLat = latLngList[0].latitude;
    double maxLat = latLngList[0].latitude;
    double minLng = latLngList[0].longitude;
    double maxLng = latLngList[0].longitude;

    // Iterate through the list to find the minimum and maximum values
    for (LatLng latLng in latLngList) {
      minLat = min(minLat, latLng.latitude);
      maxLat = max(maxLat, latLng.latitude);
      minLng = min(minLng, latLng.longitude);
      maxLng = max(maxLng, latLng.longitude);
    }

    return LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
  }

  Future<List<DriverModel>> getDriverData() async {
    try {
      QuerySnapshot<Object?> driversCollection =
          await FirebaseFirestore.instance.collection('driver').get();
      List<DriverModel> driverList = [];
      latlnglist = [];
      await Future.wait(driversCollection.docs.map((doc) async {
        var data = doc.data() as Map<String, dynamic>;
        DriverModel driver = DriverModel.fromMap(data);
        var positionData = await getPosition(uid: driver.uid);
        latlnglist.add(LatLng(
            driver.latestPosition.latitude, driver.latestPosition.longitude));
        driver.position = positionData[0];
        driver.totalDistance = calculateTotalDistance(positionData[1]);
        driver.distanceToday = calculateTotalDistance(positionData[2]);
        driverList.add(driver);
      }).toList());
      return driverList;
    } catch (e) {
      return [];
    }
  }
}

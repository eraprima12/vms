import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math' show cos, sqrt, asin, sin, pow, min, max;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:vms/auth/model/driver_model.dart';
import 'package:vms/auth/model/user_model.dart';
import 'package:vms/constant.dart';
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

  List<User> _driverData = [];
  List<User> get driverData => _driverData;
  set driverData(List<User> value) {
    _driverData = value;
    notifyListeners();
  }

  List<User> _highestDriverData = [];
  List<User> get highestDriverData => _highestDriverData;
  set highestDriverData(List<User> value) {
    _highestDriverData = value;
    notifyListeners();
  }

  List<User> _lowestDriverData = [];
  List<User> get lowestDriverData => _lowestDriverData;
  set lowestDriverData(List<User> value) {
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

  Future<String> getAddressFromLatLng(
      {required double latitude, required double longitude}) async {
    String address = '';
    List<Placemark> placemarks = await placemarkFromCoordinates(
      latitude,
      longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      address =
          '${placemark.name}, ${placemark.locality}, ${placemark.country}';
    }
    return address;
  }

  Future<Map<int, dynamic>> getPosition({required String uid}) async {
    try {
      List<PositionModel> res = [];
      List<LatLng> latlngList = [];
      List<LatLng> latlngListToday = [];
      var positionCollection = await FirebaseFirestore.instance
          .collection('user')
          .doc(uid)
          .collection('position')
          .get();
      if (positionCollection.docs.isNotEmpty) {
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
      }
      return {0: res, 1: latlngList, 2: latlngListToday};
    } catch (e) {
      return {0: [], 1: [], 2: []};
    }
  }

  List<Timestamp> separatePositionsByDateTime(List<PositionModel> positions) {
    final Map<DateTime, Timestamp> separatedMap = {};

    for (final position in positions) {
      final dateTimeKey = DateTime(
        position.dateTime.year,
        position.dateTime.month,
        position.dateTime.day,
      );

      if (!separatedMap.containsKey(dateTimeKey)) {
        separatedMap[dateTimeKey] = Timestamp.fromDate(dateTimeKey);
      }
    }

    return separatedMap.values.toList();
  }

  getAndMapDriverData() async {
    try {
      loadingGetUser = true;
      var driverList = await getDriverData();
      highestDriverData = List.from(driverList);
      lowestDriverData = List.from(driverList);
      logger.f('asd ${highestDriverData.length}');
      if (driverList.length > 1) {
        lowestDriverData
            .sort((a, b) => a.distanceToday.compareTo(b.distanceToday));
        highestDriverData
            .sort((a, b) => b.distanceToday.compareTo(a.distanceToday));
      } else {
        logger.f('asd');
      }
      driverData = List.from(driverList);
      loadingGetUser = false;
      return driverData;
    } catch (e) {
      logger.f(e);
    }
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

  Future<Vehicle> getVehicle({required String uid}) async {
    DocumentSnapshot<Object?> vehicleCollection =
        await FirebaseFirestore.instance.collection('vehicle').doc(uid).get();
    Map<String, dynamic> data =
        vehicleCollection.data() as Map<String, dynamic>;
    Vehicle vehicle = Vehicle.fromJson(data);
    return vehicle;
  }

  Future<List<User>> getDriverData() async {
    try {
      String? companyUid = localStorage.read(companyUidKey) ?? '';
      QuerySnapshot<Object?> driversCollection = await FirebaseFirestore
          .instance
          .collection('user')
          .where('type', isEqualTo: driverKey)
          .where('company_uid', isEqualTo: companyUid)
          .get();
      List<User> driverList = [];
      latlnglist = [];
      await Future.wait(driversCollection.docs.map((doc) async {
        var data = doc.data() as Map<String, dynamic>;
        User driver = User.fromJson(data);
        logger.f(driver.name);
        var positionData = await getPosition(uid: driver.uid);
        var vehicleData = await getVehicle(uid: driver.vehicleUid);
        driver.position = positionData[0];
        driver.position.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        driver.totalDistance = calculateTotalDistance(positionData[1]);
        driver.distanceToday = calculateTotalDistance(positionData[2]);
        driver.vehicle = vehicleData;
        driver.tripHistory = separatePositionsByDateTime(positionData[0]);
        driverList.add(driver);
      }).toList());
      logger.f('asd driver list ${driverList.length}');
      return driverList;
    } catch (e) {
      logger.f(e);
      return [];
    }
  }
}

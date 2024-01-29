import 'dart:math' show cos, sqrt, asin, sin, pow, min, max, atan2;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:vms/auth/model/driver_model.dart';
import 'package:vms/auth/model/user_model.dart';
import 'package:vms/constant.dart';
import 'package:vms/global/function/date_function.dart';
import 'package:vms/global/model/notification_model.dart';

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

  List<Service> _listService = [];
  List<Service> get listService => _listService;
  set listService(List<Service> value) {
    _listService = value;
    notifyListeners();
  }

  List<NotificationModel> _listNotif = [];
  List<NotificationModel> get listNotif => _listNotif;
  set listNotif(List<NotificationModel> value) {
    _listNotif = value;
    notifyListeners();
  }

  List<Vehicle> _listVehicle = [];
  List<Vehicle> get listVehicle => _listVehicle;
  set listVehicle(List<Vehicle> value) {
    _listVehicle = value;
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
    const double earthRadius = 6371;

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
          .collection('position')
          .where('user_uid', isEqualTo: uid)
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

  Future<Map<int, dynamic>> getPositionVehicle({required String uid}) async {
    try {
      List<PositionModel> res = [];
      List<LatLng> latlngList = [];
      List<LatLng> latlngListToday = [];
      var positionCollection = await FirebaseFirestore.instance
          .collection('position')
          .where('vehicle_uid', isEqualTo: uid)
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
      if (driverList.length > 1) {
        lowestDriverData
            .sort((a, b) => a.distanceToday.compareTo(b.distanceToday));
        highestDriverData
            .sort((a, b) => b.distanceToday.compareTo(a.distanceToday));
        driverList
            .sort((a, b) => a.nextServiceOdo!.compareTo(b.nextServiceOdo!));
      } else {}
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

  Future<List<Vehicle>> getListVehicle({bool unique = false}) async {
    try {
      listVehicle = [];
      var companyUid = localStorage.read(companyUidKey);
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('vehicle')
          .where('company_uid', isEqualTo: companyUid)
          .get();

      List<Vehicle> vehicles = [];
      querySnapshot.docs.map((doc) {
        late Vehicle data =
            Vehicle.fromJson(doc.data() as Map<String, dynamic>);
        Future.delayed(const Duration()).then((value) async {
          data.lastService = await getServicesCloserToCurrentDay(uid: data.uid);
        });
        vehicles.add(data);
      }).toList();
      for (int i = 0; i < vehicles.length; i++) {
        bool dataFound = false;
        for (int j = 0; j < driverData.length; j++) {
          if (driverData[j].vehicleUid != '') {
            if (driverData[j].vehicle!.uid == vehicles[i].uid) {
              dataFound = true;
              break;
            }
          }
        }
        if (!dataFound) {
          listVehicle.add(vehicles[i]);
        }
      }
      if (!unique) {
        listVehicle = vehicles;
      }
      return vehicles;
    } catch (e) {
      return [];
    }
  }

  Future<Vehicle> getVehicle({required String uid}) async {
    DocumentSnapshot<Object?> vehicleCollection =
        await FirebaseFirestore.instance.collection('vehicle').doc(uid).get();
    Map<String, dynamic> data =
        vehicleCollection.data() as Map<String, dynamic>;
    Vehicle vehicle = Vehicle.fromJson(data);
    vehicle.lastService = await getServicesCloserToCurrentDay(uid: uid);
    return vehicle;
  }

  Future<Service> getServicesCloserToCurrentDay({required String uid}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('vehicle')
        .doc(uid)
        .collection('service')
        .orderBy('created_at', descending: true)
        .limit(1) // Adjust the limit as needed
        .get();
    late Service service;
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      service = Service.fromMap(doc.data() as Map<String, dynamic>);
    }
    return service;
  }

  Future<List<Service>> getListServices({required String uid}) async {
    List<Service> temp = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('vehicle')
        .doc(uid)
        .collection('service')
        .orderBy('created_at', descending: true)
        .get();
    late Service service;
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      service = Service.fromMap(doc.data() as Map<String, dynamic>);
      temp.add(service);
    }
    logger.f(temp.length);
    listService = temp;
    return temp;
  }

  double _toRadians(double degrees) {
    return degrees * (pi / 180.0);
  }

  double haversine(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0; // Earth radius in kilometers

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    final distance = R * c;

    return distance;
  }

  double totalDistanceCoverage(List<PositionModel> positions) {
    positions.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    Map<String, double> totalDistanceByDay = {};
    double previousLatitude = 0.0;
    double previousLongitude = 0.0;

    for (int i = 0; i < positions.length; i++) {
      PositionModel position = positions[i];

      // Extract day from createdAt
      String day =
          '${position.dateTime.year}-${position.dateTime.month}-${position.dateTime.day}';

      if (i > 0 && totalDistanceByDay.containsKey(day)) {
        totalDistanceByDay[day] = totalDistanceByDay[day]! +
            haversine(
              previousLatitude,
              previousLongitude,
              position.geopoint.latitude,
              position.geopoint.longitude,
            );
      } else {
        totalDistanceByDay[day] = 0.0;
      }

      previousLatitude = position.geopoint.latitude;
      previousLongitude = position.geopoint.longitude;
    }
    double totalDistance = totalDistanceByDay.values.fold(0.0, (a, b) => a + b);

    return totalDistance;
  }

  double distanceCoverageCounter(List<PositionModel> positions, DateTime time) {
    positions.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    double totalDistance = 0.0;
    double previousLatitude = 0.0;
    double previousLongitude = 0.0;

    for (int i = 0; i < positions.length; i++) {
      PositionModel position = positions[i];

      if (position.dateTime.isAtSameMomentAs(time)) {
        if (i > 0) {
          totalDistance += haversine(
            previousLatitude,
            previousLongitude,
            position.geopoint.latitude,
            position.geopoint.longitude,
          );
        }

        previousLatitude = position.geopoint.latitude;
        previousLongitude = position.geopoint.longitude;
      } else {
        break;
      }
    }

    return totalDistance;
  }

  double distanceCoveragePast(List<PositionModel> positions, int substraction) {
    positions.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    DateTime currentDate = DateTime.now();
    DateTime subtr = substraction == 0
        ? DateTime(currentDate.year, currentDate.month, currentDate.day)
        : currentDate.subtract(Duration(days: substraction));

    double totalDistance = 0.0;
    double previousLatitude = 0.0;
    double previousLongitude = 0.0;

    for (int i = 0; i < positions.length; i++) {
      PositionModel position = positions[i];

      if (position.dateTime.isAfter(subtr)) {
        if (i > 0) {
          totalDistance += haversine(
            previousLatitude,
            previousLongitude,
            position.geopoint.latitude,
            position.geopoint.longitude,
          );
        }

        previousLatitude = position.geopoint.latitude;
        previousLongitude = position.geopoint.longitude;
      } else {
        break;
      }
    }

    return totalDistance;
  }

  Future<List<User>> getDriverData() async {
    try {
      listNotif.clear();
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
        var positionData = await getPosition(uid: driver.uid);
        driver.position = positionData[0];

        driver.position.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        driver.totalDistanceYesterday =
            distanceCoveragePast(positionData[0], 1);
        driver.totalDistancePast7Days =
            distanceCoveragePast(positionData[0], 7);
        driver.totalDistance = totalDistanceCoverage(positionData[0]);
        driver.distanceToday = distanceCoveragePast(positionData[0], 0);
        distanceCoveragePast(positionData[0], 0);
        if (driver.vehicleUid != '') {
          var vehicleData = await getVehicle(uid: driver.vehicleUid);
          driver.vehicle = vehicleData;
          var vehicleLogData = await getPositionVehicle(uid: driver.vehicleUid);
          var totalDistanceVehicleLogData =
              totalDistanceCoverage(vehicleLogData[0]);
          logger.f(totalDistanceVehicleLogData);
          driver.nextServiceOdo = driver.vehicle!.serviceOdoEvery -
              ((driver.vehicle!.odo + totalDistanceVehicleLogData.toInt()) -
                  driver.vehicle!.lastService!.serviceAtOdo);
          for (int i = 0; i < driver.position.length; i++) {
            if ((driver.position[i].speed * 3.6).toInt() >
                vehicleData.overspeedLimit) {
              listNotif.add(
                NotificationModel(
                  speed: (driver.position[i].speed * 3.6).toInt(),
                  driverName: driver.name,
                  date: DateFormat('dd-MMM-yyyy').format(
                    driver.position[i].dateTime,
                  ),
                ),
              );
            }
          }
          listNotif.sort((a, b) => b.date.compareTo(a.date));
          driver.vehicle!.odo =
              (driver.vehicle!.odo + totalDistanceVehicleLogData.toInt());
        }
        driver.tripHistory = separatePositionsByDateTime(positionData[0]);
        driverList.add(driver);
      }).toList());
      return driverList;
    } catch (e) {
      return [];
    }
  }
}

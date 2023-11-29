import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class DriverModel {
  String avatar;
  String fcmToken;
  int lastServiceOdo;
  LatLng latestPosition;
  String licensePlate;
  String name;
  int odometer;
  String password;
  double distanceToday;
  double totalDistance;
  String status;
  String uid;
  String username;
  List<PositionModel> position;

  DriverModel(
      {required this.avatar,
      required this.fcmToken,
      required this.lastServiceOdo,
      required this.latestPosition,
      required this.licensePlate,
      required this.name,
      required this.odometer,
      required this.password,
      required this.distanceToday,
      required this.totalDistance,
      required this.status,
      required this.uid,
      required this.username,
      required this.position});

  factory DriverModel.fromMap(Map<String, dynamic> map) {
    GeoPoint geoPoint = map['latestPosition'];
    LatLng position = LatLng(geoPoint.latitude, geoPoint.longitude);

    return DriverModel(
      distanceToday: 0,
      totalDistance: 0,
      position: map['position'] ?? [],
      avatar: map['avatar'] ?? '',
      fcmToken: map['fcmToken'] ?? '',
      lastServiceOdo: map['lastServiceOdo'] ?? 0,
      latestPosition: position,
      licensePlate: map['licensePlate'] ?? '',
      name: map['name'] ?? '',
      odometer: map['odometer'] ?? 0,
      password: map['password'] ?? '',
      status: map['status'] ?? '',
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'avatar': avatar,
      'fcmToken': fcmToken,
      'lastServiceOdo': lastServiceOdo,
      'latestPosition':
          GeoPoint(latestPosition.latitude, latestPosition.longitude),
      'licensePlate': licensePlate,
      'name': name,
      'odometer': odometer,
      'password': password,
      'status': status,
      'uid': uid,
      'username': username,
    };
  }
}

class PositionModel {
  DateTime dateTime;
  GeoPoint geopoint;
  double speed;

  PositionModel({
    required this.dateTime,
    required this.geopoint,
    required this.speed,
  });

  factory PositionModel.fromMap(Map<String, dynamic> map) {
    GeoPoint geoPoint = map['geopoint'];

    return PositionModel(
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      geopoint: geoPoint,
      speed: map['speed']?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateTime': Timestamp.fromDate(dateTime),
      'geopoint': geopoint,
      'speed': speed,
    };
  }
}

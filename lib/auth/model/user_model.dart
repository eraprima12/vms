import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vms/auth/model/driver_model.dart';

class User {
  String avatar;
  String companyUid;
  DateTime createdAt;
  String password;
  List<PositionModel> position;
  String token;
  String type;
  List<Timestamp> tripHistory;
  bool isOnline;
  String name;
  String uid;
  Vehicle? vehicle;
  String username;
  double totalDistance;
  double distanceToday;
  String vehicleUid;

  User({
    required this.avatar,
    required this.companyUid,
    required this.createdAt,
    required this.distanceToday,
    required this.password,
    required this.isOnline,
    required this.token,
    required this.position,
    required this.type,
    required this.totalDistance,
    required this.uid,
    required this.name,
    this.vehicle,
    required this.tripHistory,
    required this.username,
    required this.vehicleUid,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      isOnline: json['is_online'] ?? false,
      avatar: json['avatar'] ?? "",
      companyUid: json['company_uid'] ?? "",
      createdAt: (json['created_at'] as Timestamp).toDate(),
      password: json['password'] ?? "",
      token: json['token'] ?? "",
      type: json['type'] ?? "",
      name: json['name'] ?? '',
      uid: json['uid'] ?? "",
      tripHistory: [],
      distanceToday: 0,
      vehicle: null,
      position: [],
      totalDistance: 0,
      username: json['username'] ?? "",
      vehicleUid: json['vehicle_uid'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avatar': avatar,
      'company_uid': companyUid,
      'created_at': createdAt.toUtc().toIso8601String(),
      'password': password,
      'token': token,
      'position': position,
      'type': type,
      'uid': uid,
      'username': username,
      'vehicle_uid': vehicleUid,
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
      dateTime: (map['created_at'] as Timestamp).toDate(),
      geopoint: geoPoint,
      speed: map['speed']?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'created_at': Timestamp.fromDate(dateTime),
      'geopoint': geopoint,
      'speed': speed,
    };
  }
}

PositionModel getClosestLocation(
    DateTime targetDate, List<PositionModel> list) {
  PositionModel closestLocation = list[0];
  Duration minDifference = targetDate.difference(closestLocation.dateTime);

  for (var location in list) {
    Duration difference = targetDate.difference(location.dateTime);
    if (difference.abs() < minDifference.abs()) {
      minDifference = difference;
      closestLocation = location;
    }
  }
  return closestLocation;
}

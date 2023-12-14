import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  String avatar;
  String companyUid;
  DateTime createdAt;
  String licensePlate;
  int odo;
  int overspeedLimit;
  int serviceOdoEvery;
  String uid;

  Vehicle({
    required this.avatar,
    required this.companyUid,
    required this.createdAt,
    required this.licensePlate,
    required this.odo,
    required this.overspeedLimit,
    required this.serviceOdoEvery,
    required this.uid,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      avatar: json['avatar'] ?? "",
      companyUid: json['company_uid'] ?? "",
      createdAt: (json['created_at'] as Timestamp).toDate(),
      licensePlate: json['license_plate'] ?? "",
      odo: json['odo'] ?? 0,
      overspeedLimit: json['overspeed_limit'] ?? 0,
      serviceOdoEvery: json['service_odo_every'] ?? 0,
      uid: json['uid'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avatar': avatar,
      'company_uid': companyUid,
      'created_at': createdAt.toUtc().toIso8601String(),
      'license_plate': licensePlate,
      'odo': odo,
      'overspeed_limit': overspeedLimit,
      'service_odo_every': serviceOdoEvery,
      'uid': uid,
    };
  }
}

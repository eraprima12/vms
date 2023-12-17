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
  Service? lastService;

  Vehicle({
    this.lastService,
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
      lastService: null,
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

class Service {
  DateTime createdAt;
  int serviceAtOdo;
  String uid;
  String vehicleUid;

  Service({
    required this.createdAt,
    required this.serviceAtOdo,
    required this.uid,
    required this.vehicleUid,
  });

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      createdAt: map['created_at'] != null
          ? (map['created_at'] as Timestamp).toDate()
          : DateTime.now(),
      serviceAtOdo: map['service_at_odo'] ?? 0,
      uid: map['uid'] ?? '',
      vehicleUid: map['vehicle_uid'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'created_at': createdAt,
      'service_at_odo': serviceAtOdo,
      'uid': uid,
      'vehicle_uid': vehicleUid,
    };
  }
}

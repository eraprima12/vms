import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyModel {
  bool approved;
  DateTime createdAt;
  String name;
  String primaryColor;
  String secondaryColor;
  String? splashScreen;
  String thirdColor;
  String uid;

  CompanyModel({
    required this.approved,
    required this.createdAt,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    this.splashScreen,
    required this.thirdColor,
    required this.uid,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      approved: json['approved'] ?? false,
      createdAt: (json['created_at'] as Timestamp).toDate(),
      name: json['name'] ?? '',
      primaryColor: json['primary_color'] ?? '',
      secondaryColor: json['secondary_color'] ?? '',
      splashScreen: json['splash_screen'],
      thirdColor: json['third_color'] ?? '',
      uid: json['uid'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'approved': approved,
      'created_at': createdAt.toUtc().toIso8601String(),
      'name': name,
      'primary_color': primaryColor,
      'secondary_color': secondaryColor,
      'splash_screen': splashScreen,
      'third_color': thirdColor,
      'uid': uid,
    };
  }
}

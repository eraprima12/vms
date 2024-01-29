import 'package:cloud_firestore/cloud_firestore.dart';

class Company {
  DateTime? createdAt;
  String? name;
  String? primaryColor;
  String? secondaryColor;
  String? splashScreen;
  String? thirdColor;
  String? uid;
  bool? approved;

  Company(
      {this.createdAt,
      this.name,
      this.primaryColor,
      this.secondaryColor,
      this.splashScreen,
      this.thirdColor,
      this.uid,
      this.approved});

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
        createdAt: (json['created_at'] as Timestamp).toDate(),
        name: json['name'] ?? "",
        primaryColor: json['primary_color'] ?? "",
        secondaryColor: json['secondary_color'] ?? "",
        splashScreen: json['splash_screen'] ?? "",
        thirdColor: json['third_color'] ?? "",
        uid: json['uid'] ?? "",
        approved: json['approved'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {
      'primary_color': primaryColor,
      'secondary_color': secondaryColor,
      'splash_screen': splashScreen,
      'third_color': thirdColor,
    };
  }
}

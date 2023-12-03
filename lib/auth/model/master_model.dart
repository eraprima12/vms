class MasterSettingsModel {
  int? maxSpeed;
  int? minDistancePerDay;
  int? servicePerKM;
  String primaryColor;
  String secondaryColor;
  String thirdColor;
  String splashScreen;

  MasterSettingsModel({
    this.maxSpeed,
    this.minDistancePerDay,
    this.servicePerKM,
    required this.primaryColor,
    required this.secondaryColor,
    required this.thirdColor,
    required this.splashScreen,
  });

  factory MasterSettingsModel.fromJson(Map<String, dynamic> json) {
    return MasterSettingsModel(
      maxSpeed: json['maxSpeed'],
      minDistancePerDay: json['minDistancePerDay'],
      servicePerKM: json['servicePerKM'],
      primaryColor: json['primaryColor'] ?? "",
      secondaryColor: json['secondaryColor'] ?? "",
      thirdColor: json['thirdColor'] ?? "",
      splashScreen: json['splashScreen'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxSpeed': maxSpeed,
      'minDistancePerDay': minDistancePerDay,
      'servicePerKM': servicePerKM,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'thirdColor': thirdColor,
      'splashScreen': splashScreen,
    };
  }
}

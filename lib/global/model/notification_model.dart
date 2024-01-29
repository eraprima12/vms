class NotificationModel {
  final int speed;
  final String driverName;
  final String date;

  NotificationModel(
      {required this.speed, required this.driverName, required this.date});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
        speed: json['speed'] as int,
        driverName: json['driverName'] as String,
        date: json['date'] as String);
  }

  Map<String, dynamic> toJson() {
    return {
      'speed': speed,
      'driverName': driverName,
    };
  }
}

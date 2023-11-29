class UserModel {
  final String uid;
  final String username;
  final String password;
  final String fcmToken;

  UserModel({
    required this.uid,
    required this.username,
    required this.password,
    required this.fcmToken,
  });
}

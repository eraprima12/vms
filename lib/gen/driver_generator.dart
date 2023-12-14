import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:vms/global/function/random_string_generator.dart';

Future<void> generateAndStoreData(name, username) async {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Generate UID
  String uid = generateRandomString(length: 10);

  // Generate random position
  GeoPoint position = generateRandomGeoPoint();

  // Get current timestamp
  Timestamp timestamp = Timestamp.now();

  // Create document for position collection

  // Update driver document with UID
  CollectionReference driverCollection = firestore.collection('user');
  DocumentReference driverDocRef = driverCollection.doc(uid);

  // Get FCM token
  String fcmToken = await messaging.getToken() ?? '';

  // Set data in the driver collection
  await firestore.collection('user').doc(uid).set({
    'avatar': '',
    'company_uid': '9CiTjte8yjee5CxHuLHg',
    'created_at': Timestamp.now(),
    'is_online': true,
    'password': '123456',
    'token': '',
    'type': 'driver',
    'uid': uid,
    'username': username,
    'vehicle_uid': 'vA56X7qO4iQR9jCuzpgU',
  }).then((value) async {
    CollectionReference positionCollection =
        driverCollection.doc(uid).collection('position');
    DocumentReference positionDocRef =
        positionCollection.doc(generateRandomString(length: 10));
    await positionDocRef
        .set({'geopoint': position, 'dateTime': timestamp, 'speed': 80});
  });
}

String getRandomStatus() {
  List<String> statusOptions = ['offline', 'parking', 'online'];
  int randomIndex = Random().nextInt(statusOptions.length);
  return statusOptions[randomIndex];
}

GeoPoint generateRandomGeoPoint() {
  // Define the bounds for latitude and longitude
  const double minLat = -7;
  const double maxLat = -8;
  const double minLong = 112;
  const double maxLong = 110;

  // Generate random latitude and longitude within bounds
  double randomLat = minLat + (Random().nextDouble() * (maxLat - minLat));
  double randomLong = minLong + (Random().nextDouble() * (maxLong - minLong));

  // Create and return the GeoPoint
  return GeoPoint(randomLat, randomLong);
}

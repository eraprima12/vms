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
  CollectionReference driverCollection = firestore.collection('driver');
  DocumentReference driverDocRef = driverCollection.doc(uid);

  // Get FCM token
  String fcmToken = await messaging.getToken() ?? '';

  // Set data in the driver collection
  await driverDocRef.set({
    'uid': uid,
    'name': name,
    'password': '123456',
    'username': username,
    'fcmToken': fcmToken,
    'avatar': '',
    'odometer': 100,
    'lastServiceOdo': 0,
    'status': getRandomStatus(),
    'licensePlate':
        'L ${Random().nextInt(9999) + 1} ${generateRandomString(length: 3)}',
    'latestPosition': position,
    // Add any other fields you need
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

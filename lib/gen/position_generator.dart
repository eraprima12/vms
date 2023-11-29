import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vms/gen/driver_generator.dart';
import 'package:vms/global/function/random_string_generator.dart';

generatePosition(uid) async {
  GeoPoint position = generateRandomGeoPoint();

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference driverCollection = firestore.collection('driver');

  CollectionReference positionCollection =
      driverCollection.doc(uid).collection('position');
  DocumentReference positionDocRef =
      positionCollection.doc(generateRandomString(length: 10));
  await positionDocRef
      .set({'geopoint': position, 'dateTime': Timestamp.now(), 'speed': 80});
}

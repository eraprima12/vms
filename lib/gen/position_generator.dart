import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vms/gen/driver_generator.dart';
import 'package:vms/global/function/random_string_generator.dart';

generatePosition(uid) async {
  GeoPoint position = generateRandomGeoPoint();

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference driverCollection = firestore.collection('user');

  CollectionReference positionCollection =
      driverCollection.doc(uid).collection('position');
  var uids = generateRandomString(length: 10);
  DocumentReference positionDocRef = positionCollection.doc(uids);
  await positionDocRef.set({
    'geopoint': position,
    'created_at': Timestamp.now(),
    'speed': 80,
    'uid': uids
  });
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vms/auth/model/user_model.dart';
import 'package:vms/gen/driver_generator.dart';
import 'package:vms/global/function/random_string_generator.dart';

generatePosition(uid) async {
  GeoPoint position = generateRandomGeoPoint();

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference positionCollection = firestore.collection('position');

  var uids = generateRandomString(length: 10);
  DocumentReference positionDocRef = positionCollection.doc(uids);
  await positionDocRef.set({
    'geopoint': position,
    'created_at': Timestamp.now(),
    'speed': 80,
    'uid': uids
  });
}

getPosition({required String uid}) async {
  try {
    List<PositionModel> res = [];
    var positionCollection = await FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .collection('position')
        .get();
    if (positionCollection.docs.isNotEmpty) {
      positionCollection.docs.map(
        (e) async {
          var data = e.data();
          PositionModel position = PositionModel.fromMap(data);
          FirebaseFirestore firestore = FirebaseFirestore.instance;
          CollectionReference positionCollection =
              firestore.collection('position');
          var uids = generateRandomString(length: 10);
          DocumentReference positionDocRef = positionCollection.doc(uids);
          await positionDocRef.set({
            'geopoint': position.geopoint,
            'created_at': data['created_at'] as Timestamp,
            'speed': position.speed,
            'uid': uids,
            'user_uid': uid,
            'vehicle_uid': 'vA56X7qO4iQR9jCuzpgU'
          });
          res.add(position);
        },
      ).toList();
    }
  } catch (e) {
    rethrow;
  }
}

migrateLocation(uid, vehicleUID) async {}

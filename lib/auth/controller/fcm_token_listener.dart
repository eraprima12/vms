import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vms/auth/view/auth_page.dart';
import 'package:vms/constant.dart';

class FCMTokenChangeListener {
  StreamSubscription<DocumentSnapshot>? _subscription;

  // Provide the UID of the admin
  final String uid;
  final String currentToken;

  FCMTokenChangeListener({
    required this.uid,
    required this.currentToken,
  });

  // Start listening to token changes
  void startListening() {
    _subscription = FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        String? fcmToken = snapshot.get('token');
        log(jsonEncode('$currentToken $fcmToken'));
        if (fcmToken != currentToken) {
          stopListening();
          pageMover.pushAndRemove(widget: const LoginPage());
          // popupHandler.showErrorPopup('Session Expired');
        }
      }
    });
  }

  // Stop listening to token changes
  void stopListening() {
    _subscription?.cancel();
  }
}

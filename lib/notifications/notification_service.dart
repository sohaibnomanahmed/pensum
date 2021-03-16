import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:leaf/notifications/models/notifications.dart';

class NotificationService {
  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;

  const NotificationService(this._firestore, this._messaging);

  // get initial message to check if we are returning from a terminated state
  Future<RemoteMessage> get getInitialMessage => _messaging.getInitialMessage();

  // ask permission needed for ios
  Future<NotificationSettings> requestPermission() async {
    return _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  // subscribe to a spesific topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  // unsubscribe from a spesific topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  // set notifications data
  Future<void> setNotifications(
      {@required String uid, @required Notifications notifications}) {
    return _firestore
        .collection('notifications')
        .doc(uid)
        .set(notifications.toMap(), SetOptions(merge: true));
  }

  // get notifications stream
  Stream<Notifications> fetchNotifications(String uid) {
    return _firestore
        .collection('notifications')
        .doc(uid)
        .snapshots()
        .map((notifications) => Notifications.fromFirestore(notifications));
  }
}

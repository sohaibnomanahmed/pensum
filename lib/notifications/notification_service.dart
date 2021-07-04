import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// get initial message to check if we are returning from a terminated state
  Future<RemoteMessage?> get getInitialMessage => _messaging.getInitialMessage();

  /// ask permission needed for ios
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

  /// subscribe to a spesific topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  /// unsubscribe from a spesific topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  /// get chat notification stream
  Stream<bool> fetchChatNotification(String uid) {
    return _firestore
        .collection('chats')
        .doc(uid)
        .collection('recipients')
        .where('notification', isEqualTo: true)
        .snapshots()
        .map((list) => list.docs.isEmpty ? false : true);
  }

  /// get book notification stream
  Stream<bool> fetchFollowingNotification(String uid) {
    return _firestore
        .collection('profiles')
        .doc(uid)
        .collection('following')
        .where('notification', isEqualTo: true)
        .snapshots()
        .map((list) => list.docs.isEmpty ? false : true);
  }
}

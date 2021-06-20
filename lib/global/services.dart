import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:leaf/authentication/authentication_service.dart';
import 'package:leaf/notifications/notification_service.dart';
import 'package:leaf/presence/presence_service.dart';

/// Services that shoudl be [global] i.e only access from the same place
/// this is done so that the data stored in [presence provider] by example
/// is the same for every provider that accesses the [presence service]
/// some services should have their own data, like [deals service] as it should
/// show different data when accessed from different pages.
class GlobalServices{
  static final presenceService = PresenceService(FirebaseDatabase.instance);
  static final authenticationService = AuthenticationService(FirebaseAuth.instance);
  static final notificationService = NotificationService(FirebaseFirestore.instance, FirebaseMessaging.instance);
}
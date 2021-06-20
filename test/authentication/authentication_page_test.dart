import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaf/authentication/authentication_page.dart';
import 'package:leaf/authentication/authentication_provider.dart';
import 'package:leaf/authentication/authentication_service.dart';
import 'package:leaf/following/follow_service.dart';
import 'package:leaf/notifications/notification_service.dart';
import 'package:leaf/presence/presence_service.dart';
import 'package:leaf/profile/profile_service.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockFirebaseDatabase extends Mock implements FirebaseDatabase {}

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

void main() {
  final _mockAuth = MockFirebaseAuth();
  final _mockUserCredential = MockUserCredential();
  final _mockFirestore = MockFirebaseFirestore();
  final _mockDatabase = MockFirebaseDatabase();
  final _mockMessaging = MockFirebaseMessaging();

  final _authenticationSerive = AuthenticationService(_mockAuth);
  final _profileService = ProfileService(_mockFirestore);
  final _followService = FollowService(_mockFirestore);
  final _presenceService = PresenceService(_mockDatabase);
  final _notificationProvider =
      NotificationService(_mockFirestore, _mockMessaging);

  final _authenticationProvider = AuthenticationProvider(
    authenticationService: _authenticationSerive,
    profileService: _profileService,
    followService: _followService,
    presenceService: _presenceService,
    notificationService: _notificationProvider,
  );
  group('Should be able to create, sign in and reset password for a user', () {
    when(_mockAuth
        .createUserWithEmailAndPassword(email: 'correct', password: 'correct')
        .then((value) async => _mockUserCredential));
    testWidgets('Should be able to create a user', (tester) async {
      // GIVEN: acceptable credentials for creating a user
      await tester.pumpWidget(ChangeNotifierProvider(
        create: (ctx) => _authenticationProvider,
        child: AuthenticationPage(),
      ));
    });
  });
}

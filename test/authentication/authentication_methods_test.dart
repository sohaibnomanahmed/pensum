import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import 'package:leaf/authentication/authentication_provider.dart';
import 'package:leaf/authentication/authentication_service.dart';
import 'package:leaf/profile/profile_service.dart';

void main() {
  final auth = MockFirebaseAuth();
  final firestore = FakeFirebaseFirestore();

  final _authenticationSerive = AuthenticationService(auth);
  final _profileService = ProfileService(firestore);

  final _authenticationProvider = AuthenticationProvider(
    authenticationService: _authenticationSerive,
    profileService: _profileService,
  );

  group('Should be able to create, sign in and reset password for a user', () {
    test('Should be able to create a user', () async {
      // GIVEN: acceptable credentials for creating a user
      final firstname = 'firstname';
      final lastname = 'lastname';
      final email = 'bob@somedomain.com';
      final password = 'correct';
      // WHEN: createUser is called
      final res = await _authenticationProvider.createUser(
          firstname: firstname,
          lastname: lastname,
          email: email,
          password: password);
      // THEN: user should be created
      expect(res, true);
    });
    test('Should not be able to create a user with missing credentials', () async {
      // GIVEN: missing credentials for creating a user
      final firstname = 'firstname';
      final lastname = '';
      final email = 'bob@somedomain.com';
      final password = 'correct';
      // WHEN: createUser is called
      final res = await _authenticationProvider.createUser(
          firstname: firstname,
          lastname: lastname,
          email: email,
          password: password);
      // THEN: user should not be created
      expect(res, false);
    });
    test('Should be able to sign a user in', () async {
      // GIVEN: acceptable credentials for signing a user in
      final email = 'bob@somedomain.com';
      final password = 'correct';
      // WHEN: signIn is called
      final res = await _authenticationProvider.signIn(
          email: email,
          password: password);
      // THEN: user should be signed in
      expect(res, true);
    });
    // test('Should be able to reset password', () async {
    //   // GIVEN: acceptable credentials for reseting a users password
    //   final email = 'bob@somedomain.com';
    //   // WHEN: resetPassword is called
    //   final res = await _authenticationProvider.resetPassword(email);
    //   // THEN: the password should be reset
    //   expect(res, true);
    // });
  });
}

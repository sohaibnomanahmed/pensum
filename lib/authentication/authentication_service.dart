import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService{
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// getters
  User get currentUser => _auth.currentUser;
  Stream<User> get authState => _auth.authStateChanges();

  /// create user
  Future<UserCredential> createUser({@required String email, @required String password}) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// sign user in
  Future<UserCredential> signIn({@required String email, @required String password}) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// sign user out
  Future<void> signOut() {
    return _auth.signOut();
  }

  /// reauthenticate
  Future<void> reauthenticate({@required String email, @required String password}) {
    return currentUser.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email, password: password));
  }

  /// change password
  Future<void> changePassword(String newPassword) {
    return currentUser.updatePassword(newPassword);
  }

  /// reset password
  Future<void> resetPassword(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  /// delete user
  Future<void> deleteUser() {
    return currentUser.delete();
  }
}
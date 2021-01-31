import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../global/services.dart';

class AuthenticationProvider with ChangeNotifier {
  final _authenticationService = FirebaseService.authentication;

  var _isLoading = false;
  var _errorMessage;

  // getters
  bool get isLoading => _isLoading;
  bool get isEmailVerified => _authenticationService.currentUser.emailVerified;
  Stream<User> get authState => _authenticationService.authState;
  String get errorMessage => _errorMessage;

  /*
   * tries to create a user in using firebase, if the successfull returns true
   * if an error occurs, cathes the exception, store error message and return false
   */
  Future<bool> createUser(
      {@required String email, @required String password}) async {
    _isLoading = true;
    notifyListeners();
    try {
      // create user
      final userCredentials = await _authenticationService.createUser(
          email: email, password: password);
      final user = userCredentials.user;
      // send email varification
      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (error) {
      _errorMessage = error.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /*
   * tries to sign the user in using firebase, if the successfull returns true
   * if an error occurs, cathes the exception, store error message and return false
   */
  Future<bool> signIn(
      {@required String email, @required String password}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final userCredentials =
          await _authenticationService.signIn(email: email, password: password);
      final user = userCredentials.user;
      // send email varification
      if (!user.emailVerified) {
        _errorMessage = 'Email is not verified';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on FirebaseAuthException catch (error) {
      _errorMessage = error.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /*
   * tries to log the user out using firebase, if the successfull returns true
   * if an error occurs, cathes the exception, store error message and return false
   */
  Future<bool> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authenticationService.signOut();
    } on FirebaseAuthException catch (error) {
      _errorMessage = error.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /*
   * tries to reset users passwrod using firebase, if the successfull returns true
   * if an error occurs, cathes the exception, store error message and return false
   */
  Future<bool> resetPassword() async {
    _isLoading = true;
    notifyListeners();
    try {
      final email = _authenticationService.currentUser.email;
      await _authenticationService.resetPassword(email);
    } on FirebaseAuthException catch (error) {
      _errorMessage = error.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /*
   * tries to delete the user using firebase, if the successfull returns true
   * if an error occurs, cathes the exception, store error message and return false
   */
  Future<bool> deleteUser(String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      // get email of current user
      final email = _authenticationService.currentUser.email;
      // sicen deleting user is a sensitive opperation, wee need to reauthenticate
      await _authenticationService.reauthenticate(email: email, password: password);
      // delete the current user
      await _authenticationService.deleteUser();
    } on FirebaseAuthException catch (error) {
      _errorMessage = error.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
    _isLoading = false;
    notifyListeners();
    return true;
  }
}

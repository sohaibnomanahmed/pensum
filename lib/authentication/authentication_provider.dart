import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../profile/models/profile.dart';
import '../global/services.dart';

class AuthenticationProvider with ChangeNotifier {
  final _authenticationService = FirebaseService.authentication;
  final _profileService = FirebaseService.profile;

  var _isLoading = false;
  var _unknownMessage = 'Error: please check your network connection';
  String _errorMessage;

  // getters
  bool get isLoading => _isLoading;
  bool get isEmailVerified => _authenticationService.currentUser.emailVerified;
  Stream<User> get authState => _authenticationService.authState;
  String get errorMessage => _errorMessage;

  /*
   * tries to create a user in using firebase, if the successfull returns true
   * if an error occurs, cathes the exception, store error message and return false
   */
  Future<bool> createUser({
    @required String firstname,
    @required String lastname,
    @required String email,
    @required String password,
  }) async {
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
      // create profile data in firestore
      final profile = Profile(
        uid: user.uid,
        firstname: firstname,
        lastname: lastname,
        imageUrl: 'https://firebasestorage.googleapis.com/v0/b/leaf-e52aa.appspot.com/o/profile.png?alt=media&token=ef36af4e-c528-4851-b429-53f867672b33',
        userItems: {}
      );
      await _profileService.setProfile(uid: user.uid, profile: profile);
    } on FirebaseAuthException catch (error) {
      _errorMessage = error.message;
      if (error.code == 'unknown') {
        _errorMessage = _unknownMessage;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (error){
      print(error.toString());
    }
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /*
   * tries to sign a user in using firebase, if the successfull returns true
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
      print(error.code);
      _errorMessage = error.message;
      if (error.code == 'unknown') {
        _errorMessage = _unknownMessage;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /*
   * tries to log the current user out using firebase, if the successfull returns true
   * if an error occurs, cathes the exception, store error message and return false
   */
  Future<bool> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authenticationService.signOut();
    } on FirebaseAuthException catch (error) {
      _errorMessage = error.message;
      if (error.code == 'unknown') {
        _errorMessage = _unknownMessage;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /*
   * tries to reset a users password using firebase, if the successfull returns true
   * if an error occurs, cathes the exception, store error message and return false
   */
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authenticationService.resetPassword(email);
    } on FirebaseAuthException catch (error) {
      _errorMessage = error.message;
      if (error.code == 'unknown') {
        _errorMessage = _unknownMessage;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /*
   * tries to delete the current user using firebase, if the successfull returns true
   * if an error occurs, cathes the exception, store error message and return false
   */
  Future<bool> deleteUser(String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      // get email of current user
      final email = _authenticationService.currentUser.email;
      // sicen deleting user is a sensitive opperation, wee need to reauthenticate
      await _authenticationService.reauthenticate(
          email: email, password: password);
      // delete the current user
      await _authenticationService.deleteUser();
    } on FirebaseAuthException catch (error) {
      _errorMessage = error.message;
      if (error.code == 'unknown') {
        _errorMessage = _unknownMessage;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
    _isLoading = false;
    notifyListeners();
    return true;
  }
}

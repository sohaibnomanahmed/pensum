import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:leaf/authentication/authentication_service.dart';
import 'package:leaf/following/follow_service.dart';
import 'package:leaf/global/services.dart';
import 'package:leaf/notifications/notification_service.dart';
import 'package:leaf/profile/profile_service.dart';

import '../profile/models/profile.dart';

class AuthenticationProvider with ChangeNotifier {
  final _authenticationService = AuthenticationService();
  final _profileService = ProfileService();
  final _followService = FollowService();
  final _notificationService = NotificationService();
  final _presenceService = GlobalServices.presenceService;

  var _isLoading = false;
  final _unknownMessage = 'Error: please check your network connection';
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
      // create profile data in firestore
      final profile = Profile(
        uid: user.uid,
        creationTime: user.metadata.creationTime,
        firstname: firstname,
        lastname: lastname,
        imageUrl: 'https://firebasestorage.googleapis.com/v0/b/leaf-e52aa.appspot.com/o/profile.png?alt=media&token=ef36af4e-c528-4851-b429-53f867672b33',
        userItems: {}
      );
      await _profileService.setProfile(uid: user.uid, profile: profile);
      // send email varification
      if (!user.emailVerified) {
        await user.sendEmailVerification();
        // log user out so he/she can log inn
        await _authenticationService.signOut();
      }

      // set the user to be offline
      // await _presenceService.setUserPresence(userCredential.user.uid, false);
    } on FirebaseAuthException catch (error) {
      _errorMessage = error.message;
      if (error.code == 'unknown') {
        _errorMessage = _unknownMessage;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (error){
      print('Error during auth: $error');
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
        await _authenticationService.signOut();
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // subscribe to all topics
      final followings = await _followService.getAllFollowingIds(user.uid);
      await _notificationService.subscribeToTopic(user.uid);
      followings.forEach((following) async { 
        await _notificationService.subscribeToTopic(following);
      });

    } on FirebaseAuthException catch (error) {
      _errorMessage = error.message;
      if (error.code == 'unknown') {
        print(error);
        _errorMessage = _unknownMessage;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (error){
      print('Error during auth: $error');
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
      // unsubscribe from all topics
      final user = _authenticationService.currentUser;
      final followings = await _followService.getAllFollowingIds(user.uid);
      await _notificationService.unsubscribeFromTopic(user.uid);
      for(var following in followings){
        await _notificationService.unsubscribeFromTopic(following);
      };

      // remove presence
      await _presenceService.disconnect(signout: true);

      await _authenticationService.signOut();
    } on FirebaseAuthException catch (error) {
      _errorMessage = error.message;
      if (error.code == 'unknown') {
        _errorMessage = _unknownMessage;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (error){
      print('Error during auth: $error');
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
      // unsubscribe from all topics
      final user = _authenticationService.currentUser;
      final followings = await _followService.getAllFollowingIds(user.uid);
      await _notificationService.unsubscribeFromTopic(user.uid);
      followings.forEach((following) async { 
        await _notificationService.unsubscribeFromTopic(following);
      });    
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

  // gets the service account used for feedbacks
  Future<Profile> getAdminAccount() async {
    try{
      final adminId = await _profileService.getAdminId();
      return await _profileService.getProfile(adminId);
    } catch (error){
      print('Getting admin account error: $error');
      return null;
    }
  }
}

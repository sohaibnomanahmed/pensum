import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:leaf/authentication/authentication_service.dart';
import 'package:leaf/global/services.dart';
import 'package:leaf/profile/profile_service.dart';

import '../profile/models/profile.dart';

/// AuthenticatioProvider is accessable from the entire app, its the only
/// provider to have an [errorMessage] variable, this is so since authentication
/// from firebase gives usefull feedback to the user on error whihc then are dispalyed
class AuthenticationProvider with ChangeNotifier {
  final AuthenticationService authenticationService;
  final ProfileService profileService;

  AuthenticationProvider({
    required this.authenticationService,
    required this.profileService,
  });

  factory AuthenticationProvider.basic() {
    return AuthenticationProvider(
      authenticationService: GlobalServices.authenticationService,
      profileService: ProfileService(FirebaseFirestore.instance),
    );
  }

  var _isLoading = false;
  final _defaultMessage = 'Error: Somehting went wrong, please try again';
  late String _errorMessage;

  // getters
  bool get isLoading => _isLoading;
  bool get isEmailVerified => authenticationService.currentUser!.emailVerified;
  String get uid => authenticationService.currentUser!.uid;
  String? get email => authenticationService.currentUser!.email;
  Stream<User?> get authState => authenticationService.authState;
  String get errorMessage => _errorMessage;

  /// tries to create a user in using [firebase],  [firstname] and [lastname]
  /// needs to be manually checked, email and password is covered by firebase
  /// if the successfull returns true if an error occurs, cathes the exception,
  /// store error message and return false
  Future<bool> createUser({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();
    if (firstname.isEmpty || lastname.isEmpty) {
      _errorMessage = 'Firstname or lastname can\'t be empty';
      _isLoading = false;
      return false;
    }
    try {
      // create user
      final userCredentials = await authenticationService.createUser(
          email: email, password: password);
      final user = userCredentials.user!;
      final time = user.metadata.creationTime;
      if (time == null) {
        _errorMessage = 'Failed trying to create the user, time not accesable';
        return false;
      }
      // create profile data in firestore
      final profile = Profile(
          uid: user.uid,
          creationTime: time,
          firstname: firstname,
          lastname: lastname,
          imageUrl:
              'https://firebasestorage.googleapis.com/v0/b/leaf-e52aa.appspot.com/o/profile.png?alt=media&token=ef36af4e-c528-4851-b429-53f867672b33',
          userItems: {});
      await profileService.setProfile(uid: user.uid, profile: profile);
      // send email varification
      if (!user.emailVerified) {
        await user.sendEmailVerification();
        // log user out so he/she can log inn
        await authenticationService.signOut();
      }

      // set the user to be offline
      // await _presenceService.setUserPresence(userCredential.user.uid, false);
    } on FirebaseAuthException catch (error) {
      _errorMessage = error.message ?? _defaultMessage;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (error) {
      print('Error during auth: $error');
    }
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// tries to sign a user in using [firebase], if the successfull returns true
  /// if an error occurs, cathes the exception, store error message and return false
  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final userCredentials =
          await authenticationService.signIn(email: email, password: password);
      final user = userCredentials.user!;
      // send email varification
      if (!user.emailVerified) {
        _errorMessage = 'Email is not verified';
        await authenticationService.signOut();
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on FirebaseAuthException catch (error) {
      _errorMessage = error.message ?? _defaultMessage;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (error) {
      print('Error during auth: $error');
    }
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// tries to log the current user out using [firebase], if the successfull returns true
  /// if an error occurs, cathes the exception, store error message and return false
  Future<bool> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      await authenticationService.signOut();
    } on FirebaseAuthException catch (error) {
      _errorMessage = error.message ?? _defaultMessage;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (error) {
      print('Error during auth: $error');
    }
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// tries to reset a users password using [firebase], if the successfull returns true
  /// if an error occurs, cathes the exception, store error message and return false
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      await authenticationService.resetPassword(email);
    } on FirebaseAuthException catch (error) {
      _errorMessage = error.message ?? _defaultMessage;
      _isLoading = false;
      notifyListeners();
      return false;
    }
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// tries to delete the current user using [firebase], if the successfull returns true
  /// if an error occurs, cathes the exception, store error message and return false
  Future<bool> deleteUser(String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      // get email of current user
      final email = authenticationService.currentUser!.email!;
      // sicen deleting user is a sensitive opperation, wee need to reauthenticate
      await authenticationService.reauthenticate(
          email: email, password: password);
      // delete the current user
      await authenticationService.deleteUser();
    } on FirebaseAuthException catch (error) {
      _errorMessage = error.message ?? _defaultMessage;
      _isLoading = false;
      notifyListeners();
      return false;
    }
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// gets the [service account] used for feedbacks
  Future<Profile?> getAdminAccount() async {
    try {
      final adminId = await profileService.getAdminId();
      return await profileService.getProfile(adminId);
    } catch (error) {
      print('Getting admin account error: $error');
      return null;
    }
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leaf/authentication/authentication_service.dart';
import 'package:leaf/books/books_service.dart';
import 'package:leaf/books/models/book.dart';
import 'package:leaf/deals/deals_service.dart';
import 'package:leaf/deals/models/deal.dart';
import 'package:leaf/images/image_cropper_service.dart';
import 'package:leaf/images/image_picker_service.dart';
import 'package:leaf/images/image_upload_service.dart';
import 'package:leaf/profile/profile_service.dart';

import '../profile/models/profile.dart';

class ProfileProvider with ChangeNotifier {
  final _authenticationService = AuthenticationService();
  final _profileService = ProfileService();
  final _dealsService = DealsService();
  final _booksService = BooksService();
  final _imageUploadService = ImageUploadService();
  final _imagePickerService = ImagePickerService();
  final _imageCropperService = ImageCropperService();

  Profile _profile;
  var _isLoading = true;
  var _isError = false;
  String _errorMessage;
  StreamSubscription _subscription;

  // getters
  ProfileProvider get provider => this;
  bool get isLoading => _isLoading;
  bool get isError => _isError;
  Profile get profile => _profile;
  String get errorMessage => _errorMessage;
  List<Deal> get profileDeals => _profile.userItems.isEmpty
      ? []
      : _profile.userItems
          .map((isbn, deal) => MapEntry(isbn, Deal.fromMap(deal, isbn)))
          .values
          .toList();

  /*
   * Subsbribe to a profile stream, if an error accours the stream will be canceled 
   * Should be called in the init state method, and recalled if an error occurs
   */
  void fetchProfile(String uid) {
    // fetch user profile
    var isMe = uid == null ? true : false;
    uid ??= _authenticationService.currentUser.uid;
    final stream = _profileService.fetchProfile(uid);
    _subscription = stream.listen(
      (profile) {
        // if user is deleted, the profile value would be null
        if (profile == null){
          print('Fetch profile error: Profile is null');
          _isError = true;
          _isLoading = false;
          notifyListeners();
          return;
        }
        _profile = profile;
        _profile.isMe = isMe;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print('Fetch profile error: $error');
        _isError = true;
        _isLoading = false;
        notifyListeners();
      },
      cancelOnError: true,
    );
  }

  /*
   *  reload profile when an error occurs, set loading and fetch the profile
   *  again by remaking the stream 
   */
  void reFetchProfile([String uid]) async{
    _isLoading = true;
    _isError = false;
    notifyListeners();
    fetchProfile(uid);
  }

  Future<Book> getDealedBook(String isbn){
    return _booksService.getBook(isbn);
  }

  /*
   * Deletes a deal both from the users profile and from the books deals page
   * if successfull return true, if an error occurs set error message and retun false 
   */
  Future<bool> deleteDeal(
      {@required String productId, @required String id}) async {
    try {
      // remove deal from the book
      await _dealsService.deleteDeal(productId: productId, id: id);
      // remove deal from users profile
      final user = _authenticationService.currentUser;
      await _profileService.deleteDeal(uid: user.uid, id: id);
    } catch (error) {
      print('Removing deal error: $error');
      _errorMessage = 'An error occured trying to delete the deal';
      return false;
    }
    return true;
  }

  /*
   * set the user profile, this is called from the profile page
   * and will update the current profile of the user, returns true if
   * successfull and false if an error occurs
   */
  Future<bool> setProfile({
    @required String firstname,
    @required String lastname,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = _authenticationService.currentUser;
      // add changes to the user profile
      _profile.firstname = firstname;
      _profile.lastname = lastname;
      // update the user object in the database
      await _profileService.setProfile(uid: user.uid, profile: _profile);
    } catch (error) {
      print('Add deal error: $error');
      _errorMessage = 'Something went wrong, please try again!';
      _isLoading = false;
      notifyListeners();
      return false;
    }
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /*
   * set the user profile image, if no image is choosen return false, no
   * errorMessage is set since not reachable as pages change, if an error 
   * occurs return false. if successfull return true do not need to set isLoading 
   * to false as this shoul happen, when the profile is reloaded from firebase
   */
  Future<bool> setProfileImage(ImageSource source) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Choose image from image picker service
      final image = await _imagePickerService.pickImage(source);
      if (image == null) {
        print('Error picking image');
        _isLoading = false;
        notifyListeners();
        return false;
      }
      // Crop choosen image
      var croppedImage = await _imageCropperService.pickImage(image);
      if (croppedImage == null) {
        print('Error cropping image');
        _isLoading = false;
        notifyListeners();
        return false;
      }
      // Upload image to firebase storage
      final user = _authenticationService.currentUser;
      final imageUrl = await _imageUploadService.uploadProfileImage(
          image: croppedImage, uid: user.uid);
      // Add new imageUrl to user
      _profile.imageUrl = imageUrl;

      // Upload imageUrl to firestore user data
      await _profileService.setProfile(uid: user.uid, profile: _profile);
    } catch (error) {
      print(error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
    return true;
  }

  /*
   * Cancel suscription on dispose 
   */
  @override
  void dispose() {
    super.dispose();
    if (_subscription != null) {
      _subscription.cancel();
    }
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leaf/authentication/authentication_service.dart';
import 'package:leaf/books/books_service.dart';
import 'package:leaf/books/models/book.dart';
import 'package:leaf/deals/deals_service.dart';
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

  Profile? _profile;
  var _isLoading = true;
  var _isError = false;
  late StreamSubscription _subscription;

  // getters
  ProfileProvider get provider => this;
  bool get isLoading => _isLoading;
  bool get isError => _isError;
  Profile? get profile => _profile;

  /// Subsbribe to a profile stream, Should be called in the [init state] method of the page
  /// from where it is called, check if null and stores the result in [profile], store if
  /// its is the users profile and stop [loading] if an error accours 
  /// the stream will be canceled, and we will set [isError]
  void fetchProfile(String uid) {
    // fetch user profile
    var isMe = _authenticationService.currentUser!.uid == uid;
    final stream = _profileService.fetchProfile(uid);
    _subscription = stream.listen(
      (profile) {
        _profile = profile;
        _profile!.isMe = isMe;
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

  /// refetch profile when an error occurs, reset [loading] and [error]
  /// then call [fetchProfile] again to remake the stream 
  void reFetchProfile(String uid) async{
    _isLoading = true;
    _isError = false;
    notifyListeners();
    fetchProfile(uid);
  }

  /// returnes a dealed [Book], mainly used for [navigation] 
  Future<Book> getDealedBook(String isbn){
    return _booksService.getBook(isbn);
  }

  /// Deletes a deal both from the users [profile] and from the books [deals page]
  /// if successfull return true, if an error occurs set error message and retun false 
  Future<bool> deleteProfileDeal(
      {required String pid, required String id}) async {
    try {
      // remove deal from the book
      final p1 = _dealsService.deleteDeal(pid: pid, id: id);
      // remove deal from users profile
      final user = _authenticationService.currentUser!;
      _profile!.userItems.remove(id);
      final p2 = _profileService.setProfile(uid: user.uid, profile: _profile!);
      final p3 = _booksService.decrementDealsCount(pid);
      await Future.wait([p1, p2, p3]);
      notifyListeners();
    } catch (error) {
      print('Removing deal error: $error');
      return false;
    }
    return true;
  }

  /// set the user [profile], this is called from the [profile page]
  /// and will update the current [profile] of the user, returns true if
  /// successfull and false if an error occurs
  Future<bool> setProfileName({
    required String firstname,
    required String lastname,
  }) async {
    try {
      final user = _authenticationService.currentUser!;
      // add changes to the user profile
      _profile!.firstname = firstname;
      _profile!.lastname = lastname;
      // update the user object in the database
      await _profileService.setProfile(uid: user.uid, profile: _profile!);
      notifyListeners();
    } catch (error) {
      print('Add deal error: $error');
      return false;
    }
    return true;
  }

  /// set the user profile [image], if no [image] is choosen return false. If an error 
  /// occurs return false. if successfull return true do not need to set [isLoading] 
  /// to false as this should happen, when the profile is reloaded from [firebase]
  Future<bool> setProfileImage(ImageSource source) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Choose image from image picker service
      final image = await _imagePickerService.pickImage(source);
      if (image == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      // Crop choosen image, need to compress as picker dont compress
      var croppedImage = await _imageCropperService.pickImage(image: image, style: CropStyle.circle, ratio: CropAspectRatio(ratioX: 1, ratioY: 1));
      if (croppedImage == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      // Upload image to firebase storage
      final user = _authenticationService.currentUser!;
      final imageUrl = await _imageUploadService.uploadProfileImage(
          image: croppedImage, uid: user.uid);
      // Add new imageUrl to user
      _profile!.imageUrl = imageUrl;

      // Upload imageUrl to firestore user data
      await _profileService.setProfile(uid: user.uid, profile: _profile!);
    } catch (error) {
      print(error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
    return true;
  }

  /// Dispose when the provider is destroyed, cancel the profile subscription
  @override
  void dispose() async {
    super.dispose();
      await _subscription.cancel();
  }
}

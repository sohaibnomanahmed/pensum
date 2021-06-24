import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:leaf/authentication/authentication_service.dart';
import 'package:leaf/books/books_service.dart';
import 'package:leaf/books/models/book.dart';
import 'package:leaf/following/follow_service.dart';
import 'package:leaf/global/services.dart';

import 'models/Follow.dart';

class FollowProvider with ChangeNotifier{
  final _authenticationService = AuthenticationService(FirebaseAuth.instance);
  final _booksService = BooksService(FirebaseFirestore.instance);
  final _followService = FollowService(FirebaseFirestore.instance);
  final _notificationsService = GlobalServices.notificationService;

  List<Follow> _follows = [];
  final _pageSize = 10;
  var _isLoading = true;
  var _isError = false;
  late StreamSubscription _subscription;

  // getters
  bool get isLoading => _isLoading;
  bool get isError => _isError;
  List<Follow> get follows => [..._follows];

  /// Subsbribe to the follows stream, Should be called in the [init state] method of the page
  /// from where it is called, stores the result in [follows] and stop [loading]
  /// if an error accours the stream will be canceled, and we will set [isError]
  void fetchFollows() {
    // get original first batch of follow
    final user = _authenticationService.currentUser!;
    final stream = _followService.fetchFollowing(uid: user.uid, pageSize: _pageSize);
    _subscription = stream.listen(
      (follows) {
        _follows = follows;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print(error);
        _isError = true;
        _isLoading = false;
        notifyListeners();
      },
      cancelOnError: true,
    );
  }

  /// refetch follows when an error occurs, reset [loading] and [error]
  /// then call [fetchFollows] again to remake the stream   
  void reFetchFollows() async{
    _isLoading = true;
    _isError = false;
    notifyListeners();
    fetchFollows();
  }

  /// fetch more follows, starts with setting a [silent loader] so that the method does 
  /// not get called again. Check if [follows] is empty or [isError] or [isSearch] is set
  /// add fetched follows at the end of [follows], catch errors if any and return
  Future<void> fetchMoreFollows() async {
    // only get called one time and not on error screen
    // Aslo if no lastFollow to start from, needs to return
    if (_follows.isEmpty || _isError) {
      return;
    }

    // get more follows
    List<Follow> moreFollows;
    try{
      final user = _authenticationService.currentUser!;
      moreFollows = await _followService.fetchMoreFollowing(uid: user.uid, pageSize: _pageSize);
    } catch (error){
      print('Failed to fetch more follows: $error');
      return;
    }
    // add them the end of the follows list
    _follows.addAll(moreFollows);
    notifyListeners();
  }

  /// Unfollow a spesific [Book], should unsubscribe from [notifications]
  /// return true if successfull and false if an error occurs 
  Future<bool> unfollow(String isbn) async {
    try {
      // remove deal from users profile
      final user = _authenticationService.currentUser!;
      await _followService.removeFollowing(uid: user.uid, id: isbn);
      await _notificationsService.unsubscribeFromTopic(isbn);
    } catch (error) {
      print('Removing deal error: $error');
      return false;
    }
    return true;
  }

  /// returnes a followed [Book], mainly used for [navigation] 
  Future<Book> getFollowedBook(String isbn){
    return _booksService.getBook(isbn);
  }

  /// remove following [notification] for a spesific [Book];
  /// Since this method is preceeds other actions, we need to
  /// decide if it is important to show if it succeeds or not
  /// in this case its not, so we wont return a [Future] to halt the activity  
  void removeFollowingNotification(String id) async {
    try{
      final user = _authenticationService.currentUser!;
      await _followService.removeFollowingNotification(uid: user.uid, id: id);
    }catch(error){
      print('remove notification error: $error');
    }
  }

  /// Dispose when the provider is destroyed, cancel the follow subscription
  @override
  void dispose() async {
    super.dispose();
    await _subscription.cancel();
  }
}
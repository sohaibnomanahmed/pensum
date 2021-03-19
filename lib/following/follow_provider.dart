import 'dart:async';

import 'package:flutter/foundation.dart';

import '../global/services.dart';
import 'models/Follow.dart';

class FollowProvider with ChangeNotifier{
  final _authenticationService = FirebaseService.authentication;
  final _followService = FirebaseService.follow;
  final _notificationsService = FirebaseService.notifications;

  List<Follow> _follows = [];
  final _pageSize = 10;
  var _isLoading = true;
  var _silentLoading = false;
  var _isError = false;
  StreamSubscription _subscription;
  String _errorMessage;

  // getters
  bool get isLoading => _isLoading;
  bool get isError => _isError;
  String get errorMessage => _errorMessage;
  List<Follow> get follows => [..._follows];

  /*
   * Subsbribe to the followstream, if an error accours the stream will be canceled 
   * Should be called in the init state method, and recalled if an error occurs
   */
  void get fetchFollows {
    // get original first batch of follow
    final user = _authenticationService.currentUser;
    final stream = _followService.fetchFollowing(uid: user.uid, pageSize: _pageSize);
    _subscription = stream.listen(
      (follows) {
        // in case there are no follows
        if (follows == null){
          _isLoading = false;
          notifyListeners();
          return;
        }
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

  /*
   *  reload follows when an error occurs, set loading and fetch the follows
   *  again by remaking the stream 
   */
  void reFetchFollows() async{
    _isLoading = true;
    _isError = false;
    notifyListeners();
    fetchFollows;
  }

  /*
   * fetch more books from firebase, starts with setting a silent loader so that
   * the methos does not get called again, also so that the UI does not get updated.
   * if no more books can be fetched return, if error occurs return 
   * if there are more books add the books to _books and return
   */
  Future<void> get fetchMoreFollows async {
    // only get called one time and not on error screen or in a search
    if (_isLoading || _silentLoading || _isError) {
      return;
    }
    // set silent loader
    _silentLoading = true;

    // get more follows
    List<Follow> moreFollows;
    try{
      final user = _authenticationService.currentUser;
      moreFollows = await _followService.fetchMoreFollowing(uid: user.uid, pageSize: _pageSize);
    } catch (error){
      print('Failed to fetch more follows: $error');
      _silentLoading = false;
      return;
    }
    // no more follows to add
    if (moreFollows == null) {
      _silentLoading = false;
      return;
    }
 
    // add them the end of the follows list
    _follows.addAll(moreFollows);
    // update UI then reset the silent loader
    notifyListeners();
    _silentLoading = false;
    return;
  }

  /*
   * Unfollow a spesific book, should unsubscribe from notifications
   * if successfull return true, if an error occurs set error message and retun false 
   */
  Future<bool> unfollow(String isbn) async {
    try {
      // remove deal from users profile
      final user = _authenticationService.currentUser;
      await _followService.removeFollowing(uid: user.uid, id: isbn);
      await _notificationsService.unsubscribeFromTopic(isbn);
    } catch (error) {
      print('Removing deal error: $error');
      _errorMessage = 'An error occured trying to delete the deal';
      return false;
    }
    return true;
  }

  /*
   * Dispose when the provider is destroyed, cancel the follow subscrition
   */
  @override
  void dispose() {
    super.dispose();
    if (_subscription != null) {
      _subscription.cancel();
    }
  }
}
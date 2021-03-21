import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:leaf/deals/models/deal_filter.dart';
import 'package:leaf/following/models/Follow.dart';

import '../books/models/book.dart';
import '../global/services.dart';
import 'models/deal.dart';

class DealsProvider with ChangeNotifier {
  final _authenticationService = FirebaseService.authentication;
  final _profileService = FirebaseService.profile;
  final _dealsService = FirebaseService.deals;
  final _followService = FirebaseService.follow;
  final _notificationsService = FirebaseService.notifications;

  List<Deal> _deals = [];
  final _pageSize = 10;
  var _isFilter = false;
  var _isError = false;
  var _isLoading = true;
  var _isFollowBtnLoading = false;
  var _silentLoading = false;
  var _dealFilter = DealFilter.empty();
  bool _isFollowing;
  StreamSubscription _dealsSubscription;
  StreamSubscription _followSubscribtion;
  String _errorMessage;

  // getters
  bool get isLoading => _isLoading;
  bool get isError => _isError;
  bool get isFilter => _isFilter;
  bool get isFollowing => _isFollowing;
  bool get isFollowBtnLoading => _isFollowBtnLoading;
  String get errorMessage => _errorMessage;
  DealFilter get dealFilter => _dealFilter;
  List<Deal> get deals => [..._deals];

  /*
   * Subsbribe to the deals stream, if an error accours the stream will be canceled 
   * Should be called in the init state method, and recalled if an error occurs
   * after deals are received we called getFollowStatus, after that stream has started we
   * remove the loading
   */
  void fetchDeals(String isbn) {
    // get original first batch of deals
    final stream = _dealsService.fetchDeals(isbn: isbn, pageSize: _pageSize);
    _dealsSubscription = stream.listen(
      (deals) {
        // in case there are no deals
        if (deals == null) {
          return;
        }
        _deals = deals;
        getFollowStatus(isbn);
      },
      onError: (error) {
        print('Fetch deal error: $error');
        _isError = true;
        _isLoading = false;
        notifyListeners();
      },
      cancelOnError: true,
    );
  }

  /*
   *  reload deals when an error occurs, set loading and fetch the deals
   *  again by remaking the stream 
   */
  void refetchDeals(String isbn) async {
    _isLoading = true;
    _isError = false;
    notifyListeners();
    fetchDeals(isbn);
  }

  /*
   * fetch more deals from firebase, starts with setting a silent loader so that
   * the methos does not get called again, also so that the UI does not get updated.
   * if no more deals can be fetched return, if error occurs return 
   * if there are more books add the books to _books and return
   */
  Future<void> fetchMoreDeals(String isbn) async {
    // only get called one time and not on error screen
    if (_isLoading || _silentLoading || _isError) {
      return;
    }
    print('Fetching more deals');
    // set silent loader
    _silentLoading = true;

    // get more books
    List<Deal> moreDeals;
    try {
      if (dealFilter.isEmpty) {
        moreDeals =
            await _dealsService.fetchMoreDeals(isbn: isbn, pageSize: _pageSize);
      } else {
        moreDeals = await _dealsService.fetchMoreFilteredDeals(
            isbn: isbn, pageSize: _pageSize, dealFilter: dealFilter);
      }
    } catch (error) {
      print('Failed to fetch more books: $error');
      _silentLoading = false;
      return;
    }
    // no more books to add
    if (moreDeals == null) {
      _silentLoading = false;
      return;
    }
    // add them the end of the messages list
    _deals.addAll(moreDeals);
    print(_deals.length);
    // update UI then reset the silent loader
    notifyListeners();
    _silentLoading = false;
    return;
  }

  /*
   * setDeal, is a new deal a is will be created, else a previous deal will be 
   * updated with merging. After updating book deals, add the deal to users 
   * profile, return true if successfull and false if an error occurs
   * probably dont need to show a loader
   */
  Future<bool> setDeal({
    String id,
    @required String pid,
    @required String productImage,
    @required String productTitle,
    @required String price,
    @required String quality,
    @required String place,
    @required String description,
  }) async {
    try {
      final user = _authenticationService.currentUser;
      final userProfile = await _profileService.getProfile(user.uid);
      // get a deal id from the database
      id ??= _dealsService.getDealId(pid);
      final deal = Deal(
        id: id,
        uid: user.uid,
        userImage: userProfile.imageUrl,
        userName: userProfile.fullName,
        pid: pid,
        productImage: productImage,
        productTitle: productTitle,
        price: price,
        quality: quality,
        place: place,
        description: description,
        time: Timestamp.now(),
      );
      // add deal to the corresponding book collection database
      await _dealsService.setDeal(deal: deal, id: id);
      // add deal to the user objects item list
      userProfile.userItems[id] = deal.toMap();
      // update the user object in the database
      await _profileService.setProfile(
          uid: userProfile.uid, profile: userProfile);
    } catch (error) {
      print('Add deal error: $error');
      _errorMessage = 'Something went wrong, please try again!';
      return false;
    }
    return true;
  }

  /*
   * Filter deals, based on price, quality and place, price ranges are min and max
   * if none spesified, helse spesified are used, quality is only counted in if
   * spesified, so if places, places can be a match uptil 10 places. If an error 
   * occurs _isError is set to true, probably dont need to show a loader
   */
  Future<void> filterDeals({
    @required String isbn,
    @required int priceAbove,
    @required int priceBelow,
    @required List<String> places,
    @required String quality,
  }) async {
    _isLoading = true;
    _isFilter = true;
    notifyListeners();
    // filter deals
    final _stream = _dealsService.filterDeals(
      isbn: isbn,
      priceAbove: priceAbove,
      priceBelow: priceBelow,
      places: places,
      quality: quality,
      pageSize: _pageSize,
    );
    await _dealsSubscription.cancel();
    _dealsSubscription = _stream.listen((deals) {
      _deals = deals;
      _dealFilter = DealFilter(
          priceAbove: priceAbove,
          priceBelow: priceBelow,
          places: places,
          quality: quality);
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      print('Filter deals error: $error');
      _isError = true;
      _isLoading = false;
      notifyListeners();
    }, cancelOnError: true);
  }

  /*
   * Restores the stored deals, from filtering
   */
  void clearFilter(String isbn) async {
    _isLoading = true;
    notifyListeners();
    await _dealsSubscription.cancel();
    _dealFilter = DealFilter.empty();
    _isFilter = false;
    fetchDeals(isbn);
  }

  /*
   * follow a Book
   */
  Future<bool> followBook(Book book) async {
    _isFollowBtnLoading = true;
    notifyListeners();
    try {
      final user = _authenticationService.currentUser;
      final time = Timestamp.now();
      final follow = Follow(
        pid: book.isbn,
        title: book.titles.first,
        image: book.image,
        year: book.year,
        time: time,
        notification: false,
      );
      await _followService.follow(uid: user.uid, follow: follow);
      await _notificationsService.subscribeToTopic(book.isbn);
    } catch (error) {
      print('Add deal error: $error');
      _errorMessage = 'Something went wrong, please try again!';
      _isFollowBtnLoading = false;
      notifyListeners();
      return false;
    }
    _isFollowBtnLoading = false;
    notifyListeners();
    return true;
  }

  /*
   *  Get the following status for the book
   *  This need to be a stream as changes should be shown to the user
   */
  void getFollowStatus(String isbn) async {
    final user = _authenticationService.currentUser;
    final stream =
        _followService.getFollowingStatus(uid: user.uid, id: isbn);
    _followSubscribtion = stream.listen(
      (isFollowing) {
        _isFollowing = isFollowing;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print('Fetch deal error: $error');
        _isError = true;
        _isLoading = false;
        notifyListeners();
      },
      cancelOnError: true,
    );
  }

  /*
   * Dispose when the provider is destroyed, cancel the deal subscrition
   */
  @override
  void dispose() {
    super.dispose();
    if (_dealsSubscription != null) {
      _dealsSubscription.cancel();
    }
    if (_followSubscribtion != null) {
      _followSubscribtion.cancel();
    }
  }
}

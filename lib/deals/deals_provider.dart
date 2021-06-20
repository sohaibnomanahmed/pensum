import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:leaf/authentication/authentication_service.dart';
import 'package:leaf/deals/deals_service.dart';
import 'package:leaf/deals/models/deal_filter.dart';
import 'package:leaf/following/follow_service.dart';
import 'package:leaf/following/models/Follow.dart';
import 'package:leaf/global/services.dart';
import 'package:leaf/notifications/notification_service.dart';
import 'package:leaf/profile/profile_service.dart';

import '../books/models/book.dart';
import 'models/deal.dart';

/// DealsProvider cant store previous deals in a [cache] variable since
/// there are made multiple streams, and the [lastDeal] pointer in 
/// DealService would become wrong without changing the stream
class DealsProvider with ChangeNotifier {
  final _authenticationService = AuthenticationService(FirebaseAuth.instance);
  final _profileService = ProfileService(FirebaseFirestore.instance);
  final _dealsService = DealsService();
  final _followService = FollowService(FirebaseFirestore.instance);
  final _notificationsService = GlobalServices.notificationService;

  List<Deal> _deals = [];
  final _pageSize = 10;
  var _isFilter = false;
  var _isError = false;
  var _isLoading = true;
  var _isFollowBtnLoading = false;
  var _dealFilter = DealFilter.empty();
  bool _isFollowing = false;
  late StreamSubscription _dealsSubscription;
  StreamSubscription? _followSubscribtion;

  // getters
  bool get isLoading => _isLoading;
  bool get isError => _isError;
  bool get isFilter => _isFilter;
  bool get isFollowing => _isFollowing;
  bool get isFollowBtnLoading => _isFollowBtnLoading;
  DealFilter get dealFilter => _dealFilter;
  List<Deal> get deals => [..._deals];
  DealsProvider get provider => this;

  /// Subsbribe to the deals stream, Should be called in the [init state] method of the page
  /// from where it is called, stores the result in [deals] then calls [getFollowStatus]
  /// for that spesific book. If an error accours the stream will be canceled, 
  /// and we will set [isError]
  void fetchDeals(String isbn) {
    // get original first batch of deals
    final stream = _dealsService.fetchDeals(isbn: isbn, pageSize: _pageSize);
    _dealsSubscription = stream.listen(
      (deals) {
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

  /// refetch deals when an error occurs, reset [loading] and [error]
  /// then call [fetchDeals] again to remake the stream 
  void refetchDeals(String isbn) async {
    _isLoading = true;
    _isError = false;
    notifyListeners();
    fetchDeals(isbn);
  }

  /// fetch more deals, starts with setting a [silent loader] so that the method does 
  /// not get called again. Check if [deals] is empty or [isError] or [isSearch] is set
  /// add fetched deals at the end of [deals], catch errors if any and return
  /// this method takes care of both original deals and [filtered]
  Future<void> fetchMoreDeals(String isbn) async {
    // only get called one time and not on error screen
    // Aslo if no lastDeal to start from, needs to return
    if (_deals.isEmpty || _isError) {
      return;
    }

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
      return;
    }
    // add them the end of the messages list
    _deals.addAll(moreDeals);
    notifyListeners();
  }

  /// A new [deal] will be created, or a previous [deal] will be updated with merging. 
  /// After adding/updating book deals, add/update the [userItems] in the users [profile], 
  /// return true if successfull and false if an error occurs
  Future<bool> setDeal({
    String? id,
    required String pid,
    required String productImage,
    required String productTitle,
    required String price,
    required String quality,
    required String place,
    required String description,
  }) async {
    try {
      final user = _authenticationService.currentUser!;
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
      final p1 = _dealsService.setDeal(deal: deal, id: id);
      // add deal to the user objects item list
      userProfile.userItems[id] = deal.toMap();
      // update the user object in the database
      final p2 = _profileService.setProfile(
          uid: userProfile.uid, profile: userProfile);
      await Future.wait([p1, p2]);    
    } catch (error) {
      print('Add deal error: $error');
      return false;
    }
    return true;
  }

  /// Filter deals, based on [price], [quality] and [place], price ranges are min and max
  /// if none spesified, else spesified are used, quality is only counted in if
  /// spesified, so is places, places can be a match uptil 10 places. Creates a new
  /// stream as changes could occur and paging needs to be matched. 
  /// If an error occurs [isError] is set
  Future<void> filterDeals({
    required String isbn,
    required int priceAbove,
    required int priceBelow,
    required List<String> places,
    required String quality,
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

  /// cancel the filtered deals stream and call [fetchDeals] to restore all
  /// deals, return true if successfull and false if an error occurs
  Future<bool> clearFilter(String isbn) async {
    _isLoading = true;
    notifyListeners();
    try {
    await _dealsSubscription.cancel();
    _dealFilter = DealFilter.empty();
    _isFilter = false;
    fetchDeals(isbn);
    } catch (error){
      print('Error clearing filter $error');
      _isLoading = false;
      notifyListeners();
      return false;
    }
    return true;
  }

  /// follow a [Book], by subscribing to its id, so that [notifications] can
  /// be received when new deals are added. return true if successfull 
  /// and false if an error occurs
  Future<bool> followBook(Book book) async {
    _isFollowBtnLoading = true;
    notifyListeners();
    try {
      final user = _authenticationService.currentUser!;
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
      _isFollowBtnLoading = false;
      notifyListeners();
      return false;
    }
    _isFollowBtnLoading = false;
    notifyListeners();
    return true;
  }

  /// Subscribe to the follow stream, result show if user is following a
  /// certain book, store result in [isFollowing] default is false i.g. no wifi
  /// if an error occurs set [isError]
  void getFollowStatus(String isbn) async {
    final user = _authenticationService.currentUser!;
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

  /// Dispose when the provider is destroyed, cancel the deal subscription
  @override
  void dispose() async {
    super.dispose();
      await _dealsSubscription.cancel();
      await _followSubscribtion?.cancel();
  }
}
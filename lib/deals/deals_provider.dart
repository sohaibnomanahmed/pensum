import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../books/models/book.dart';
import '../global/services.dart';
import 'models/deal.dart';

class DealsProvider with ChangeNotifier {
  final _authenticationService = FirebaseService.authentication;
  final _profileService = FirebaseService.profile;
  final _booksService = FirebaseService.books;

  List<Deal> _deals = [];
  List<Deal> _prevDeals = [];
  final _pageSize = 10;
  var _isFilter = false;
  var _isError = false;
  var _isLoading = true;
  var _silentLoading = false;
  var _subscription;
  String _errorMessage;

  // getters
  bool get isLoading => _isLoading;
  bool get isError => _isError;
  bool get isFilter => _isFilter;
  String get errorMessage => _errorMessage;
  List<Deal> get deals => [..._deals];

  /*
   * Subsbribe to the deals stream, if an error accours the stream will be canceled 
   * Should be called in the init state method, and recalled if an error occurs
   */
  void fetchDeals(String isbn) {
    // get original first batch of deals
    final stream = _booksService.fetchDeals(isbn: isbn, pageSize: _pageSize);
    _subscription = stream.listen(
      (deals) {
        // in case there are no deals
        if (deals == null) {
          return;
        }
        _deals = deals;
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
    // set silent loader
    _silentLoading = true;

    // get more books
    List<Deal> moreDeals;
    try {
      moreDeals =
          await _booksService.fetchMoreDeals(isbn: isbn, pageSize: _pageSize);
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
    // update UI then reset the silent loader
    notifyListeners();
    _silentLoading = false;
    return;
  }

  /*
   * setDeal, is a new deal a is will be created, else a previous deal will be 
   * updated with merging. After updating book deals, add the deal to users 
   * profile, return true if successfull and false if an error occurs
   */
  Future<bool> addDeal({
    String id,
    @required Book book,
    @required String price,
    @required String quality,
    @required String place,
    @required String description,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = _authenticationService.currentUser;
      final userProfile = await _profileService.getProfile(user.uid);
      // get a deal id from the database
      id ??= _booksService.getDealId(book.isbn);
      final deal = Deal(
        id: id,
        userId: user.uid,
        userImage: userProfile.imageUrl,
        userName: userProfile.fullName,
        bookIsbn: book.isbn,
        bookImage: book.image,
        bookTitle: book.titles.first,
        price: price,
        quality: quality,
        place: place,
        description: description,
        time: Timestamp.now(),
      );
      // add deal to the corresponding book collection database
      await _booksService.addDeal(deal: deal, id: id);
      // add deal to the user objects item list
      userProfile.userItems[id] = deal.toMap();
      // update the user object in the database
      await _profileService.setProfile(
          uid: userProfile.uid, profile: userProfile);
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
   * Filter deals, based on price, quality and place, price ranges are min and max
   * if none spesified, helse spesified are used, quality is only counted in if
   * spesified, so if places, places can be a match uptil 10 places. If an error 
   *  occurs _isError is set to true
   */
  Future<void> filterDeals({
    @required String isbn,
    @required int priceAbove,
    @required int priceBelow,
    @required List<String> places,
    @required String quality,
  }) async {
    // only store the loaded deals, when not having a filter
    if (!_isFilter){
      _prevDeals = _deals;
    }
    _isLoading = true;
    _isFilter = true;
    notifyListeners();
    // filter deals
    try {
      _deals = await _booksService.filterDeals(
        isbn: isbn,
        priceAbove: priceAbove,
        priceBelow: priceBelow,
        places: places,
        quality: quality,
      );
    } catch (error) {
      print('Filter deals error: $error');
      _isError = true;
      _isLoading = false;
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  /*
   * Restores the stored deals, from filtering
   */
  void clearFilter(){
    _isLoading = true;
    notifyListeners();
    _deals = _prevDeals;
    _isFilter = false;
    _isLoading = false;
    notifyListeners();
  }

  /*
   * Dispose when the provider is destroyed, cancel the deal subscrition
   */
  @override
  void dispose() {
    super.dispose();
    if (_subscription != null) {
      _subscription.cancel();
    }
  }
}

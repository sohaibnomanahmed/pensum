import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:leaf/books/books_service.dart';

import 'models/book.dart';

class BooksProvider with ChangeNotifier{
  final _booksService = BooksService();

  List<Book> _books = [];
  // can cashe book since only one subscription is made, search gets all mathces. Cashe include all previous.
  List<Book> _cachedBooks = [];
  Map<String, dynamic> _bookTitles = {};
  final _pageSize = 10;
  var _isLoading = true;
  var _silentLoading = false;
  var _isError = false;
  var _isSearch = false;
  StreamSubscription _booksSubscription;
  StreamSubscription _bookTitlesSubscription;

  // getters
  List<Book> get books => [..._books];
  Map<String, dynamic> get bookTitles => {..._bookTitles};
  bool get isLoading => _isLoading;
  bool get isError => _isError;
  bool get isSearch => _isSearch;

  /*
   * Subsbribe to the book stream, if an error accours the stream will be canceled 
   * Should be called in the init state method, and recalled if an error occurs
   */
  void fetchBooks() {
    // get original first batch of books
    final stream = _booksService.fetchBooks(_pageSize);
    _booksSubscription = stream.listen(
      (books) {
        _books = books;
        fetchBookTitles();
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
   *  reload books when an error occurs, set loading and fetch the books
   *  again by remaking the stream 
   */
  void reFetchBooks() async{
    _isLoading = true;
    _isError = false;
    notifyListeners();
    fetchBooks();
  }

  /*
   * fetch more books from firebase, starts with setting a silent loader so that
   * the method does not get called again, also so that the UI does not get updated.
   * if no more books can be fetched return, if error occurs return 
   * if there are more books add the books to _books and return
   */
  Future<void> fetchMoreBooks() async {
    // only get called one time and not on error screen or in a search
    // Also do not get called when original sets of book are being loaded
    if (_isLoading || _silentLoading || _isError || _isSearch) {
      return;
    }
    // set silent loader
    _silentLoading = true;

    // get more books
    List<Book> moreBooks;
    try{
      moreBooks = await _booksService.fetchMoreBooks(_pageSize);
    } catch (error){
      print('Failed to fetch more books: $error');
      _silentLoading = false;
      return;
    }
    // add them the end of the messages list
    _books.addAll(moreBooks);
    // update UI then reset the silent loader
    notifyListeners();
    _silentLoading = false;
    return;
  }

  /*
   * Subsbribe to the book titles stream, if an error accours the stream will be canceled 
   * Should be called in the fetch books method
   */
  void fetchBookTitles() {
    // get book titles
    final stream = _booksService.fetchBookTitles();
    _bookTitlesSubscription = stream.listen(
      (bookTitles) {
        _bookTitles = bookTitles;
        _isError = false;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _isError = true;
        _isLoading = false;
        notifyListeners();
      },
      cancelOnError: true,
    );
  }

  /// /*
  /// * Searches for all books matching a certain title from firebase and sets [_isSearch] flag
  /// * if successfull lists the found books in [_books] and cashe prevoius books
  /// * to be restored when search is cleared, if failed sets flag [_isError]
  /// */
  Future<void> fetchSearchedBook(String title) async {
    // only store the loaded books, when not searching
    // else on double search you get the previous search
    if (!_isSearch){
      _cachedBooks = _books;
    }
    // get books that fits a cetain title
    _isSearch = true;
    _isLoading = true;
    notifyListeners();
    try{
      _books = await _booksService.searchBooksByTitle(title);
    } catch (error){
      print('Failed to fetch books: $error');
      _isError = true;
    }
    _isLoading = false;
    notifyListeners();
  }

  /*
   * Restores the stored books, when a search is called
   * and turns off _isSearch flag
   */
  void clearSearch(){
    _isLoading = true;
    _isSearch = false;
    notifyListeners();
    _books = _cachedBooks;
    _isLoading = false;
    notifyListeners();
  }

  /*
   * Dispose when the provider is destroyed, cancel the book subscrition
   */
  @override
  void dispose() async {
    super.dispose();
    if (_booksSubscription != null) {
      await _booksSubscription.cancel();
    }
    if (_bookTitlesSubscription != null) {
      await _bookTitlesSubscription.cancel();
    }
  }
}
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../global/services.dart';
import 'models/book.dart';

class BooksProvider with ChangeNotifier{
  final _booksService = FirebaseService.books;

  List<Book> _books = [];
  List<Book> _prevBooks = [];
  Map<String, dynamic> _bookTitles = {};
  final _pageSize = 10;
  var _isLoading = true;
  var _silentLoading = false;
  var _isError = false;
  var _isSearch = false;
  StreamSubscription _booksSubscription;
  StreamSubscription _bookTitlesSubscription;

  // getters
  bool get isLoading => _isLoading;
  bool get isError => _isError;
  bool get isSearch => _isSearch;
  List<Book> get books => [..._books];
  Map<String, dynamic> get bookTitles => {..._bookTitles};

  /*
   * Subsbribe to the book stream, if an error accours the stream will be canceled 
   * Should be called in the init state method, and recalled if an error occurs
   */
  void get fetchBooks {
    // get original first batch of books
    final stream = _booksService.fetchBooks(_pageSize);
    _booksSubscription = stream.listen(
      (books) {
        // in case there are no books
        if (books == null){
          return;
        }
        _books = books;
        fetchBookTitles;
      },
      onError: (error) {
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
    fetchBooks;
  }

  /*
   * fetch more books from firebase, starts with setting a silent loader so that
   * the methos does not get called again, also so that the UI does not get updated.
   * if no more books can be fetched return, if error occurs return 
   * if there are more books add the books to _books and return
   */
  Future<void> fetchMoreBooks() async {
    // TODO could be a getter?
    // only get called one time and not on error screen or in a search
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
    // no more books to add
    if (moreBooks == null) {
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
  void get fetchBookTitles {
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

  /*
   * Searches for all books matching a certain title from firebase and sets _isSearch flag
   * if successfull lists the found books in _books and stores prevoius books
   * to be restored when search is cleared, if failed sets flag _isError
   */
  Future<void> fetchSearchedBook(String title) async {
    // only store the loaded books, when not searching
    // else on double search you get the previous search
    if (!_isSearch){
      _prevBooks = _books;
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
    notifyListeners();
    _books = _prevBooks;
    _isSearch = false;
    _isLoading = false;
    notifyListeners();
  }

  /*
   * Dispose when the provider is destroyed, cancel the book subscrition
   */
  @override
  void dispose() {
    super.dispose();
    if (_booksSubscription != null) {
      _booksSubscription.cancel();
    }
    if (_bookTitlesSubscription != null) {
      _bookTitlesSubscription.cancel();
    }
  }
}
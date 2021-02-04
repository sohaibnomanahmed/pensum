import 'dart:async';

import 'package:flutter/foundation.dart';

import '../global/services.dart';
import 'models/book.dart';

class BooksProvider with ChangeNotifier{
  final _booksService = FirebaseService.books;

  List<Book> _books = [];
  final _pageSize = 10;
  var _isLoading = true;
  var _silentLoading = false;
  var _isError = false;
  StreamSubscription _subscription;

  // getters
  bool get isLoading => _isLoading;
  bool get isError => _isError;
  List<Book> get books => [..._books];

  /*
   * Subsbribe to the book stream, if an error accours the stream will be canceled 
   * Should be called in the init state method, and recalled if an error occurs
   */
  void get fetchBooks {
    // get original first batch of books
    final stream = _booksService.fetchBooks(_pageSize);
    _subscription = stream.listen(
      (books) {
        _books = books;
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
   * fetch more books from firebase, starts with setting a silent loader so that
   * the methos does not get called again, also so that the UI does not get updated.
   * if no more books can be fetched return, if error occurs return 
   * if there are more books add the books to _books and return
   */
  Future<void> fetchMoreBooks() async {
    if (_silentLoading || _isError) {
      return;
    }
    // set silent loader
    _silentLoading = true;

    // get more books
    List<Book> moreBooks;
    try{
      moreBooks = await _booksService.fetchMoreBooks(_pageSize);
    } catch (error){
      print("Failed to fetch books: $error");
      _silentLoading = false;
      return;
    }
    // no more books to add
    if (moreBooks == null) {
      _silentLoading = false;
      return;
    }
    moreBooks = moreBooks.toList();
 
    // add them the end of the messages list
    _books.addAll(moreBooks);
    // update UI then reset the silent loader
    notifyListeners();
    _silentLoading = false;
    return;
  }

  /*
   * Dispose when the provider is destroyed, cancel the book subscrition
   */
  @override
  void dispose() {
    super.dispose();
    if (_subscription != null) {
      _subscription.cancel();
    }
  }
}
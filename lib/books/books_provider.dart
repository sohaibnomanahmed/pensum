import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'books_service.dart';
import 'models/book.dart';

class BooksProvider with ChangeNotifier {
  late BooksService booksService = BooksService();
  final int _pageSize = 10;

  List<Book> _books = [];
  Map<String, dynamic> _bookTitles = {};
  var _isLoading = true;
  var _isError = false;
  var _isSearch = false;
  late StreamSubscription _booksSubscription;
  StreamSubscription? _bookTitlesSubscription;

  // getters
  List<Book> get books => [..._books];
  Map<String, dynamic> get bookTitles => {..._bookTitles};
  bool get isLoading => _isLoading;
  bool get isError => _isError;
  bool get isSearch => _isSearch;

  /// Subsbribe to the book stream, Should be called in the [init state] method of the page
  /// from where it is called, stores the result in [books] then calls [fetchBookTitles]
  /// if an error accours the stream will be canceled, and we will set [isError]
  void fetchBooks(String locale) {
    // get original first batch of books
    final stream = booksService.fetchBooks(_pageSize);
    _booksSubscription = stream.listen(
      (books) async {
        books.forEach((book) async => await book.translateLanguage(locale));
        _books = books;
        notifyListeners();
        // so that two subscriptions might not be added
        if (_bookTitles.isEmpty) {
          fetchBookTitles();
        } else {
          _isLoading = false;
          notifyListeners();
        }
      },
      onError: (error) {
        print('Error fetching books $error');
        _isError = true;
        _isLoading = false;
        notifyListeners();
      },
      cancelOnError: true,
    );
  }

  /// refetch books when an error occurs, reset [loading] and [error]
  /// then call [fetchBooks] again to remake the stream
  void reFetchBooks(String locale) async {
    _isLoading = true;
    _isError = false;
    _isSearch = false;
    notifyListeners();
    fetchBooks(locale);
  }

  /// fetch more books, starts with setting a [silent loader] so that the method does
  /// not get called again. Check if [books] is empty or [isError] or [isSearch] is set
  /// add fetched books at the end of [books], catch errors if any and return
  Future<void> fetchMoreBooks(String locale) async {
    // only get called one time and not on error or in a search
    // Aslo if no lastBook to start from, needs to return
    if (_books.isEmpty || _isError || _isSearch) {
      return;
    }
    // get more books
    List<Book> moreBooks;
    try {
      moreBooks = await booksService.fetchMoreBooks(_pageSize);
    } catch (error) {
      print('Failed to fetch more books: $error');
      return;
    }
    moreBooks.forEach((book) async => await book.translateLanguage(locale));
    // add them the end of the messages list
    _books.addAll(moreBooks);
    notifyListeners();
  }

  /// Subscbribe to the book titles stream, should only be called from [fetchBooks]
  /// store the result in [bookTitles] and stop [loading] if an error accours
  /// the stream will be canceled, and we will set [isError]
  void fetchBookTitles() {
    // get book titles
    final stream = booksService.fetchBookTitles();
    _bookTitlesSubscription = stream.listen(
      (bookTitles) {
        _bookTitles = bookTitles;
        _isError = false;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print('Error feteching book titles $error');
        _isError = true;
        _isLoading = false;
        notifyListeners();
      },
      cancelOnError: true,
    );
  }

  /// Searches for all books matching a certain title from [firebase] and sets [isSearch] flag
  /// if successfull lists the found books in [books] and cashe prevoius books in [cashedBooks]
  /// to be restored when search is cleared, do not store prevoius searches
  /// if an error occurs sets [isError]
  Future<void> fetchSearchedBook(String isbn, String locale) async {
    // get books that fits a cetain title
    _isSearch = true;
    _isLoading = true;
    notifyListeners();
    final _stream = booksService.searchBooks(isbn);
    await _booksSubscription.cancel();
    _booksSubscription = _stream.listen(
      (books) {
        books.forEach((book) async => await book.translateLanguage(locale));
        _books = books;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print('Error fetching searched books $error');
        _isError = true;
        _isLoading = false;
        notifyListeners();
      },
      cancelOnError: true,
    );
  }

  /// Restores the [chashed books], when a search is called
  /// and turns off [isSearch] flag
  void clearSearch(String locale) async {
    _isLoading = true;
    notifyListeners();
    try{
      await _booksSubscription.cancel();
      _isSearch = false;
      fetchBooks(locale);
    } catch (error){
      print('Error clearing search $error');
      _isLoading = false;
      _isError = true;
      notifyListeners();
    }
  }

  /// Dispose when the provider is destroyed, cancel the book subscription
  @override
  void dispose() async {
    super.dispose();
    await _booksSubscription.cancel();
    await _bookTitlesSubscription?.cancel();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/book.dart';

class BooksService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentSnapshot lastBook;

  // fetch books
  Stream<List<Book>> fetchBooks(int pageSize) {
    return firestore
        .collection('books')
        .orderBy('year', descending: true)
        .limit(pageSize)
        .snapshots()
        .map(
      (list) {
        if (list.docs.isEmpty) {
          return null;
        }
        lastBook = list.docs.last;
        return list.docs
            .map((document) => Book.fromFirestore(document))
            .toList();
      },
    );
  }

  // fetch and return more books, from current last. If no more books return null
  Future<List<Book>> fetchMoreBooks(int pageSize) async {
    final books = await firestore
        .collection('books')
        .orderBy('year', descending: true)
        .startAfterDocument(lastBook)
        .limit(pageSize)
        .get();
    if (books.docs.isEmpty) {
      return null;
    }
    lastBook = books.docs.last;
    return books.docs.map((document) => Book.fromFirestore(document)).toList();
  }

  // fetch book titles
  Stream<Map> fetchBookTitles() {
    return firestore.collection('books').doc('metadata').snapshots().map(
      (snapshot) {
        return snapshot.data()['titles'];
      },
    );
  }

  // get book
  Future<Book> getBook(String isbn) async {
    final book = await firestore.collection('books').doc(isbn).get();
    return Book.fromFirestore(book);
  }

  // Search books by title
  Future<List<Book>> searchBooksByTitle(String title) async {
    final books = await firestore
        .collection('books')
        .orderBy('year', descending: true)
        .where('title', arrayContains: title)
        .get();

    return books.docs.map((document) => Book.fromFirestore(document)).toList();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/book.dart';

class BooksService {
  final FirebaseFirestore firestore;
  late DocumentSnapshot lastBook;

  BooksService(this.firestore);

  /// fetch books
  Stream<List<Book>> fetchBooks(int pageSize) {
    return firestore
        .collection('books')
        .orderBy('deals', descending: true)
        .limit(pageSize)
        .snapshots()
        .map(
      (list) {
        if (list.docs.isNotEmpty) {
          lastBook = list.docs.last;
        }
        return list.docs
            .map((document) => Book.fromFirestore(document))
            .toList();
      },
    );
  }

  /// fetch and return more books, from current last. If no more books return null
  Future<List<Book>> fetchMoreBooks(int pageSize) async {
    final books = await firestore
        .collection('books')
        .orderBy('deals', descending: true)
        .startAfterDocument(lastBook)
        .limit(pageSize)
        .get();
    if (books.docs.isNotEmpty) {
      lastBook = books.docs.last;
    }
    return books.docs.map((document) => Book.fromFirestore(document)).toList();
  }

  /// fetch book titles
  Stream<Map<String, dynamic>> fetchBookTitles() {
    return firestore.collection('books').doc('metadata').snapshots().map(
      (snapshot) {
        Map<String, dynamic> map;
        map = {};
        // check if the document exist
        if (snapshot.exists){
          // check is the document is not null
          final data = snapshot.data();
          if (data != null){
            return data['titles'] ?? map;
          }    
        }
        return map;
      },
    );
  }

  /// get book
  Future<Book> getBook(String isbn) async {
    final book = await firestore.collection('books').doc(isbn).get();
    return Book.fromFirestore(book);
  }

  // increments deals count for a spesific book
  Future<void> incrementDealsCount(String isbn) async {
    final docRef = firestore.collection('books').doc(isbn);
    return docRef.update(({'deals': FieldValue.increment(1)}));
  }

  // decrements deals count for a spesific book
  Future<void> decrementDealsCount(String isbn) async {
    final docRef = firestore.collection('books').doc(isbn);
    return docRef.update(({'deals': FieldValue.increment(-1)}));
  }

  /// Search books by title
  Future<List<Book>> searchBooksByTitle(String title) async {
    final books = await firestore
        .collection('books')
        .orderBy('year', descending: true)
        .where('title', arrayContains: title)
        .get();
    return books.docs.map((document) => Book.fromFirestore(document)).toList();
  }
}

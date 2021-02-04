import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'models/book.dart';
import '../deals/models/deal.dart';

class BooksService {
  FirebaseFirestore firestore;
  DocumentSnapshot lastBook;

  BooksService(this.firestore);

  // fetch books
  Stream<List<Book>> fetchBooks(int pageSize) {
    return firestore
        .collection('books')
        .orderBy('year', descending: true)
        .limit(pageSize)
        .snapshots()
        .map(
      (list) {
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
    return books.docs
        .map((document) => Book.fromFirestore(document))
        .toList();
  }

  // Search books by title
  Future<List<Book>> searchBooksByTitle(String title) async {
    final books = await firestore
        .collection('books')
        .orderBy('year', descending: true)
        .where('title', arrayContains: title)
        .get();
    
    return books.docs
      .map((document) => Book.fromFirestore(document))
      .toList();
  }

  // add deal to a spesific book
  Future<void> addDeal({@required Deal deal, @required String id}){
    return firestore
        .collection('books')
        .doc(deal.bookIsbn)
        .collection('deals')
        .doc(id)
        .set(deal.toMap(), SetOptions(merge: true));
  }

  // delete a deal
  Future<void> deleteDeal(String bookIsbn, String id){
    return firestore
        .collection('books')
        .doc(bookIsbn)
        .collection('deals')
        .doc(id)
        .delete();
  }

  // get a new deal id
  String getDealId(String isbn) {
    return firestore
        .collection('books')
        .doc(isbn)
        .collection('deals')
        .doc()
        .id;
  }

  // get deals
  Stream<List<Deal>> fetchDeals(String isbn) {
    return firestore
        .collection('books/' + isbn + '/deals')
        .orderBy('price')
        //.limit(pageSize)
        .snapshots()
        .map(
      (list) {
        return list.docs
            .map((document) => Deal.fromFirestore(document))
            .toList();
      },
    );
  }
}
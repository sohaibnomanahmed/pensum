import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'models/book.dart';
import '../deals/models/deal.dart';

class BooksService {
  FirebaseFirestore firestore;
  DocumentSnapshot lastBook;
  DocumentSnapshot lastDeal;

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

  // Search books by title
  Future<List<Book>> searchBooksByTitle(String title) async {
    final books = await firestore
        .collection('books')
        .orderBy('year', descending: true)
        .where('title', arrayContains: title)
        .get();

    return books.docs.map((document) => Book.fromFirestore(document)).toList();
  }

  // fetch deals
  Stream<List<Deal>> fetchDeals(
      {@required String isbn, @required int pageSize}) {
    return firestore
        .collection('books/' + isbn + '/deals')
        .orderBy('price')
        .limit(pageSize)
        .snapshots()
        .map(
      (list) {
        if (list.docs.isNotEmpty) {
          lastDeal = list.docs.last;
        }
        return list.docs
            .map((document) => Deal.fromFirestore(document))
            .toList();
      },
    );
  }

  // fetch and return more deals, from current last. If no more deals return null
  Future<List<Deal>> fetchMoreDeals(
      {@required String isbn, @required int pageSize}) async {
    final deals = await firestore
        .collection('books/' + isbn + '/deals')
        .orderBy('price')
        .startAfterDocument(lastDeal)
        .limit(pageSize)
        .get();
    if (deals.docs.isEmpty) {
      return null;
    }
    lastDeal = deals.docs.last;
    return deals.docs.map((document) => Deal.fromFirestore(document)).toList();
  }

  // filter deals for a spesific book
  Future<List<Deal>> filterDeals({
    @required String isbn,
    @required int priceAbove,
    @required int priceBelow,
    @required List<String> places,
    @required String quality,
  }) async {
    var query = firestore
        .collection('books/' + isbn + '/deals')
        .orderBy('price')
        .where('price', isGreaterThanOrEqualTo: priceAbove)
        .where('price', isLessThanOrEqualTo: priceBelow);
    if (quality.isNotEmpty){
      query = query.where('quality', isEqualTo: quality);
    }
    if (places.isNotEmpty){
      query = query.where('place', whereIn: places);
    }  
    // get the deals matching the query
    final deals = await query.get();
    // map the deals to the Deal model
    return deals.docs.map((doc) => Deal.fromFirestore(doc)).toList();
  }

  // get a new deal id
  String getDealId(String isbn) {
    return firestore.collection('books').doc(isbn).collection('deals').doc().id;
  }

  // add deal to a spesific book
  Future<void> addDeal({@required Deal deal, @required String id}) {
    return firestore
        .collection('books')
        .doc(deal.bookIsbn)
        .collection('deals')
        .doc(id)
        .set(deal.toMap(), SetOptions(merge: true));
  }

  // delete a deal
  Future<void> deleteDeal({@required String isbn, @required String id}) {
    return firestore
        .collection('books')
        .doc(isbn)
        .collection('deals')
        .doc(id)
        .delete();
  }
}

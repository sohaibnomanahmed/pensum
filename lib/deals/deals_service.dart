import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'models/deal.dart';
import 'models/deal_filter.dart';

class DealsService {
  FirebaseFirestore firestore;
  DocumentSnapshot lastDeal;
  DocumentSnapshot lastFilteredDeal;

  DealsService(this.firestore);

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
  Stream<List<Deal>> filterDeals({
    @required String isbn,
    @required int priceAbove,
    @required int priceBelow,
    @required List<String> places,
    @required String quality,
    @required int pageSize,
  }) {
    var query = firestore
        .collection('books/' + isbn + '/deals')
        .orderBy('price')
        .where('price', isGreaterThanOrEqualTo: priceAbove)
        .where('price', isLessThanOrEqualTo: priceBelow)
        .limit(pageSize);
    if (quality.isNotEmpty) {
      query = query.where('quality', isEqualTo: quality);
    }
    if (places.isNotEmpty) {
      query = query.where('place', whereIn: places);
    }
    // get the deals matching the query
    return query.snapshots().map((list) {
      if (list.docs.isNotEmpty) {
        lastFilteredDeal = list.docs.last;
      }
      // map the deals to the Deal model
      return list.docs.map((doc) => Deal.fromFirestore(doc)).toList();
    });
  }

  // fetch and return more filtered deals, from current last. If no more deals return null
  Future<List<Deal>> fetchMoreFilteredDeals({
    @required String isbn,
    @required int pageSize,
    @required DealFilter dealFilter,
  }) async {
    var query = await firestore
        .collection('books/' + isbn + '/deals')
        .orderBy('price')
        .startAfterDocument(lastFilteredDeal)
        .where('price', isGreaterThanOrEqualTo: dealFilter.priceAbove)
        .where('price', isLessThanOrEqualTo: dealFilter.priceBelow)
        .limit(pageSize);
    if (dealFilter.quality.isNotEmpty) {
      query = query.where('quality', isEqualTo: dealFilter.quality);
    }
    if (dealFilter.places.isNotEmpty) {
      query = query.where('place', whereIn: dealFilter.places);
    }
    // get the deals matching the query
    final deals = await query.get();
    // map the deals to the Deal model
    if (deals.docs.isEmpty) {
      return null;
    }
    lastFilteredDeal = deals.docs.last;
    return deals.docs.map((document) => Deal.fromFirestore(document)).toList();
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
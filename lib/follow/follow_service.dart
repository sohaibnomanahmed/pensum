import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../books/models/book.dart';

class FollowService{
  final FirebaseFirestore firestore;

  const FollowService(this.firestore);

  // follow to a spesific book
  Future<void> followBook({@required String uid, @required Book book}) {
    return firestore
        .collection('following')
        .doc(uid)
        .collection('books')
        .doc(book.isbn)
        .set(book.toMap(), SetOptions(merge: true));
  }

  // get following status stream
  Stream<bool> followStatus({@required String uid, @required String isbn}){
    return firestore
        .collection('following')
        .doc(uid)
        .collection('books')
        .doc(isbn).snapshots().map((doc) => doc.exists);   
  }

  
}
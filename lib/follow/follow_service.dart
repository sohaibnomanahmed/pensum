import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'models/Follow.dart';

class FollowService{
  final FirebaseFirestore firestore;
  DocumentSnapshot lastFollow;
  DocumentSnapshot lastNotification;

  FollowService(this.firestore);

  // fetch follows
  Stream<List<Follow>> fetchFollows(
      {@required String uid, @required int pageSize}) {
    return firestore
        .collection('following')
        .doc(uid)
        .collection('books')
        .orderBy('time')
        .limit(pageSize)
        .snapshots()
        .map(
      (list) {
        if (list.docs.isNotEmpty) {
          lastFollow = list.docs.last;
        }
        return list.docs
            .map((document) => Follow.fromFirestore(document))
            .toList();
      },
    );
  }

  // fetch and return more follows, from current last. If no more follows return null
  Future<List<Follow>> fetchMoreFollows(
      {@required String uid, @required int pageSize}) async {
    final follows = await firestore
        .collection('following')
        .doc(uid)
        .collection('books')
        .orderBy('time')
        .startAfterDocument(lastFollow)
        .limit(pageSize)
        .get();
    if (follows.docs.isNotEmpty) {
      lastFollow = follows.docs.last;
    }
    return follows.docs.map((document) => Follow.fromFirestore(document)).toList();
  }

  // follow to a spesific book
  Future<void> followBook({@required String uid, @required Follow follow}) {
    return firestore
        .collection('following')
        .doc(uid)
        .collection('books')
        .doc(follow.id)
        .set(follow.toMap(), SetOptions(merge: true));
  }

  // get following status stream
  Stream<bool> getBookFollowStatus({@required String uid, @required String isbn}){
    return firestore
        .collection('following')
        .doc(uid)
        .collection('books')
        .doc(isbn).snapshots().map((doc) => doc.exists);   
  }

  // remove a follow
  Future<void> removeBookFollow({@required String uid, @required String isbn}) {
    return firestore
        .collection('following')
        .doc(uid)
        .collection('books')
        .doc(isbn)
        .delete();
  }


  
}
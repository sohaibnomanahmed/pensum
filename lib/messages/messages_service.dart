import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'models/message.dart';
import 'models/recipient.dart';

class MessagesService {
  final FirebaseFirestore firestore;
  DocumentSnapshot lastMessage;

  MessagesService(this.firestore);

  // fetch messages
  Stream<List<Message>> fetchMessages({
    @required int pageSize,
    @required String sid,
    @required String rid,
  }) {
    return firestore
        .collection('chats')
        .doc(sid)
        .collection('recipients')
        .doc(rid)
        .collection('messages')
        .orderBy('time', descending: true)
        .limit(pageSize)
        .snapshots()
        .map(
      (list) {
        if (list.docs.isEmpty) {
          return null;
        }
        lastMessage = list.docs.last;
        return list.docs
            .map((document) => Message.fromFirestore(document))
            .toList();
      },
    );
  }

  // fetch more messages
  Future<List<Message>> fetchMoreMessages({
    @required int pageSize,
    @required String sid,
    @required String rid,
  }) async {
    final messages = await firestore
        .collection('chats')
        .doc(sid)
        .collection('recipients')
        .doc(rid)
        .collection('messages')
        .orderBy('time', descending: true)
        .startAfterDocument(lastMessage)
        .limit(pageSize)
        .get();
    if (messages.docs.isEmpty) {
      return null;
    }
    lastMessage = messages.docs.last;

    return messages.docs
        .map((document) => Message.fromFirestore(document))
        .toList();
  }

  // send message
  Future<void> sendMessage({
    @required String sid,
    @required String rid,
    @required Message message,
    @required Recipient recipient,
  }) async {
    // store message info for the sender
    await firestore
        .collection('chats')
        .doc(sid)
        .collection('recipients')
        .doc(rid)
        .set(recipient.toMap(), SetOptions(merge: true));
    // store message for sender
    await firestore
        .collection('chats')
        .doc(sid)
        .collection('recipients')
        .doc(rid)
        .collection('messages')
        .add(message.toMap());
  }

  // set seen value for a message, located at the recipient
  Future<void> setSeen({
    @required String id, // message id
    @required String sid,
    @required String rid,
    @required Map message,
  }) {
    return firestore
        .collection('chats')
        .doc(rid)
        .collection('recipients')
        .doc(sid)
        .collection('messages')
        .doc(id)
        .set(message, SetOptions(merge: true));
  }
}

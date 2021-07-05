import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/message.dart';
import 'models/recipient.dart';

class MessagesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late DocumentSnapshot _lastMessage;

  /// fetch messages, sometimes fetches old messaes then the 10 new,
  /// this will make the ordering wrong as if there was 13 new the 3 wont 
  /// be shown in correct position.
  Stream<List<Message>> fetchMessages({
    required int pageSize,
    required String sid,
    required String rid,
  }) {
    return _firestore
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
        if (list.docs.isNotEmpty) {
          _lastMessage = list.docs.last;
        }
        return list.docs
            .map((document) => Message.fromFirestore(document))
            .toList();
      },
    );
  }

  /// fetch more messages
  Future<List<Message>> fetchMoreMessages({
    required int pageSize,
    required String sid,
    required String rid,
  }) async {
    final messages = await _firestore
        .collection('chats')
        .doc(sid)
        .collection('recipients')
        .doc(rid)
        .collection('messages')
        .orderBy('time', descending: true)
        .startAfterDocument(_lastMessage)
        .limit(pageSize)
        .get();
    if (messages.docs.isNotEmpty) {
      _lastMessage = messages.docs.last;
    }
    return messages.docs
        .map((document) => Message.fromFirestore(document))
        .toList();
  }

  /// send message:, info is stored for the sender the receiver get data from cloud fucntions
  Future<void> sendMessage({
    required String sid,
    required String rid,
    required Message message,
    required Recipient recipient,
  }) async {
    // store message info for the sender
    await _firestore
        .collection('chats')
        .doc(sid)
        .collection('recipients')
        .doc(rid)
        .set(recipient.toMap(), SetOptions(merge: true));
    // store message for sender
    await _firestore
        .collection('chats')
        .doc(sid)
        .collection('recipients')
        .doc(rid)
        .collection('messages')
        .add(message.toMap());
  }

  /// set seen value for a message, located at the recipient
  Future<void> setSeen({
    required String id, // message id
    required String sid,
    required String rid,
    required Map<String, bool> message,
  }) {
    return _firestore
        .collection('chats')
        .doc(rid)
        .collection('recipients')
        .doc(sid)
        .collection('messages')
        .doc(id)
        .set(message, SetOptions(merge: true));
  }
}

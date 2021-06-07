import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/message.dart';
import 'models/recipient.dart';

class MessagesService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late DocumentSnapshot lastMessage;

  /// fetch messages, sometimes fetches old messaes then the 10 new,
  /// this will make the ordering wrong as if there was 13 new the 3 wont 
  /// be shown in correct position.
  Stream<List<Message>> fetchMessages({
    required int pageSize,
    required String sid,
    required String rid,
  }) {
    print('Original messages');
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
        if (list.docs.isNotEmpty) {
          lastMessage = list.docs.last;
          print('last: ${lastMessage['text']}');
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
    print('Fetch more:');
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
    if (messages.docs.isNotEmpty) {
      print('start from: ${lastMessage['text']}');
      lastMessage = messages.docs.last;
      print('new last: ${lastMessage['text']}');
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

  /// set seen value for a message, located at the recipient
  Future<void> setSeen({
    required String id, // message id
    required String sid,
    required String rid,
    required Map<String, bool> message,
  }) {
    print('updating seen');
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

import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/recipient.dart';

class RecipientsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late DocumentSnapshot _lastRecipient;

  /// fetch recipients
  Stream<List<Recipient>> fetchRecipients({
    required String sid,
    required int pageSize,
  }) {
    return _firestore
        .collection('chats')
        .doc(sid)
        .collection('recipients')
        .orderBy('time', descending: true)
        .limit(pageSize)
        .snapshots()
        .map(
      (list) {
        if (list.docs.isNotEmpty) {
          _lastRecipient = list.docs.last;
        }
        return list.docs
            .map((document) => Recipient.fromFirestore(document))
            .toList();
      },
    );
  }

  /// fetch more recipients
  Future<List<Recipient>> fetchMoreRecipients({
    required String sid,
    required int pageSize,
  }) async {
    final recipients = await _firestore
        .collection('chats')
        .doc(sid)
        .collection('recipients')
        .orderBy('time', descending: true)
        .startAfterDocument(_lastRecipient)
        .limit(pageSize)
        .get();
    if (recipients.docs.isNotEmpty) {
      _lastRecipient = recipients.docs.last;
    }
    return recipients.docs
        .map((document) => Recipient.fromFirestore(document))
        .toList();
  }

  /// set seen value for a recipient, since they need to know if you have seen their message
  Future<void> setNotification({
    required String sid,
    required String rid,
    required Map<String, bool> recipient,
  }) {
    return _firestore
        .collection('chats')
        .doc(sid)
        .collection('recipients')
        .doc(rid)
        .set(recipient, SetOptions(merge: true));
  }
}

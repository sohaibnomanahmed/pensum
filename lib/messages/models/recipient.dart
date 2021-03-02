import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Recipient {
  final String id;
  final String rid;
  final String receiverImage;
  final String receiverName;
  final String lastMessage;
  final Timestamp time;
  bool seen;

  Recipient({
    @required this.rid,
    @required this.receiverImage,
    @required this.receiverName,
    @required this.lastMessage,
    @required this.time,
    @required this.seen,
    this.id,
  });

  factory Recipient.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    if (data == null) {
      return null;
    }
    final String rid = data['rid'];
    final String receiverName = data['receiverName'];
    final String receiverImage = data['receiverImage'];
    final String lastMessage = data['lastMessage'];
    final Timestamp time = data['time'];
    final bool seen = data['seen'];
    return Recipient(
        rid: rid,
        receiverImage: receiverImage,
        receiverName: receiverName,
        lastMessage: lastMessage,
        time: time,
        seen: seen,
        id: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'rid': rid,
      'receiverName': receiverName,
      'receiverImage': receiverImage,
      'lastMessage': lastMessage,
      'time': time,
      'seen': seen,
    };
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(covariant Recipient other) => other.id == id;
}

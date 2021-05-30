import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Recipient {
  final String id;
  final String rid;
  final String receiverImage;
  final String receiverName;
  final String lastMessage;
  final Timestamp time;
  bool notification;

  Recipient({
    @required this.rid,
    @required this.receiverImage,
    @required this.receiverName,
    @required this.lastMessage,
    @required this.time,
    @required this.notification,
    this.id,
  });

  factory Recipient.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    if (data == null) {
      return null;
    }
    final String rid = data['rid'];
    final String receiverName = data['receiverName'] ?? 'Leaf User';
    final String receiverImage = data['receiverImage'];
    final String lastMessage = data['lastMessage'];
    final Timestamp time = data['time'];
    final bool notification = data['notification'];

    if (
        rid == null ||
        time == null ||
        lastMessage == null ||
        notification == null 
     ){
      return null;
    }
    return Recipient(
        rid: rid,
        receiverImage: receiverImage,
        receiverName: receiverName,
        lastMessage: lastMessage,
        time: time,
        notification: notification,
        id: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'rid': rid,
      'receiverName': receiverName,
      'receiverImage': receiverImage,
      'lastMessage': lastMessage,
      'time': time,
      'notification': notification,
    };
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(covariant Recipient other) => other.id == id;
}

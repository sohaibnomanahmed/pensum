import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Message {
  final String id;
  final String sid; // sender id
  final String rid; // receiver id
  final String text;
  final Timestamp time;
  final String type;
  bool seen;
  bool isMe;

  Message({
    @required this.sid,
    @required this.rid,
    @required this.text,
    @required this.time,
    @required this.type,
    @required this.seen,
    this.id,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    if (data == null) {
      return null;
    }
    final String text = data['text'];
    final String sid = data['sid'];
    final String rid = data['rid'];
    final Timestamp time = data['time'];
    final String type = data['type'];
    final bool seen = data['seen'];
    return Message(
        text: text,
        sid: sid,
        rid: rid,
        time: time,
        type: type,
        seen: seen,
        id: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'time': time,
      'sid': sid,
      'rid': rid,
      'type': type,
      'seen': seen,
    };
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(covariant Message other) => other.id == id;
}

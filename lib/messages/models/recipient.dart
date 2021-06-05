import 'package:cloud_firestore/cloud_firestore.dart';

class Recipient {
  final String rid;
  final String receiverImage;
  final String receiverName;
  final String lastMessage;
  final Timestamp time;
  bool notification;

  Recipient({
    required this.rid,
    required this.receiverImage,
    required this.receiverName,
    required this.lastMessage,
    required this.time,
    required this.notification,
  });

  factory Recipient.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw 'Error creating Recipient from null value';
    }
    final String? rid = data['rid'];
    final String? receiverName = data['receiverName'];
    final String? receiverImage = data['receiverImage'];
    final String? lastMessage = data['lastMessage'];
    final Timestamp? time = data['time'];
    final bool? notification = data['notification'];

    if (
        rid == null ||
        receiverName == null ||
        receiverImage == null ||
        time == null ||
        lastMessage == null ||
        notification == null 
     ){
      throw 'Error creating Recipient from null value';
    }
    return Recipient(
        rid: rid,
        receiverImage: receiverImage,
        receiverName: receiverName,
        lastMessage: lastMessage,
        time: time,
        notification: notification);
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
  int get hashCode => rid.hashCode;

  @override
  bool operator ==(covariant Recipient other) => other.rid == rid;
}

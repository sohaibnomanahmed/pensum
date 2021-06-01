import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Message {
  final String id;
  final String sid; // sender id
  final String text;
  final String image;
  final String address;
  final double latitude;
  final double longitude;
  final Timestamp time;
  final String type;
  bool seen;
  bool isMe;

  Message({
    @required this.sid,
    @required this.text,
    @required this.image,
    @required this.address,
    @required this.latitude,
    @required this.longitude,
    @required this.time,
    @required this.type,
    @required this.seen,
    this.id,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    if (data == null) {
      throw 'Error creating Message from null value';
    }
    final String text = data['text'];
    final String sid = data['sid'];
    final String image = data['image'];
    final String address = data['address'];
    final double latitude = data['latitude'];
    final double longitude = data['longitude'];
    final Timestamp time = data['time'];
    final String type = data['type'];
    final bool seen = data['seen'];

    if (
        sid == null ||
        time == null ||
        type == null ||
        seen == null 
     ){
      throw 'Error creating Message from null value';
    }

    return Message(
      text: text,
      sid: sid,
      image: image,
      address: address,
      latitude: latitude,
      longitude: longitude,
      time: time,
      type: type,
      seen: seen,
      id: doc.id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'time': time,
      'sid': sid,
      'image': image,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'type': type,
      'seen': seen,
    };
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(covariant Message other) => other.id == id;
}

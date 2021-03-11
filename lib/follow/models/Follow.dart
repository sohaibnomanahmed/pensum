import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Follow {
  final String id;
  final String title;
  final String image;
  final String year;
  final Timestamp time;
  final bool notification;

  const Follow({
    @required this.id,
    @required this.title,
    @required this.image,
    @required this.year,
    @required this.time,
    @required this.notification,
  });

  factory Follow.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    if (data == null) {
      return null;
    }
    final String title = data['title'];
    final String image = data['image'];
    final String year = data['year'];
    final Timestamp time = data['time'];
    final bool notification = data['notification'];
    return Follow(
      title: title,
      image: image,
      year: year,
      time: time,
      notification: notification,
      id: doc.id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'image': image,
      'year': year,
      'time': time,
      'notification': notification,
    };
  }
}

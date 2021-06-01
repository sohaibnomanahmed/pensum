import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Follow {
  final String pid;
  final String title;
  final String image;
  final String year;
  final Timestamp time;
  final bool notification;

  const Follow({
    @required this.pid,
    @required this.title,
    @required this.image,
    @required this.year,
    @required this.time,
    @required this.notification,
  });

  factory Follow.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    if (data == null) {
      throw 'Error creating Follow from null value';
    }
    final String pid = data['pid'];
    final String title = data['title'];
    final String image = data['image'];
    final String year = data['year'];
    final Timestamp time = data['time'];
    final bool notification = data['notification'];

    if (
        pid == null ||
        title == null ||
        image == null ||
        year == null ||
        time == null ||
        notification == null
     ){
      throw 'Error creating Follow from null value';
    }

    return Follow(
      pid: pid,
      title: title,
      image: image,
      year: year,
      time: time,
      notification: notification,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pid': pid,
      'title': title,
      'image': image,
      'year': year,
      'time': time,
      'notification': notification,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/*
 * The deal class restores the inforamtion it needs from the user and the book
 * this is done, since if received from firebase we need mutiple calls, more
 * document reads, but worse we need stream every where to catch changes.
 * In this case we store all the infromation needed and updates the info by cloud functions
 * Also by storing object like Profile and Book, needs to map them from map and document
 * this solution seemed more effetient
 */
class Deal {
  final String id;
  final String userId;
  final String userImage;
  final String userName;
  final String bookIsbn;
  final String bookImage;
  final String bookTitle;
  final String price;
  final String quality;
  final String place;
  final String description;
  final Timestamp time;

  Deal({
    @required this.id,
    @required this.userId,
    @required this.userImage,
    @required this.userName,
    @required this.bookIsbn,
    @required this.bookImage,
    @required this.bookTitle,
    @required this.price,
    @required this.quality,
    @required this.place,
    @required this.description,
    @required this.time,
  });

  factory Deal.fromMap(Map data, String id) {
    final String userId = data['userId'];
    final String userImage = data['userImage'];
    final String userName = data['userName'];
    final String bookIsbn = data['bookIsbn'];
    final String bookImage = data['bookImage'];
    final String bookTitle = data['bookTitle'];
    final String price = data['price'];
    final String quality = data['quality'];
    final String place = data['place'];
    final String description = data['description'];
    final Timestamp time = data['time'];

    return Deal(
      id: id,
      userId: userId,
      userImage: userImage,
      userName: userName,
      bookIsbn: bookIsbn,
      bookImage: bookImage,
      bookTitle: bookTitle,
      price: price,
      quality: quality,
      place: place,
      description: description,
      time: time,
    );
  }

  factory Deal.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    if (data == null) {
      return null;
    }
    return Deal.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userImage': userImage,
      'userName': userName,
      'bookIsbn': bookIsbn,
      'bookImage': bookImage,
      'bookTitle': bookTitle,
      'price': price,
      'quality': quality,
      'place': place,
      'description': description,
      'time': time,
    };
  }
}

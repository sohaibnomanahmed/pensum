import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Deal {
  final String documentId;
  final String bookIsbn;
  final String userId;
  final String userImage;
  final String userName;
  final String bookImage;
  final String bookTitle;
  final int price;
  final String quality;
  final String place;
  final String description;
  final Timestamp time;

  static List<String> qualities = [
    'Ny',
    'Litt brukt',
    'Brukt',
    'Veldig mye brukt',
  ];

  static List<String> places = [
    'Ålesund',
    'Arendal',
    'Bærum',
    'Bergen',
    'Fana',
    'Bodø',
    'Drammen',
    'Fredrikstad',
    'Halden',
    'Hamar',
    'Hammerfest',
    'Haugesund',
    'Kabelvåg',
    'Kristiansand',
    'Kristiansund',
    'Lillehammer',
    'Molde',
    'Moss',
    'Narvik',
    'Oslo',
    'Porsgrunn',
    'Ringsaker',
    'Sandefjord',
    'Sandnes',
    'Skien',
    'Stavanger',
    'Steinkjer',
    'Svolvær',
    'Tønsberg',
    'Tromsø',
    'Trondheim',
    'Vadsø',
  ];

  static List<dynamic> get prices {
    final priceValues = [];
    for (var i = 0; i < 3050; i += 50) {
      priceValues.add(i.toString());
    }
    return priceValues;
  }

  Deal({
    this.documentId,
    @required this.bookIsbn,
    @required this.userId,
    @required this.userImage,
    @required this.userName,
    @required this.bookImage,
    @required this.bookTitle,
    @required this.price,
    @required this.quality,
    @required this.place,
    @required this.description,
    @required this.time,
  });

  factory Deal.fromMap(Map data, String isbn) {
    final String bookIsbn = data['bookIsbn'];
    final String userId = data['userId'];
    final String userImage = data['userImage'];
    final String userName = data['userName'];
    final String bookImage = data['bookImage'];
    final String bookTitle = data['bookTitle'];
    final int price = data['price'];
    final String quality = data['quality'];
    final String place = data['place'];
    final String description = data['place'];
    final Timestamp time = data['time'];

    return Deal(
      documentId: isbn,
      bookIsbn: bookIsbn,
      userId: userId,
      userImage: userImage,
      userName: userName,
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
      'bookIsbn': bookIsbn,
      'userId': userId,
      'userImage': userImage,
      'userName': userName,
      'bookImage': bookImage,
      'bookTitle': bookTitle,
      'price': price,
      'quality': quality,
      'place': place,
      'description' : description,
      'time': time,
    };
  }
}

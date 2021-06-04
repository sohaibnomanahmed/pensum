import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/price_data.dart';

/// The deal class stores the inforamtion it needs from the user and the book class
/// this is done, since if received from [firebase] we need mutiple calls, more
/// document reads, but worse we need stream every where to catch changes.
/// In this case we store all the infromation needed and updates the info by [cloud functions]
/// Also by storing object like [Profile] and [Book], needs to map them from map and document
/// and change the design if not we get reccurrent storing: deals -> profile -> deals etc..
class Deal {
  final String id;
  final String uid; // user id
  final String userImage;
  final String userName;
  final String pid; // product id
  final String productImage;
  final String productTitle;
  final String price;
  final String quality;
  final String place;
  final String description;
  final Timestamp time;

  Deal({
    @required this.id,
    @required this.uid,
    @required this.userImage,
    @required this.userName,
    @required this.pid,
    @required this.productImage,
    @required this.productTitle,
    @required this.price,
    @required this.quality,
    @required this.place,
    @required this.description,
    @required this.time,
  });

  factory Deal.fromMap(Map data, String id) {
    final String uid = data['uid'];
    final String userImage = data['userImage'];
    final String userName = data['userName'];
    final String pid = data['pid'];
    final String productImage = data['productImage'];
    final String productTitle = data['productTitle'];
    final String quality = data['quality'];
    final String place = data['place'];
    final String description = data['description'];
    final Timestamp time = data['time'];

    if (uid == null ||
        userImage == null ||
        userName == null ||
        pid == null ||
        productImage == null ||
        productTitle == null ||
        data['price'] == null ||
        quality == null ||
        place == null ||
        description == null ||
        time == null) {
      throw 'Error creating Deal from null value';
    }

    // data on firestore is int, need to be converted
    var price = prices.first;
    if (data['price'] != 0) {
      price = data['price'].toString() + ' kr';
    }

    return Deal(
      id: id,
      uid: uid,
      userImage: userImage,
      userName: userName,
      pid: pid,
      productImage: productImage,
      productTitle: productTitle,
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
      throw 'Error creating Deal from null value';
    }
    return Deal.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    // store the price as int, so it can be ordered on firebase
    var convertedPrice = 0;
    if (price != prices.first) {
      // remove the ' kr' part from the string
      convertedPrice = int.parse(price.replaceAll(RegExp('[^0-9]'), ''));
    }
    return {
      'uid': uid,
      'userImage': userImage,
      'userName': userName,
      'pid': pid,
      'productImage': productImage,
      'productTitle': productTitle,
      'price': convertedPrice,
      'quality': quality,
      'place': place,
      'description': description,
      'time': time,
    };
  }
}

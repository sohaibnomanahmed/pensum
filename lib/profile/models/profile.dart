import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:leaf/deals/models/deal.dart';

import '../../global/extensions.dart';

class Profile {
  final String uid;
  DateTime creationTime;
  String firstname;
  String lastname;
  String imageUrl;
  Map<String, dynamic> userItems;
  bool isMe;

  // getters
  String get fullName => firstname + ' ' + lastname;
  List<Deal> get deals => userItems.isEmpty
      ? []
      : userItems
          .map((isbn, deal) => MapEntry(isbn, Deal.fromMap(deal, isbn)))
          .values
          .toList();

  /*
   *  need to capitalize first value (value) all other values (element) and
   *  a single value (value returned from reduce) 
   */
  static String capitalizaName(String name) {
    return name.trim()
        .toLowerCase()
        .split(RegExp('\\s+'))
        .reduce(
            (value, element) => value.capitalize() + ' ' + element.capitalize())
        .capitalize();
  }

  Profile({
    @required this.uid,
    @required this.creationTime,
    @required this.firstname,
    @required this.lastname,
    @required this.imageUrl,
    @required this.userItems,
  }) {
    firstname = capitalizaName(firstname);
    lastname = capitalizaName(lastname);
  }

  factory Profile.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    if (data == null) {
      throw 'Error creating Profile from null value';
    }
    final String firstname = data['firstname'];
    final String lastname = data['lastname'];
    final String imageUrl = data['imageUrl'];
    final Timestamp creationTime = data['creationTime'];
    final Map<String, dynamic> userItems = data['userItems'];
    
    if (firstname == null ||
        lastname == null ||
        imageUrl == null ||
        creationTime == null ||
        userItems == null) {
      throw 'Error creating Profile from null value';
    }

    return Profile(
      uid: doc.id,
      creationTime: creationTime.toDate(),
      firstname: firstname,
      lastname: lastname,
      imageUrl: imageUrl,
      userItems: userItems,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'creationTime': creationTime,
      'firstname': firstname,
      'lastname': lastname,
      'imageUrl': imageUrl,
      'userItems': userItems,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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
    @required String firstname,
    @required String lastname,
    @required this.imageUrl,
    @required this.userItems,
  }) {
    this.firstname = capitalizaName(firstname);
    this.lastname = capitalizaName(lastname);
  }

  factory Profile.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    if (data == null) {
      return null;
    }
    final String firstnameData = data['firstname'];
    final String lastnameData = data['lastname'];
    final String imageUrlData = data['imageUrl'];
    final Timestamp creationTime = data['creationTime'];
    final Map<String, dynamic> userItemsData = data['userItems'];
    return Profile(
      uid: doc.id,
      creationTime: creationTime.toDate(),
      firstname: firstnameData,
      lastname: lastnameData,
      imageUrl: imageUrlData,
      userItems: userItemsData,
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

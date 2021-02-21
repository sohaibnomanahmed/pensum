import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../global/extensions.dart';

class Profile {
  final String uid;
  String firstname;
  String lastname;
  String imageUrl;
  Map<String, dynamic> userItems;
  bool isMe;

  /*
   *  need to capitalize first value (value) all other values (element) and
   *  a single value (value returned from reduce) 
   */
  String get fullName =>
      firstname
          .split(RegExp('\\s+'))
          .reduce((value, element) => value.capitalize() + ' ' + element.capitalize()).capitalize() +
      ' ' +
      lastname
          .split(RegExp('\\s+'))
          .reduce((value, element) => value.capitalize() + ' ' + element.capitalize()).capitalize();

  Profile({
    @required this.uid,
    @required this.firstname,
    @required this.lastname,
    @required this.imageUrl,
    @required this.userItems,
  });

  factory Profile.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    if (data == null) {
      return null;
    }
    final String firstnameData = data['firstname'];
    final String lastnameData = data['lastname'];
    final String imageUrlData = data['imageUrl'];
    final Map<String, dynamic> userItemsData = data['userItems'];
    return Profile(
      uid: doc.id,
      firstname: firstnameData,
      lastname: lastnameData,
      imageUrl: imageUrlData,
      userItems: userItemsData,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstname': firstname,
      'lastname': lastname,
      'imageUrl': imageUrl,
      'userItems': userItems,
    };
  }
}

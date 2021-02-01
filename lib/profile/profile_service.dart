import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:leaf/profile/models/profile.dart';

class ProfileService {
  FirebaseFirestore firestore;

  ProfileService(this.firestore);

  // set profile data
  Future<void> setProfile({@required String uid, @required Profile profile}) {
    return firestore
        .collection('profiles')
        .doc(uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }
}
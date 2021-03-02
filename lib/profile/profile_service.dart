import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:leaf/profile/models/profile.dart';

class ProfileService {
  final FirebaseFirestore firestore;

  const ProfileService(this.firestore);

  // set profile data
  Future<void> setProfile({@required String uid, @required Profile profile}) {
    return firestore
        .collection('profiles')
        .doc(uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }

  // get profile data 
  Future<Profile> getProfile(String uid) async {
    final profile = await firestore.collection('profiles').doc(uid).get();
    return Profile.fromFirestore(profile);
  }

  // get profile stream
  Stream<Profile> fetchProfile(String uid){
    return firestore
        .collection('profiles')
        .doc(uid)
        .snapshots()
        .map((profile) => Profile.fromFirestore(profile));
  }

  // deletes a deal from the profile
  Future<void> deleteDeal({@required String uid, @required String id}) async {
    final profileData = await firestore.collection('profiles').doc(uid).get();
    final profile = Profile.fromFirestore(profileData);
    profile.userItems.remove(id);
    return firestore.collection('profiles').doc(uid).update(profile.toMap());
  }
}
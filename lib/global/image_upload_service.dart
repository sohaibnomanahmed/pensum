import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class ImageUploadService{
  FirebaseStorage firebaseStorage;

  ImageUploadService(this.firebaseStorage);

  Future<String> uploadProfileImage({@required File image, @required String uid}) async {
    final storageReference =
        firebaseStorage.ref().child('profile/' + uid);
    await storageReference.putFile(image);

    final url = await storageReference.getDownloadURL();
    return url;
  }

  Future<String> uploadChatMessageImage(File image) async {
    var uuid = Uuid();
    final storageReference =
        firebaseStorage.ref().child('chat/' + uuid.v4());

    final uploadTask = storageReference.putFile(image);

    // Cancel your subscription when done.
    await uploadTask.whenComplete(() => null);

    final url = await storageReference.getDownloadURL();
    return url;
  }
}
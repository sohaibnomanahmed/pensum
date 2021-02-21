import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

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
}
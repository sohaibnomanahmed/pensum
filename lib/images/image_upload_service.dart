import 'dart:io' as io;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:uuid/uuid.dart';


/// after some debugging the [cache manager] also uses [File] class now and this can be mistaken
/// wiht the dart io [File] class therefere explicit decleration is needed 
class ImageUploadService{
  final _firebaseStorage = FirebaseStorage.instance;
  final _key = 'Network image';

  Future<String> uploadProfileImage({required io.File image, required String uid}) async {
    final storageReference =
        _firebaseStorage.ref().child('profile/' + uid);  
    await storageReference.putFile(image);
    final url = await storageReference.getDownloadURL();
    return url;
  }

  Future<String> uploadChatMessageImage(io.File image) async {
    var uuid = Uuid();
    final storageReference =
        _firebaseStorage.ref().child('chat/' + uuid.v4());

    final uploadTask = storageReference.putFile(image);

    // Cancel your subscription when done.
    await uploadTask.whenComplete(() => null);

    final url = await storageReference.getDownloadURL();
    return url;
  }

  // covert url to file
  Future<File> urlToFile(String url) async {
    var file = await DefaultCacheManager().getSingleFile(url, key: _key);
    return file;
  }

  // remove last downloaded file
  Future<void> deleteLastCachedFile() async {
    await DefaultCacheManager().removeFile(_key);
  }
}
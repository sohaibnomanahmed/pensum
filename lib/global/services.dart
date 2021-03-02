import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:leaf/messages/recipients_service.dart';

import '../messages/messages_service.dart';
import '../deals/deals_service.dart';
import '../books/books_service.dart';
import '../follow/follow_service.dart';
import '../profile/profile_service.dart';
import '../authentication/authentication_service.dart';
import 'image_cropper_service.dart';
import 'image_picker_service.dart';
import 'image_upload_service.dart';

class FirebaseService {
  // init firebase instances
  static final firestore = FirebaseFirestore.instance;
  static final firebaseStorage = FirebaseStorage.instance;
  // init firebase services
  static final authentication = AuthenticationService();
  static final profile = ProfileService(firestore);
  static final books = BooksService(firestore);
  static final deals = DealsService(firestore);
  static final follow = FollowService(firestore);
  static final messages = MessagesService(firestore);
  static final recipients = RecipientsService(firestore);
  static final imageUpload = ImageUploadService(firebaseStorage);
}

class NativeService{
  // init native services
  static final imagePicker = ImagePickerService();
  static final imageCropper = ImageCropperService();
}
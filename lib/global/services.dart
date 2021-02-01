import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:leaf/profile/profile_service.dart';

import '../authentication/authentication_service.dart';

class FirebaseService {
  // init firebase services
  static final firestore = FirebaseFirestore.instance;
  static final authentication = AuthenticationService();
  static final profile = ProfileService(firestore);
  
}

class NativeService{
  // init native services
  // static final imagePicker = ImagePickerService();
  // static final imageCropper = ImageCropperService();
}
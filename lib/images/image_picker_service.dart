import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  /// Picks an image from a choosen source like camera and photo library etc..
  /// [maxWidth] in getImage restricts the size, but has currently an error in 
  /// version 0.8.0+1: on iOS the image is rotated
  Future<File?> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source); //maxWidth: 2000);
    return pickedFile == null ? null : File(pickedFile.path) ;
  }
}

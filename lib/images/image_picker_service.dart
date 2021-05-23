import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {

  Future<File> pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker.pickImage(
      source: source,
      maxWidth: 2000,
    );
    if (pickedImage == null) {
      return null;
    }
    final pickedImageFile = File(pickedImage.path);
    return pickedImageFile;
  }
}

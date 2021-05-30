import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  File _image;
  final picker = ImagePicker();

  Future<File> pickImage(ImageSource source) async {
    final pickedFile = await picker.getImage(source: source, maxWidth: 2000);
    if (pickedFile == null) {
      return null;
    }
    _image = File(pickedFile.path);
    return _image;
  }
}

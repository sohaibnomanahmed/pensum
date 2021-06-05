import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  Future<File?> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: source, maxWidth: 2000);
    return pickedFile == null ? null : File(pickedFile.path) ;
  }
}

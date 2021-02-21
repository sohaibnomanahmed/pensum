import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final picker = ImagePicker();

  Future<File> pickImage(ImageSource source) async {
    final pickedImage = await picker.getImage(
      source: source,
      maxWidth: 250,
    );
    if (pickedImage == null) {
      return null;
    }
    final pickedImageFile = File(pickedImage.path);
    return pickedImageFile;
  }
}

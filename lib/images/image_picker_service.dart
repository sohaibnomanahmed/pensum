import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final picker = ImagePicker();

  Future<File> pickImage(ImageSource source) async {
    // TODO check if not messed up
    final pickedImage = await picker.getImage(
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

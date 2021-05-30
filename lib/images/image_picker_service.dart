import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  Future<File> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: source, maxWidth: 2000);
    if (pickedFile == null) {
      return null;
    }
    final image = File(pickedFile.path);
    print(image.runtimeType);
    return image;
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class ImageCropperService {
  Future<File> pickImage(File image) async {
    var croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9,
        ],
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        cropStyle: CropStyle.circle,
        androidUiSettings: AndroidUiSettings(
          showCropGrid: false,
          cropFrameColor: Color.fromRGBO(0, 0, 0, 0),
          statusBarColor: Color.fromRGBO(0, 0, 0, 0.3),
        ),
        iosUiSettings: IOSUiSettings());
    return croppedFile;
  }
}

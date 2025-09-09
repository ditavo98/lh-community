import 'dart:io';

import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lh_community/src/utils/dialog_util.dart';
import 'package:lh_community/src/utils/res.dart';

Future<XFile?> pickImageByCamera() async {
  final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      requestFullMetadata: true,
      maxWidth: 1920,
      maxHeight: 1080);
  if (image != null) {
    File rotatedImage = await FlutterExifRotation.rotateImage(path: image.path);
    return XFile(rotatedImage.path); //Return the file
  }
  return image;
}

Future<File?> pickVideoByCamera() async {
  final XFile? video = await ImagePicker().pickVideo(
    source: ImageSource.camera,
    maxDuration: const Duration(minutes: 10),
  );
  if (video == null) return null;
  final file = File(video.path);
  final bytes = await file.length();
  final kb = bytes / 1024;
  final mb = kb / 1024;

  if (mb > maxFileSize) {
    AppDialog.showFailedToast(
        msg: cmStr.text_max_file_size(maxFileSize));
    return null;
  }
  return file;
}

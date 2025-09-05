import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fc_native_image_resize/fc_native_image_resize.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lh_community/src/utils/string_ex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:video_compress/video_compress.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class MediaUtil {
  static Future<File?> generateThumbnail(dynamic video) async {
    String videoPath = '';
    if (video is File) {
      videoPath = video.path;
    } else if (video is String) {
      videoPath = video;
    } else if (video is Medium) {
      final file = await video.getFile();
      videoPath = file.path;
    }
    if (videoPath.isNullOrEmpty) return null;
    final String? path = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.PNG,
      quality: 50,
    );
    return File(path ?? '');
  }

  static Future<File> compressFile(
    File file, {
    int quality = 95,
    int minWidth = 1080,
    int minHeight = 1920,
  }) async {
    if (!file.path.isMediaFile()) {
      return file;
    }
    if (file.path.isVideo) {
      var fileSize = file.lengthSync();
      double sizeInMb = fileSize / (1024 * 1024);
      try {
        final info = await VideoCompress.compressVideo(
          file.path,
          quality: VideoQuality.Res1920x1080Quality,
          deleteOrigin: false,
          includeAudio: true,
        ).timeout(Duration(seconds: (sizeInMb * 2).round()));
        return info?.file ?? file;
      } catch (e) {
        return file;
      }
    }

    var result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: quality,
      minWidth: minWidth,
      minHeight: minHeight,
    );

    final tempDir = await getTemporaryDirectory();
    String? name = file.path.split(Platform.pathSeparator).last;
    File data = await File('${tempDir.path}/$name').create();
    data.writeAsBytesSync(result ?? []);
    return data;
  }

  static Future<File> compressList(
    Uint8List bytes, {
    required String path,
    int quality = 95,
    int minWidth = 1080,
    int minHeight = 1920,
  }) async {
    var result = await FlutterImageCompress.compressWithList(
      bytes,
      quality: quality,
      minWidth: minWidth,
      minHeight: minHeight,
    );

    final tempDir = await getTemporaryDirectory();
    String? name = path.split(Platform.pathSeparator).last;
    File data = await File('${tempDir.path}/$name').create();
    data.writeAsBytesSync(result);
    return data;
  }

  static Future<ui.Image> getImage(String url) {
    Completer<ui.Image> completer = Completer<ui.Image>();
    NetworkImage(url)
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((image, synchronousCall) {
      return completer.complete(image.image);
    }));
    return completer.future;
  }

  static Future? saveImage({
    required Uint8List uint8List,
    required Directory dir,
    required String fileName,
  }) async {
    final isDirExist = await Directory(dir.path).exists();
    if (!isDirExist) Directory(dir.path).create();
    final tempPath = '${dir.path}/$fileName';
    final image = File(tempPath);
    final isExist = await image.exists();
    if (isExist) await image.delete();
    return File(tempPath).writeAsBytes(uint8List, flush: true);
  }

  static Future<File?> resizeImage(File? file, {width = 1080}) async {
    try {
      if (file == null) return null;
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().microsecondsSinceEpoch;
      File thumbFile = File('${tempDir.path}/shared_${timestamp}_thumb.png');

      await FcNativeImageResize().resizeFile(
        srcFile: file.path,
        destFile: thumbFile.path,
        width: width,
        height: width,
        keepAspectRatio: true,
        format: 'png',
        quality: 100,
      );

      return thumbFile;
    } catch (_) {}
    return null;
  }

  static Future<File> processImage(
    File inputFile, {
    int width = 1280,
    int? maxSize, //KB
  }) async {
    try {
      if (inputFile.path.isVideo) {
        var fileSize = inputFile.lengthSync();
        double sizeInMb = fileSize / (1024 * 1024);
        try {
          final info = await VideoCompress.compressVideo(
            inputFile.path,
            quality: VideoQuality.Res1920x1080Quality,
            deleteOrigin: false,
            includeAudio: true,
          ).timeout(Duration(seconds: (sizeInMb * 2).round()));
          return info?.file ?? inputFile;
        } catch (e) {
          return inputFile;
        }
      }

      File? outputFile;
      if (inputFile.path.isImage) {
        outputFile = await resizeImage(inputFile, width: width);
      }
      if (outputFile == null) return inputFile;
      if (maxSize == null) return outputFile;

      final targetSizeKB = maxSize;
      File compressedFile = await _compressImage(outputFile, targetSizeKB);
      return compressedFile;
    } catch (e) {
      return inputFile;
    }
  }

  static Future<File> _compressImage(File file, int targetSizeKB) async {
    try {
      int quality = 90; // Start with high quality
      File compressedFile = file;
      int fileSizeKB = (await file.length()) ~/ 1024;
      CompressFormat format = CompressFormat.jpeg;

      if (file.path.endsWith('.jpg') || file.path.endsWith('.jpeg')) {
        format = CompressFormat.jpeg;
      } else if (file.path.endsWith('.png')) {
        format = CompressFormat.png;
      } else if (file.path.endsWith('.webp')) {
        format = CompressFormat.webp;
      } else if (file.path.endsWith('.heic')) {
        format = CompressFormat.heic;
      }

      while (fileSizeKB > targetSizeKB && quality > 50) {
        final tempDir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final tempPath =
            '${tempDir.path}/compressed_$timestamp.${file.path.split('.').last}';

        final cpXFile = await FlutterImageCompress.compressAndGetFile(
          file.path,
          tempPath,
          quality: quality,
          minWidth: 100,
          keepExif: false,
          format: format,
        );
        if (cpXFile == null) {
          break;
        }
        compressedFile = File(cpXFile.path);
        fileSizeKB = (await compressedFile.length()) ~/ 1024;
        quality -= 10; // Reduce quality incrementally
      }

      return compressedFile;
    } catch (_) {
      return file;
    }
  }
}

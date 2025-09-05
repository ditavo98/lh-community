import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lh_community/src/core/api/api_client.dart';
import 'package:lh_community/src/core/di.dart';
import 'package:lh_community/src/core/model/post_dto.dart';
import 'package:lh_community/src/core/model/signed_url/signed_url_dto.dart';
import 'package:lh_community/src/utils/collection_ex.dart';
import 'package:lh_community/src/utils/lh_utils.dart';
import 'package:lh_community/src/utils/loading_screen.dart';
import 'package:lh_community/src/utils/map_ex.dart';
import 'package:lh_community/src/utils/media_util.dart';
import 'package:lh_community/src/utils/string_ex.dart';
import 'package:media_info/media_info.dart';
import 'package:path/path.dart' as p;
import 'package:photo_gallery/photo_gallery.dart';

class CommunityUploadRepository {
  Future<List<CommunityFileElementDto>> uploadMedias(List files) async {
    List<Future<CommunityFileElementDto?>> futures = [];
    for (var f in files) {
      futures.add(_getPresignUrl(f));
    }
    LHLoadingScreen.show();
    final result = await Future.wait(futures);
    LHLoadingScreen.close();
    return result.whereType<CommunityFileElementDto>().toList();
  }

  Future<CommunityFileElementDto?> _getPresignUrl(file) async {
    try {
      String? filename;
      File? uploadFile;
      File? thumbnail;
      bool isVideo = false;
      if (file is Medium) {
        uploadFile = await file.getFile();
        isVideo = file.mediumType == MediumType.video;
      }
      if (file is File) {
        uploadFile = file;
        filename = p.basename(uploadFile.path);
        isVideo = filename.isVideo;
      }
      if (file is XFile) {
        uploadFile = File(file.path);
        filename = p.basename(uploadFile.path);
        isVideo = filename.isVideo;
      }

      List<Future<SignedUrlDto?>> futures = [];
      if (uploadFile == null) return null;
      if (isVideo) {
        thumbnail = await LHUtils.generateThumbnail(uploadFile);
        uploadFile = await MediaUtil.processImage(uploadFile);
        if (thumbnail != null) {
          thumbnail = await MediaUtil.processImage(
            thumbnail,
            width: 640,
          );
        }
      } else {
        thumbnail = await MediaUtil.processImage(
          uploadFile,
          width: 800,
        );
        uploadFile = await MediaUtil.processImage(
          uploadFile,
          width: 1280,
        );
      }
      futures.add(_uploads(uploadFile));
      futures.add(_uploads(thumbnail));

      final uploadFiles = await Future.wait(futures);

      final originalFileData = uploadFiles.firstOrNull;
      final thumbnailFileData = uploadFiles.getOrNull(1);
      if (originalFileData != null) {
        int width, height;
        if (file is Medium) {
          width = file.width ?? 0;
          height = file.height ?? 0;
        } else {
          final info = await getInfo(file);
          height = info.getInt('height');
          width = info.getInt('width');
        }

        String? thumb = thumbnailFileData?.filePath;
        if (!isVideo) {
          thumb ??= originalFileData.filePath;
        }
        return CommunityFileElementDto(
          url: originalFileData.filePath,
          mime: originalFileData.contentType,
          height: height,
          type: isVideo ? "video" : null,
          width: width,
          thumbnailUrl: thumb,
        );
      }
    } catch (_) {}
    return null;
  }

  Future<SignedUrlDto?> _uploads(File? file) async {
    if (file == null) return null;
    final result = await getIt<ApiClient>().presigned(
      data: {'filePath': p.basename(file.path)},
    );
    final data = result.data;
    if (data == null) return null;
    final uploaded = await _uploadCloudflare(
      url: data.signedUrl ?? '',
      file: file,
      contentType: data.contentType,
    );
    if (uploaded) return data;
    return null;
  }

  Future<bool> _uploadCloudflare({
    required String url,
    required File file,
    required String? contentType,
  }) async {
    Uint8List bytes = Uint8List.fromList([]);
    bytes = file.readAsBytesSync();
    if (bytes.isEmpty) {
      return false;
    }
    try {
      final result = await Dio().put(
        url,
        data: Stream.fromIterable(bytes.map((e) => [e])),
        options: Options(
          headers: {
            'Accept': "*/*",
            'Content-Length': bytes.length,
            'Connection': 'keep-alive',
            'User-Agent': 'ClinicPlush',
            'Content-Type': contentType,
          },
        ),
      );
      if (result.statusCode != 200) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}

Future<Map> getInfo(File file) async {
  final info = await MediaInfo().getMediaInfo(file.path);
  return info;
}
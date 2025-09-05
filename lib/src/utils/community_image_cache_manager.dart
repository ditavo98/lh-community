import 'dart:async';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// The AppImageCacheManager that can be easily used directly. The code of
/// this implementation can be used as inspiration for more complex cache
/// managers.

typedef OnPresignedUrlCallBack = Future<String?>? Function(String? url);

class CMImageCacheManager extends CacheManager with ImageCacheManager {
  static const TAG = 'AppImageCacheManager';
  static const key = 'LHCommunityLibCachedImageData';

  static final CMImageCacheManager _instance = CMImageCacheManager._();
  OnPresignedUrlCallBack? getPresignedUrl;
  factory CMImageCacheManager() {
    return _instance;
  }

  CMImageCacheManager._() : super(Config(key));

  void initialize({
    OnPresignedUrlCallBack? getPresignedUrl,
  }) {
    this.getPresignedUrl = getPresignedUrl;
  }

  @override
  Stream<FileResponse> getFileStream(String url,
      {String? key, Map<String, String>? headers, bool withProgress = false}) {
    key ??= url;
    final streamController = StreamController<FileResponse>();
    _pushFileToStream(streamController, url, key, headers, withProgress);
    return streamController.stream;
  }

  Future<void> _pushFileToStream(
    StreamController<dynamic> streamController,
    String url,
    String? key,
    Map<String, String>? headers,
    bool withProgress,
  ) async {
    key ??= url;
    FileInfo? cacheFile;
    try {
      cacheFile = await getFileFromCache(key);
      if (cacheFile != null) {
        streamController.add(cacheFile);
        withProgress = false;
      }
    } on Object catch (e) {
      cacheLogger.log(
          '$TAG: Failed to load cached file for $url with error:\n$e',
          CacheManagerLogLevel.debug);
    }
    if (cacheFile == null || cacheFile.validTill.isBefore(DateTime.now())) {
      try {
        await for (final response
            in webHelper.downloadFile(url, key: key, authHeaders: headers)) {
          if (response is DownloadProgress && withProgress) {
            streamController.add(response);
          }
          if (response is FileInfo) {
            streamController.add(response);
          }
        }
      } on Object catch (e) {
        void cancelAndClose() {
          cacheLogger.log(
              '$TAG: Failed to download file from $url with error:\n$e',
              CacheManagerLogLevel.debug);
          if (cacheFile == null && streamController.hasListener) {
            streamController.addError(e);
          }
        }

        if (getPresignedUrl != null) {
          try {
            final newUrl = await getPresignedUrl?.call(url);
            if ((newUrl ?? '').isEmpty) {
              cancelAndClose();
            } else {
              _pushFileToStream(
                streamController,
                newUrl!,
                key,
                headers,
                withProgress,
              );
              return;
            }
          } catch (presignedError) {
            cacheLogger.log(
              '$TAG: Failed to presigned url from $url with error:\n$presignedError',
              CacheManagerLogLevel.debug,
            );
            cancelAndClose();
          }
        } else {
          cancelAndClose();
        }
      }
    }
    streamController.close();
  }
}

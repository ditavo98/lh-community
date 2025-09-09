import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:lh_community/lh_community.dart';
import 'package:lh_community/src/core/configs.dart';
import 'package:lh_community/src/core/di.dart';
import 'package:path/path.dart' as p;
import 'package:photo_manager/photo_manager.dart';

/// make sure call [init] function before using the SDK
class LHCommunity {
  LHCommunity._();

  static final ins = LHCommunity._();

  factory LHCommunity() {
    return ins;
  }

  /// the user of the partner
  late String userId;
  String? nickname;
  String? avatar;

  /// [apiKey] of the partner
  late String apiKey;

  /// [domain] of the partner
  late String domain;

  String appLanguage = 'kr';

  BuildContext get context => _navigationKey.currentContext!;
  late final GlobalKey _navigationKey;

  List<CMPostTypePartnerData> _partnerData = [];

  List<CMPostTypePartnerData> get postTypePartnerData => _partnerData;
  StreamSubscription? _sub, _sub2;

  void init({
    required String userId,
    required String apiKey,
    required String domain,
    required GlobalKey navigationKey,
    String? nickname,
    String? avatar,
    String env = 'dev',
  }) async {
    this.userId = userId;
    this.apiKey = apiKey;
    this.domain = domain;
    _navigationKey = navigationKey;
    this.nickname = nickname;
    this.avatar = avatar;
    LHConfigs.setEnv(env);
    DependenceInjection.init();
    await CMSharedPreference.initialize();
    CMMultiVideoPlayManager.instance.ensureInitialized();
    await CMDownloader().ensureInitialized();
    PhotoManager.requestPermissionExtend();
    _listener();
  }

  void updateLanguage(String languageCode) {
    appLanguage = languageCode;
  }

  void updatePostType(List<CMPostTypePartnerData> partnerData) {
    _partnerData = partnerData;
    LHEventBus.eventBus.fire(ReloadPostTypeEvent());
  }

  _listener() {
    _sub = CMDownloader()
        .progressDownloadController
        .stream
        .where((event) => event.status == DownloadTaskStatus.running)
        .listen((event) {
      print('progress - ${event.progress} - ${event.taskId}');
    });
    _sub2 = CMDownloader()
        .progressDownloadController
        .stream
        .where((event) => event.status == DownloadTaskStatus.complete)
        .listen(
      (event) {
        CMDownloader().getTask(event.taskId).then(
          (task) async {
            final filePath = '${task?.filename}';
            final filename = p.basename(filePath);
            final isVideo = filename.isVideo;
            final fullPath = '${task?.savedDir}/$filePath';
            if (fullPath.notNullOrEmpty && fullPath.isMediaFile()) {
              try {
                await ImageGallerySaver.saveFile(fullPath);
                File(fullPath).deleteSync();
              } catch (_) {}
            }
            print('Main Screen - filePath - $filePath');
            AppDialog.showSuccessToast(
              msg: isVideo ? cmStr.text_video_saved : cmStr.text_photo_saved,
              leading: Icon(
                Icons.check,
                size: 16,
                color: CMColor.white,
              ),
            );
          },
        );
      },
    );
  }

  void dispose() {
    _sub?.cancel();
    _sub2?.cancel();
  }
}

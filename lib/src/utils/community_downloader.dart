import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';

@pragma('vm:entry-point')
class CMDownloader {
  static const TAG = 'AppDownloader';
  static const flutterDownloaderPort = 'downloader_send_port';
  final StreamController<DownloadProgressInfoModel> progressDownloadController =
      StreamController.broadcast();
  final filePathMethodChannel = const MethodChannel('lh_community');
  final _mainPort = ReceivePort();
  static final instance = CMDownloader._();

  final List<StreamSubscription> _subs = [];

  CMDownloader._();

  factory CMDownloader() {
    return instance;
  }

  Future<void> ensureInitialized() async {
    try {
      if (FlutterDownloader.initialized) {
        return;
      }
      _closeDisposeBag();
      await FlutterDownloader.initialize(
        debug: kDebugMode,
        ignoreSsl: kDebugMode,
      );
      if (IsolateNameServer.lookupPortByName(flutterDownloaderPort) != null) {
        IsolateNameServer.removePortNameMapping(flutterDownloaderPort);
      }
      IsolateNameServer.registerPortWithName(
        _mainPort.sendPort,
        flutterDownloaderPort,
      );
      _subs.add(_mainPort.listen((dynamic data) {
        progressDownloadController.sink.add(DownloadProgressInfoModel(
          taskId: data[0],
          progress: data[2],
          status: _fromStatusValue(data[1]),
        ));
      }));

      FlutterDownloader.registerCallback(downloadCallback);
    } catch (e, s) {
      print('$TAG - ensureInitialized error: $e');
    }
  }

  void dispose() {
    unawaited(progressDownloadController.close());
    _mainPort.close();
    IsolateNameServer.removePortNameMapping(flutterDownloaderPort);
    _closeDisposeBag();
  }

  _closeDisposeBag() {
    for (var s in _subs) {
      s.cancel();
    }
    _subs.clear();
  }

  Future<DownloadTask?> getTask(String? taskId) async {
    final allTask = await FlutterDownloader.loadTasks();
    final query = "SELECT * FROM task WHERE task_id='$taskId'";
    final result = await FlutterDownloader.loadTasksWithRawQuery(
      query: query,
    );
    return (result ?? []).isEmpty ? null : result?.first;
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final send =
        IsolateNameServer.lookupPortByName(CMDownloader.flutterDownloaderPort);
    send?.send([id, status, progress]);
  }

  DownloadTaskStatus _fromStatusValue(int value) {
    switch (value) {
      case 0:
        return DownloadTaskStatus.undefined;
      case 1:
        return DownloadTaskStatus.enqueued;
      case 2:
        return DownloadTaskStatus.running;
      case 3:
        return DownloadTaskStatus.complete;
      case 4:
        return DownloadTaskStatus.failed;
      case 5:
        return DownloadTaskStatus.canceled;
      case 6:
        return DownloadTaskStatus.paused;
      default:
        throw ArgumentError('Invalid value: $value');
    }
  }

  Future<String?> downloadFile({required String urlLink}) async {
    Directory? savedStorage;
    bool saveInPublicStorage = false;
    final url = Uri.parse(urlLink ?? '');
    const attachmentsPath = '/StarTalk/Attachments';
    final fileName = url.pathSegments.last;
    final mineType = lookupMimeType(fileName);
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var sdkInt = androidInfo.version.sdkInt;
      Future<void> getApplicationStorage() async {
        final externalStorage = await getApplicationDocumentsDirectory();
        savedStorage = Directory('${externalStorage.path}$attachmentsPath');
        saveInPublicStorage = true;
      }

      if (sdkInt >= 29) {
        try {
          final result = await filePathMethodChannel.invokeMethod(
            "createFileInPublicDownload",
            {
              "path": attachmentsPath,
              "display_name": DateTime.now().toIso8601String(),
              // "mine_type": mineType ??
              //     'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            },
          );
          final publicFilePath = result['media_store_path'].toString();
          final onlyFolderPath = publicFilePath.replaceAll('/$fileName', "");
          savedStorage = Directory(onlyFolderPath);
        } catch (e) {
          print('$TAG - createFileInPublicDownload - error: $e');
          await getApplicationStorage();
        }
      } else {
        await getApplicationStorage();
      }
    } else {
      final app = await getApplicationDocumentsDirectory();
      savedStorage = Directory('${app.path}$attachmentsPath');
    }
    if (savedStorage == null) {
      return '';
    }
    if (!(await savedStorage!.exists())) {
      await savedStorage!.create(recursive: true);
    }
    final taskId = await FlutterDownloader.enqueue(
      url: urlLink,
      // headers: headers,
      // optional: header send with url (auth  token etc)
      savedDir: savedStorage!.path,
      showNotification: false,
      // show download progress in status bar (for Android)
      openFileFromNotification: false,
      // click on notification to open downloaded file (for Android)
      saveInPublicStorage: saveInPublicStorage,
    );
    return taskId;
  }
}

class DownloadProgressInfoModel {
  final String? taskId;
  final int? progress;
  final DownloadTaskStatus status;

  DownloadProgressInfoModel({
    required this.taskId,
    required this.progress,
    required this.status,
  });

  @override
  String toString() =>
      'DownloadProgressInfoModel(taskId: $taskId, progress: $progress, status: $status)';
}

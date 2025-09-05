import 'dart:io';

import 'package:lh_community/src/core/configs.dart';
import 'package:lh_community/src/utils/string_ex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:intl/intl.dart' as n_format;

class LHUtils {
  static String? getMediaUrl(String? path) {
    try {
      if (path == null) {
        return null;
      }
      if (path.startsWith('http://') == true ||
          path.startsWith('https://') == true) {
        return path;
      }
      if (path.startsWith('/')) {
        return '${LHConfigs.mediaBaseUrl}$path';
      }
      return '${LHConfigs.mediaBaseUrl}/$path';
    } catch (_) {
      return path;
    }
  }


  static Future<File?> generateThumbnail(video) async {
    String videoPath = '';
    if (video is File) {
      videoPath = video.path;
    } else if (video is String) {
      videoPath = video;
    }
    if (videoPath.isNullOrEmpty) return null;
    final String? path = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.WEBP,
      maxWidth: 640,
      quality: 50,
    );
    return File(path ?? '');
  }

  static String getShortValue(num? count) {
    final val = count ?? 0;
    if (val >= 1000) {
      var formattedNumber = n_format.NumberFormat.compactCurrency(
        decimalDigits: 1,
        symbol: '',
      ).format(count);
      return formattedNumber;
    }
    return '${count ?? '0'}';
  }

  static String formattedTime({required int milliseconds}) {
    Duration duration = Duration(milliseconds: milliseconds);
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  static String formatDuration2(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (hours > 0) {
      return "${twoDigits(hours)}:$minutes:$seconds ";
    } else {
      return "$minutes:$seconds";
    }
  }
}
import 'package:mime/mime.dart';

extension StringEx on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  bool get notNullOrEmpty => this != null && this!.isNotEmpty;

  bool get isRemoteUrl {
    if (isNullOrEmpty) return false;
    return this!.startsWith('http://') || this!.startsWith('https://');
  }

  bool get isEmail {
    if (this == null) {
      return false;
    }
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(this!);
  }

  bool get passwordValid {
    return RegExp(r"^(?=.*[0-9])(?=.*[a-zA-Z]).{8,16}$").hasMatch(this ?? '');
  }

  DateTime? localTime() {
    if (isNullOrEmpty) {
      return null;
    }
    return DateTime.tryParse(this!)?.toUtc().toLocal() ?? DateTime.now();
  }

  bool isMediaFile() {
    if (this == null) return false;
    final mimeType = MimeTypeResolver().lookup(this!);
    if (mimeType != null &&
        (mimeType.contains('image') || mimeType.contains('video'))) {
      return true;
    }
    return false;
  }

  String getFileExtension() {
    if (isNullOrEmpty) return '';
    try {
      return '.${(this)!.split('.').last}'.toLowerCase();
    } catch (e) {
      return '';
    }
  }

  bool get isVideo {
    List<String> values = ['.mp4', '.mov'];
    if (values.contains((this).getFileExtension().toLowerCase())) {
      return true;
    } else {
      return false;
    }
  }

  bool get isAudio {
    final mimeType = MimeTypeResolver().lookup(this!);
    if (mimeType != null && mimeType.startsWith('audio/')) {
      return true;
    }
    List<String> values = ['.mp3', '.wav', '.flac', '.aac', '.m4a', '.ogg'];
    if (values.contains((this).getFileExtension().toLowerCase())) {
      return true;
    }
    return false;
  }

  bool get isImage {
    List<String> values = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.webp',
      '.tiff',
      '.bmp'
    ];
    if (values.contains((this).getFileExtension().toLowerCase())) {
      return true;
    } else {
      return false;
    }
  }
}

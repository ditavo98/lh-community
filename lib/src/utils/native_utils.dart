import 'package:device_info_plus/device_info_plus.dart';

class NativeUtil {
  static Future<bool> isAndroidSDK32OrLower() async {
    var androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt <= 32;
  }
}

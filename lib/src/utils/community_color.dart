import 'dart:ui';

import 'package:lh_community/src/utils/string_ex.dart';

class CMColor {
  static Color textColor = Color(0xFF3A3A3C);

  static Color primary1 = Color(0xFFFAF9FF);
  static Color primary2 = Color(0xFFF7F5FF);
  static Color primary3 = Color(0xFFEDE9FF);
  static Color primary4 = Color(0xFFE3DEFF);
  static Color primary5 = Color(0xFF6F52FF);

  static Color grey1 = Color(0xFFF9F9FD);
  static Color grey2 = Color(0xFFF5F7FB);
  static Color grey3 = Color(0xFFE9ECF4);
  static Color greyN3 = Color(0xFFEAEDF4);
  static Color grey4 = Color(0xFFC9D0DC);
  static Color greyN4 = Color(0xFFD7DCE5);
  static Color grey5 = Color(0xFFA1A6B5);
  static Color grey6 = Color(0xFF82879A);
  static Color grey7 = Color(0xFF525263);
  static Color greyN7 = Color(0xFF8491A7);
  static Color grey8 = Color(0xFF3B3B46);

  static Color red9 = Color(0xFFFF5656);

  static Color error = Color(0xFFFF5F5F);
  static Color warning = Color(0xFFF9A006);
  static Color success = Color(0xFF2EB568);
  static Color information = Color(0xFF3DA1FF);

  static Color white = Color(0xFFFFFFFF);
  static Color black = Color(0xFF000000);

  static Color background1 = Color(0xFFFDFDFC);
  static Color background2 = Color(0xFFF0F5F3);
  static Color borderColor = Color(0xFFD9D9D9);

 static Color? parseColor(String? hexString) {
    if (hexString.isNullOrEmpty) return null;
    final buffer = StringBuffer();
    if (hexString!.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

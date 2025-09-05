import 'dart:ffi';

import 'package:intl/intl.dart';

extension IntExtension on int? {
  String get toCurrency {
    try {
      if (this == null) return '';
      final NumberFormat usCurrency = NumberFormat('#,###', 'en_US');
      return usCurrency.format(this);
    } catch (e) {
      return toString();
    }
  }

  bool get haveValue {
    return this != null && this! > 0;
  }

  int get value {
    if (this != null) return this!;
    return 0;
  }
}

extension NumExtension on num? {
  String get toCurrency {
    try {
      if (this == null) return '';
      final NumberFormat usCurrency = NumberFormat('#,###', 'en_US');
      return usCurrency.format(this);
    } catch (e) {
      return toString();
    }
  }

  bool get haveValue {
    return this != null && this! > 0;
  }

  num get value {
    if (this != null) return this!;
    return 0;
  }

  num get roundValue {
    return value == value.toInt() ? value.toInt() : value;
  }
}

class NumUtil {
  static int gcd(int a, int b) {
    if (b == 0) return a.abs();
    return gcd(b, a % b);
  }
}

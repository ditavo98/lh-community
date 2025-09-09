import 'package:jiffy/jiffy.dart';
import 'package:intl/intl.dart';
import 'package:lh_community/src/core/configs.dart';
import 'package:lh_community/src/utils/res.dart';

extension DateTimeEx on DateTime? {
  DateTime get valueOrNow {
    if (this == null) return DateTime.now();
    return this!;
  }

  static String localTimeZone() {
    final offset = DateTime.now().timeZoneOffset;
    return '${offset.isNegative ? '-' : '+'}'
        '${offset.inHours.toString().padLeft(2, '0')}:'
        '${(offset.inMinutes % 60).toString().padLeft(2, '0')}';
  }

  bool isSameDate(DateTime? other) {
    return this?.year == other?.year &&
        this?.month == other?.month &&
        this?.day == other?.day;
  }

  DateTime get dateOnly {
    final now = DateTime.now();
    return DateTime(
      this?.year ?? now.year,
      this?.month ?? now.month,
      this?.day ?? now.day,
    );
  }

  DateTime get dateHourOnly {
    final now = DateTime.now();
    return DateTime(
      this?.year ?? now.year,
      this?.month ?? now.month,
      this?.day ?? now.day,
      this?.hour ?? now.hour,
    );
  }

  String get yyyyMMdd {
    if (this == null) return '';
    try {
      return DateFormat('yyyy-MM-dd').format(this!);
    } catch (e) {
      return '';
    }
  }

  String get yyyyMMddHHmm {
    if (this == null) return '';
    try {
      return DateFormat('yyyy-MM-dd HH:mm').format(this!);
    } catch (e) {
      return '';
    }
  }

  String get yyyyMMddHHmmDot {
    if (this == null) return '';
    try {
      return DateFormat('yyyy.MM.dd HH:mm').format(this!);
    } catch (e) {
      return '';
    }
  }

  String get yyyyMMddDot {
    if (this == null) return '';
    try {
      return DateFormat('yyyy.MM.dd').format(this!);
    } catch (e) {
      return '';
    }
  }

  String get yyMMddDot {
    if (this == null) return '';
    try {
      return DateFormat('yy.MM.dd').format(this!);
    } catch (e) {
      return '';
    }
  }

  String get toMMddHHmma {
    if (this == null) return '';
    try {
      if (LHConfigs.isKo) {
        return DateFormat('MM.dd EEE a hh:mm').format(this!);
      }
      return DateFormat('MM.dd EEE hh:mm a').format(this!);
    } catch (e) {
      return '';
    }
  }

  String get toMMddEEEHHmm2 {
    if (this == null) return '';
    try {
      return DateFormat('MM.dd(EEE) HH:mm').format(this!);
    } catch (e) {
      return '';
    }
  }

  String get toMMddHHmm2 {
    if (this == null) return '';
    try {
      return DateFormat('MM.dd HH:mm').format(this!);
    } catch (e) {
      return '';
    }
  }

  String get toMMddEEE2 {
    if (this == null) return '';
    try {
      return DateFormat('MM.dd(EEE)').format(this!);
    } catch (e) {
      return '';
    }
  }

  String get yyMMddHHmm {
    if (this == null) return '';
    try {
      if (LHConfigs.isKo) {
        return DateFormat('yy.MM.dd EEE HH:mm').format(this!);
      }
      return DateFormat('yy.MM.dd EEE HH:mm').format(this!);
    } catch (e) {
      return '';
    }
  }

  String get yyMMddEEE {
    if (this == null) return '';
    try {
      if (LHConfigs.isKo) {
        return DateFormat('yyyy년 MM월 dd일 EEE').format(this!);
      }
      return DateFormat('yyyy MM dd EEE').format(this!);
    } catch (e) {
      return '';
    }
  }

  String get toMMddaHHmm {
    if (this == null) return '';
    try {
      if (LHConfigs.isKo) {
        return DateFormat('MM월 dd일 a HH:mm').format(this!);
      }
      return DateFormat('MM dd a HH:mm').format(this!);
    } catch (e) {
      return '';
    }
  }

  String get toMMddHHmm {
    if (this == null) return '';
    try {
      if (LHConfigs.isKo) {
        return DateFormat('MM월 dd일 HH:mm').format(this!);
      }
      return DateFormat('MM dd HH:mm').format(this!);
    } catch (e) {
      return '';
    }
  }

  String get toMMdd {
    if (this == null) return '';
    try {
      if (LHConfigs.isKo) {
        return DateFormat('MM월 dd일').format(this!);
      }
      return DateFormat('MM dd').format(this!);
    } catch (e) {
      return '';
    }
  }

  String yyMMddHHmmAt([String? extra]) {
    if (this == null) return '';
    try {
      if (LHConfigs.isKo) {
        return [DateFormat('yy.MM.dd EEE HH:mm').format(this!), extra]
            .whereType<String>()
            .join(' ');
      }
      return [extra, DateFormat('yy.MM.dd EEE HH:mm').format(this!)]
          .whereType<String>()
          .join(' ');
    } catch (e) {
      return '';
    }
  }

  String get toMMddEEE {
    if (this == null) return '';
    try {
      return DateFormat('MM.dd (EEE)').format(this!);
    } catch (e) {
      return '';
    }
  }

  String get toMMddEEEHHmm {
    if (this == null) return '';
    try {
      return DateFormat('MM.dd (EEE) HH:mm').format(this!);
    } catch (e) {
      return '';
    }
  }

  String get toHHmma {
    if (this == null) return '';
    try {
      if (LHConfigs.isKo) {
        return DateFormat('a hh:mm').format(this!);
      }
      return DateFormat('hh:mm a').format(this!);
    } catch (e) {
      return '';
    }
  }

  String get hhMM {
    if (this == null) return '';
    try {
      return DateFormat('HH:mm').format(this!);
    } catch (e) {
      return '';
    }
  }

  String get ahhMM {
    if (this == null) return '';
    try {
      if (LHConfigs.isKo) {
        return DateFormat('a hh:mm').format(this!);
      }
      return DateFormat('hh:mm a').format(this!);
    } catch (e) {
      return '';
    }
  }

  String get toMMdd2 {
    if (this == null) return '';
    try {
      return DateFormat('MM.dd').format(this!);
    } catch (e) {
      return '';
    }
  }

  String timeAgo({bool numericDates = true}) {
    if (this == null) return '';
    final jiffyNow = Jiffy.now();
    final jiffyTime = Jiffy.parseFromDateTime(this!);
    final startTime = jiffyTime;
    final endTime = jiffyNow;
    final years = endTime.diff(startTime, unit: Unit.year);
    if (years >= 1) {
      return cmStr.text_years_ago('$years');
    }

    final months = endTime.diff(startTime, unit: Unit.month);
    if (months >= 1) {
      return cmStr.text_months_ago('$months');
    }
    final weeks = endTime.diff(startTime, unit: Unit.week);
    if (weeks == 1) {
      return cmStr.text_lastweek;
    }
    if (weeks > 1) {
      return cmStr.text_weeks_ago('$weeks');
    }

    final days = endTime.diff(startTime, unit: Unit.day);
    if (days == 1) {
      return cmStr.text_yesterday;
    }
    if (days > 1) {
      return cmStr.text_days_ago('$days');
    }

    final hours = endTime.diff(startTime, unit: Unit.hour);
    if (hours >= 1) {
      return cmStr.text_hours_ago('$hours');
    }

    final minutes = endTime.diff(startTime, unit: Unit.minute);
    if (minutes >= 1) {
      return cmStr.text_minutes_ago('$minutes');
    }

    final seconds = endTime.diff(startTime, unit: Unit.second);

    if (seconds >= 10) {
      return cmStr.text_seconds_ago('$seconds');
    }
    return cmStr.text_just_before;
  }

  int get daysIn1Year {
    if (this == null) return 0;
    final year = this!.year;
    final nextYear = this!.copyWith(year: year + 1);
    return nextYear.difference(this!).inDays;
  }
}

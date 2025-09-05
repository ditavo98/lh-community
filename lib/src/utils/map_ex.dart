extension MapExtension on Map? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get notNullOrEmpty => this != null && this!.isNotEmpty;
  Map getMap(String key) {
    if (this == null || this is! Map) {
      return {};
    }
    return this![key] as Map? ?? {};
  }

  String str(String key, {String def = ""}) {
    if (this == null || this is! Map) {
      return def;
    }
    return this![key]?.toString() ?? def;
  }

  String strOrThrow(String key) {
    if (this == null || this is! Map) {
      throw Exception("can not get $key via string");
    }
    if (this![key] == null) {
      throw Exception("can not get $key via string");
    }
    return this![key].toString();
  }

  String? strOrNull(String key) {
    if (this == null || this is! Map) {
      return null;
    }
    return this![key]?.toString();
  }

  int getInt(String key, {int def = 0}) {
    if (this == null || this is! Map) {
      return def;
    }
    final value = this![key];
    if (value == null) {
      return def;
    }
    return int.tryParse(value.toString()) ?? def;
  }

  double getDouble(String key, {double def = 0}) {
    if (this == null || this is! Map) {
      return def;
    }
    final value = this![key];
    if (value == null) {
      return def;
    }
    return double.tryParse(value.toString()) ?? def;
  }

  bool getBool(String key, {bool def = false}) {
    if (this == null || this is! Map) {
      return def;
    }
    final value = this![key];
    if (value == null || value is! bool) {
      return def;
    }
    return value;
  }

  List getList(String key) {
    if (this == null || this is! Map) {
      return [];
    }
    return this![key] as List? ?? [];
  }
}

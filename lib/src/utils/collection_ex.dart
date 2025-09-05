extension CollectionExtension<T> on List<T>? {
  bool get isNullOrEmpty =>
      this == null || this is! List || (this as List).isEmpty;

  bool get notNullOrEmpty =>
      this != null && this is List && (this as List).isNotEmpty;

  T? getOrNull(int index) {
    if (this == null) {
      return null;
    }
    if (index >= 0 && index < this!.length) {
      return this![index];
    }
    return null;
  }

  bool validIndex(int index) {
    if (this == null) return false;
    if (this!.isEmpty) return false;
    return index < this!.length && index >= 0;
  }

  bool equal(List<T>? a, {bool Function(T a, T b)? compare}) {
    if (a == null || this == null || a.length != this!.length) {
      return false;
    }
    if (compare != null) {
      for (int i = 0; i < a.length; i++) {
        if (!compare(a[i], this![i])) {
          return false;
        }
      }
    } else {
      for (int i = 0; i < a.length; i++) {
        if (a[i] != this![i]) {
          return false;
        }
      }
    }
    return true;
  }
}

extension ListExtension<T> on Iterable<T> {
  Iterable<T> except(Iterable<T> elements) {
    var result = List<T>.from(this);
    if (elements.isEmpty) return result;

    for (var element in elements) {
      while (result.contains(element)) {
        result.remove(element);
      }

      if (result.isEmpty) {
        break;
      }
    }
    return result;
  }

  Iterable<T> intersect(Iterable<T> elements) {
    var result = <T>[];
    if (elements.isEmpty) return [];

    for (var element in elements) {
      if (contains(element)) {
        result.add(element);
      }
    }
    return result.toSet().toList();
  }
}

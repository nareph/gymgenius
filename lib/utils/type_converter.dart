// lib/utils/type_converter.dart
class TypeConverter {
  /// Safely converts any Map to Map<String, dynamic>
  static Map<String, dynamic> toSafeMap(dynamic map) {
    if (map is Map<String, dynamic>) {
      return map;
    }

    if (map is Map) {
      final safeMap = <String, dynamic>{};
      map.forEach((key, value) {
        safeMap[key.toString()] = _convertValue(value);
      });
      return safeMap;
    }

    return {};
  }

  /// Safely converts any List to List<T>
  static List<T> toSafeList<T>(dynamic list) {
    if (list is List<T>) {
      return list;
    }

    if (list is List) {
      return list.map((e) => _convertValue(e) as T).whereType<T>().toList();
    }

    return [];
  }

  /// Recursively converts values
  static dynamic _convertValue(dynamic value) {
    if (value is Map) {
      return toSafeMap(value);
    } else if (value is List) {
      return value.map(_convertValue).toList();
    } else {
      return value;
    }
  }
}

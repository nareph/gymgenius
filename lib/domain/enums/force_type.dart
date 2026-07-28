enum ForceType {
  push,
  pull,
  isometric,
}

extension ForceTypeExtension on ForceType {
  String get displayName {
    switch (this) {
      case ForceType.push:
        return 'Push';
      case ForceType.pull:
        return 'Pull';
      case ForceType.isometric:
        return 'Isometric';
    }
  }

  String get value {
    switch (this) {
      case ForceType.push:
        return 'push';
      case ForceType.pull:
        return 'pull';
      case ForceType.isometric:
        return 'isometric';
    }
  }

  static ForceType fromValue(String value) {
    return ForceType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ForceType.push,
    );
  }
}

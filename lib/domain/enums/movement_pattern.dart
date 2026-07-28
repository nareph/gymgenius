enum MovementPattern {
  push,
  pull,
  squat,
  hinge,
  lunge,
  carry,
  rotation,
  core,
  cardio,
}

extension MovementPatternExtension on MovementPattern {
  String get displayName {
    switch (this) {
      case MovementPattern.push:
        return 'Push';
      case MovementPattern.pull:
        return 'Pull';
      case MovementPattern.squat:
        return 'Squat';
      case MovementPattern.hinge:
        return 'Hinge';
      case MovementPattern.lunge:
        return 'Lunge';
      case MovementPattern.carry:
        return 'Carry';
      case MovementPattern.rotation:
        return 'Rotation';
      case MovementPattern.core:
        return 'Core';
      case MovementPattern.cardio:
        return 'Cardio';
    }
  }

  String get value {
    switch (this) {
      case MovementPattern.push:
        return 'push';
      case MovementPattern.pull:
        return 'pull';
      case MovementPattern.squat:
        return 'squat';
      case MovementPattern.hinge:
        return 'hinge';
      case MovementPattern.lunge:
        return 'lunge';
      case MovementPattern.carry:
        return 'carry';
      case MovementPattern.rotation:
        return 'rotation';
      case MovementPattern.core:
        return 'core';
      case MovementPattern.cardio:
        return 'cardio';
    }
  }

  static MovementPattern fromValue(String value) {
    return MovementPattern.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MovementPattern.push,
    );
  }
}

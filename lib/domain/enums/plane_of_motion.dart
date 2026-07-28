enum PlaneOfMotion {
  sagittal,
  frontal,
  transverse,
}

extension PlaneOfMotionExtension on PlaneOfMotion {
  String get displayName {
    switch (this) {
      case PlaneOfMotion.sagittal:
        return 'Sagittal';
      case PlaneOfMotion.frontal:
        return 'Frontal';
      case PlaneOfMotion.transverse:
        return 'Transverse';
    }
  }

  String get value {
    switch (this) {
      case PlaneOfMotion.sagittal:
        return 'sagittal';
      case PlaneOfMotion.frontal:
        return 'frontal';
      case PlaneOfMotion.transverse:
        return 'transverse';
    }
  }

  static PlaneOfMotion fromValue(String value) {
    return PlaneOfMotion.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PlaneOfMotion.sagittal,
    );
  }
}

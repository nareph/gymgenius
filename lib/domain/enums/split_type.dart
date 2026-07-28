enum SplitType {
  fullBody,
  upperLower,
  pushPullLegs,
  broSplit,
  custom,
}

extension SplitTypeExtension on SplitType {
  String get displayName {
    switch (this) {
      case SplitType.fullBody:
        return 'Full Body';
      case SplitType.upperLower:
        return 'Upper / Lower';
      case SplitType.pushPullLegs:
        return 'Push / Pull / Legs';
      case SplitType.broSplit:
        return 'Bro Split';
      case SplitType.custom:
        return 'Custom';
    }
  }

  String get value {
    switch (this) {
      case SplitType.fullBody:
        return 'full_body';
      case SplitType.upperLower:
        return 'upper_lower';
      case SplitType.pushPullLegs:
        return 'push_pull_legs';
      case SplitType.broSplit:
        return 'bro_split';
      case SplitType.custom:
        return 'custom';
    }
  }

  static SplitType fromValue(String value) {
    return SplitType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SplitType.custom,
    );
  }
}

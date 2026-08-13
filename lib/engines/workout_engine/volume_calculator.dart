import 'package:gymgenius/domain/enums/activity_level.dart';

/// Calculates training volume based on session duration and daily activity.
class VolumeCalculator {
  VolumeCalculator._();

  /// Returns the number of exercises for a session given duration and offset.
  static int exerciseCountForSession(
    String? sessionDuration,
    int offset, {
    ActivityLevel activityLevel = ActivityLevel.moderatelyActive,
  }) {
    final base = switch (sessionDuration) {
      'short_30_max' => 3 + (offset % 2),
      'medium_45' => 4 + (offset % 2),
      'standard_60' => 5 + (offset % 2),
      'long_75_90' => 6 + (offset % 3),
      'very_long_90_plus' => 7 + (offset % 3),
      _ => 5,
    };

    final adjusted = base + _activityOffset(activityLevel);
    return adjusted.clamp(3, 9);
  }

  static int _activityOffset(ActivityLevel activityLevel) {
    switch (activityLevel) {
      case ActivityLevel.sedentary:
        return -1;
      case ActivityLevel.lightlyActive:
      case ActivityLevel.moderatelyActive:
        return 0;
      case ActivityLevel.veryActive:
      case ActivityLevel.extraActive:
        return 1;
    }
  }
}

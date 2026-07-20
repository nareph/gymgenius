/// Calculates training volume based on session duration.
class VolumeCalculator {
  VolumeCalculator._();

  /// Returns the number of exercises for a session given duration and offset.
  static int exerciseCountForSession(String? sessionDuration, int offset) {
    return switch (sessionDuration) {
      'short_30_max' => 3 + (offset % 2),
      'medium_45' => 4 + (offset % 2),
      'standard_60' => 5 + (offset % 2),
      'long_75_90' => 6 + (offset % 3),
      'very_long_90_plus' => 7 + (offset % 3),
      _ => 5,
    };
  }
}

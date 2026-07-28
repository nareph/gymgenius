import 'package:flutter/material.dart';

/// Returns an appropriate IconData based on the provided onboarding question key.
///
/// This is used to display a relevant icon next to each user preference.
IconData getIconForOnboardingKey(String key) {
  switch (key) {
    case 'goal':
      return Icons.flag_outlined;
    case 'gender':
      return Icons.wc_outlined;
    case 'physical_stats':
      return Icons.accessibility_new_outlined;
    case 'experience':
      return Icons.insights_outlined;
    case 'frequency':
      return Icons.event_repeat_outlined;
    case 'session_duration_minutes':
      return Icons.timer_outlined;
    case 'workout_days':
      return Icons.date_range_outlined;
    case 'equipment':
      return Icons.fitness_center_outlined;
    case 'focus_areas':
      return Icons.filter_center_focus_outlined;
    default:
      return Icons.help_outline_rounded;
  }
}

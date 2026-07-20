// lib/engines/workout_engine/overload_rules.dart
class OverloadRules {
  OverloadRules._();

  static int setsForExperience(String? experience, int offset) {
    return switch (experience?.toLowerCase()) {
      'beginner' => 2 + (offset % 2),
      'intermediate' => 3 + (offset % 2),
      'advanced' || 'expert' => 4 + (offset % 2),
      _ => 3,
    };
  }

  static String repsForExperience(
    String? experience,
    String? exerciseType,
    String? goal,
  ) {
    // Base range based on exercise type (isolation vs compound)
    final isIsolation = exerciseType?.toLowerCase() == 'isolation';
    final baseRange = isIsolation ? '12-15' : '8-12';

    // Adjust by experience
    final expRange = switch (experience?.toLowerCase()) {
      'beginner' => isIsolation ? '10-15' : '6-10',
      'intermediate' => isIsolation ? '12-15' : '8-12',
      'advanced' || 'expert' => isIsolation ? '15-20' : '10-15',
      _ => baseRange,
    };

    // Adjust by goal
    final goalRange = switch (goal?.toLowerCase()) {
      'increase_strength' || 'strength' => '4-6',
      'build_muscle' || 'hypertrophy' => expRange, // keep experience-based
      'improve_endurance' || 'endurance' => '15-20',
      'general_fitness' || _ => expRange,
    };

    return goalRange;
  }

  static int programDurationWeeks(String? experience, int offset) {
    final baseDuration = switch (experience?.toLowerCase()) {
      'beginner' => 6,
      'intermediate' => 8,
      'advanced' || 'expert' => 10,
      _ => 6,
    };
    return baseDuration + (offset % 3) - 1;
  }
}

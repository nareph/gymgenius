import 'package:gymgenius/presentation/question/profile_questions.dart';

/// Utility class that operates on raw `answers` maps to determine
/// completeness and which questions have been answered.
///
/// It does not rely on any domain entity, making it safe to use during
/// onboarding and for re‑editing flows.
class ProfileCompleteness {
  const ProfileCompleteness._();

  // The list of question ids that are required for a profile to be
  // considered complete (i.e., usable by the training engine).
  static const List<String> requiredQuestionIds = [
    'goal',
    'gender',
    'physical_stats',
    'experience',
    'activity_level',
    'frequency',
    'session_duration_minutes',
    'workout_days',
    'equipment',
    'country',
  ];

  static const List<String> requiredStatSubKeys = [
    'age',
    'height_m',
    'weight_kg',
  ];

  /// Returns the list of required question ids that are still missing
  /// or invalid in the raw [answers] map.
  static List<String> getMissingRequiredQuestionIds(
    Map<String, dynamic> answers,
  ) {
    final missing = <String>[];

    for (final id in requiredQuestionIds) {
      if (id == 'physical_stats') {
        if (_isStatsIncomplete(answers['physical_stats'])) {
          missing.add(id);
        }
        continue;
      }

      if (_isEmptyAnswer(answers[id])) {
        missing.add(id);
      }
    }

    return missing;
  }

  /// Returns the list of ALL question ids (not only required ones) that
  /// have a valid, non‑empty answer in the raw [answers] map.
  ///
  /// This is used to populate `HealthProfile.answeredQuestionIds`
  /// so that optional questions (e.g., nutrition) are also tracked.
  static List<String> getAnsweredQuestionIds(
    Map<String, dynamic> answers,
  ) {
    final allIds = <String>[];

    // We only consider questions from defaultProfileQuestions because
    // the answers map may contain temporary keys.
    for (final question in defaultProfileQuestions) {
      final id = question.id;
      if (id == 'physical_stats') {
        if (!_isStatsIncomplete(answers['physical_stats'])) {
          allIds.add(id);
        }
        continue;
      }

      if (!_isEmptyAnswer(answers[id])) {
        allIds.add(id);
      }
    }

    return allIds;
  }

  /// Convenience method to filter [questions] down to only those with
  /// ids present in [missingIds].
  static List<ProfileQuestion> filterQuestionsById(
    List<ProfileQuestion> allQuestions,
    List<String> missingIds,
  ) {
    final idSet = missingIds.toSet();
    return allQuestions.where((q) => idSet.contains(q.id)).toList();
  }

  // --- Private helpers ---

  static bool _isStatsIncomplete(dynamic rawStats) {
    if (rawStats is! Map) return true;
    for (final key in requiredStatSubKeys) {
      final value = rawStats[key];
      if (value == null) return true;
      if (value is num && value <= 0) return true;
    }
    return false;
  }

  static bool _isEmptyAnswer(dynamic value) {
    if (value == null) return true;
    if (value is String) return value.trim().isEmpty;
    if (value is List) return value.isEmpty;
    if (value is Map) return value.isEmpty;
    return false;
  }

  /// Human‑readable labels for required question ids (used in error
  /// messages if needed).
  static const Map<String, String> questionLabels = {
    'goal': 'Fitness goal',
    'gender': 'Gender',
    'physical_stats': 'Age, height & weight',
    'experience': 'Experience level',
    'activity_level': 'Activity level',
    'frequency': 'Training frequency',
    'session_duration_minutes': 'Session duration',
    'workout_days': 'Preferred training days',
    'equipment': 'Available equipment',
    'country': 'Country',
  };
}

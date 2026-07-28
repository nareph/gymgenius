// lib/presentation/mappers/profile_completeness.dart

import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/presentation/question/profile_questions.dart';

/// Validation helper that operates on the RAW `answers` map collected
/// live during onboarding (before `ProfileSetupMapper` applies its
/// defaults). It is the only place that knows the shape of each answer
/// (e.g. `physical_stats` is a Map with sub-keys) well enough to say
/// whether a question was genuinely, validly answered.
///
/// The actual list of required question ids lives on `HealthProfile`
/// (`HealthProfile.requiredFieldIds`) — a domain-level concept — so this
/// class references it instead of duplicating it, and so does
/// `HealthProfile.isComplete` once the profile is persisted.
class ProfileCompleteness {
  const ProfileCompleteness._();

  static List<String> get requiredQuestionIds => HealthProfile.requiredFieldIds;

  static const List<String> requiredStatSubKeys = [
    'age',
    'height_m',
    'weight_kg',
  ];

  /// Returns the list of required question ids still missing or invalid
  /// in the raw [answers] map (used live, during onboarding).
  static List<String> getMissingQuestionIds(Map<String, dynamic> answers) {
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

  /// The subset of required question ids that ARE validly answered in
  /// [answers]. This is what gets persisted as
  /// `HealthProfile.answeredQuestionIds` once the profile is saved.
  static List<String> getAnsweredRequiredQuestionIds(
      Map<String, dynamic> answers) {
    final missing = getMissingQuestionIds(answers).toSet();
    return requiredQuestionIds.where((id) => !missing.contains(id)).toList();
  }

  static bool isComplete(Map<String, dynamic> answers) =>
      getMissingQuestionIds(answers).isEmpty;

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
    return false;
  }

  /// Filters [allQuestions] down to only those whose id is in
  /// [missingIds]. Used when resuming an incomplete profile — the ids
  /// come from `HealthProfile.missingFieldIds` (persisted), not from a
  /// raw answers map.
  static List<ProfileQuestion> filterQuestionsById(
    List<ProfileQuestion> allQuestions,
    List<String> missingIds,
  ) {
    final idSet = missingIds.toSet();
    return allQuestions.where((q) => idSet.contains(q.id)).toList();
  }

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

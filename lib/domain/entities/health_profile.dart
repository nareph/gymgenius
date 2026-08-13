import 'package:gymgenius/domain/value_objects/body_measurements.dart';
import 'package:gymgenius/domain/value_objects/workout_preferences.dart';
import 'package:gymgenius/domain/value_objects/lifestyle_preferences.dart';

import '../enums/exports.dart';

/// Domain Entity representing the user's permanent health profile.
///
/// This is the core data model used by all engines:
/// - Workout Engine
/// - Nutrition Engine
/// - Recovery Engine
/// - Progress Engine
/// - Decision Engine
///
/// Values evolve slowly over time.
class HealthProfile {
  final String userId;
  final BodyMeasurements body;
  final WorkoutPreferences training;
  final LifestylePreferences lifestyle;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Question ids the user has genuinely answered (as opposed to values
  /// silently defaulted by `ProfileSetupMapper` for unanswered questions).
  ///
  /// This is the ONLY reliable way to know whether e.g. `training.goal`
  /// reflects a real user choice or the 'general_fitness' fallback — the
  /// enum value itself can't tell you that. Engines should ignore this
  /// field entirely (they always get a usable, defaulted profile); it
  /// exists purely for onboarding completeness (`isComplete`) and for
  /// resuming profile setup with only the missing questions.
  final List<String> answeredQuestionIds;

  const HealthProfile({
    required this.userId,
    required this.body,
    required this.training,
    required this.lifestyle,
    required this.createdAt,
    required this.updatedAt,
    this.answeredQuestionIds = const [],
  });

  // ============================================================
  // Completeness contract
  //
  // This list is the domain-level source of truth for "which questions
  // must be answered for the profile to be usable end to end". Presentation
  // code (ProfileCompleteness, ProfileSetupScreen, AuthBloc) references
  // this constant instead of duplicating it, to avoid the two drifting
  // apart. `focus_areas` and `target_weight_kg` are deliberately excluded
  // — they're optional everywhere in the app.
  // ============================================================

  static const List<String> requiredFieldIds = [
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

  // ============================================================
  // Convenience getters (delegation to body & training)
  // ============================================================

  int get age => body.age;
  Gender get gender => body.gender;
  double get heightCm => body.heightCm;
  double get currentWeightKg => body.currentWeightKg;
  double? get targetWeightKg => body.targetWeightKg;

  FitnessGoal get goal => training.goal;
  ExperienceLevel get experience => training.experience;
  SessionDuration get sessionDuration => training.sessionDuration;
  List<WorkoutDay> get workoutDays => training.preferredDays;
  List<EquipmentType> get equipment => training.equipment;
  List<MuscleGroup> get focusAreas => training.focusAreas;
  List<MuscleGroup> get avoidedMuscles => training.avoidedMuscles;

  String get country => lifestyle.country;

  /// Real onboarding completeness — every required question has been
  /// genuinely answered by the user (not defaulted).
  bool get isComplete => requiredFieldIds.every(answeredQuestionIds.contains);

  /// Required question ids the user still needs to answer.
  List<String> get missingFieldIds => requiredFieldIds
      .where((id) => !answeredQuestionIds.contains(id))
      .toList();

  // ============================================================
  // Copy method
  // ============================================================

  HealthProfile copyWith({
    String? userId,
    BodyMeasurements? body,
    WorkoutPreferences? training,
    LifestylePreferences? lifestyle,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? answeredQuestionIds,
  }) {
    return HealthProfile(
      userId: userId ?? this.userId,
      body: body ?? this.body,
      training: training ?? this.training,
      lifestyle: lifestyle ?? this.lifestyle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      answeredQuestionIds: answeredQuestionIds ?? this.answeredQuestionIds,
    );
  }

  // ============================================================
  // Equality & toString
  // ============================================================

  @override
  bool operator ==(Object other) {
    return other is HealthProfile && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() {
    return 'HealthProfile(userId: $userId, goal: ${training.goal.value}, isComplete: $isComplete)';
  }
}

import 'package:gymgenius/domain/enums/experience_level.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/engines/workout_engine/models/muscle_split.dart';

import 'split_catalog.dart';
import 'split_focus_validator.dart';

/// Resolves the weekly workout structure.
///
/// The planner follows a stable two-step process:
///
/// 1. Start from the predefined v1/v2 split for the requested number
///    of workout days.
/// 2. Validate/adapt that structure according to the user's focus areas.
///
/// Focus areas are treated as strict user intent:
///
///     "I want to work only these muscles."
///
/// When the predefined split is compatible with the requested muscles,
/// it is preserved.
///
/// When it is incompatible, [SplitFocusValidator] may replace the
/// affected structure with a specialized focus split.
///
/// The planner never scores arbitrary individual splits against one another.
/// This preserves the stable weekly structures that were used by v1/v2.
class SplitPlanner {
  const SplitPlanner({
    SplitFocusValidator focusValidator = const SplitFocusValidator(),
  }) : _focusValidator = focusValidator;

  final SplitFocusValidator _focusValidator;

  /// Builds the final weekly split plan.
  ///
  /// [workoutDays] determines the initial predefined v1/v2 template.
  ///
  /// [experience] is kept in the public API for compatibility with the
  /// previous planner and for future experience-specific policies.
  ///
  /// [focusMuscles] represents the user's explicit muscle selection.
  ///
  /// When [focusMuscles] is empty, the predefined template is returned
  /// unchanged.
  List<MuscleSplit> plan({
    required int workoutDays,
    required ExperienceLevel experience,
    required List<MuscleGroup> focusMuscles,
  }) {
    final normalizedDays = _normalizeWorkoutDays(workoutDays);

    final baseTemplate = SplitCatalog.templateCopyForDays(
      normalizedDays,
    );

    if (baseTemplate.isEmpty) {
      return const <MuscleSplit>[];
    }

    if (focusMuscles.isEmpty) {
      return baseTemplate;
    }

    return _focusValidator.validate(
      baseSplits: baseTemplate,
      focusMuscles: _normalizeFocusMuscles(focusMuscles),
      workoutDays: normalizedDays,
      experience: experience,
    );
  }

  // ============================================================
  // Helpers
  // ============================================================

  int _normalizeWorkoutDays(int workoutDays) {
    if (workoutDays <= 1) {
      return 1;
    }

    if (workoutDays >= 7) {
      return 7;
    }

    return workoutDays;
  }

  List<MuscleGroup> _normalizeFocusMuscles(
    List<MuscleGroup> muscles,
  ) {
    final seen = <MuscleGroup>{};
    final normalized = <MuscleGroup>[];

    for (final muscle in muscles) {
      if (seen.add(muscle)) {
        normalized.add(muscle);
      }
    }

    return List.unmodifiable(normalized);
  }
}

import 'package:gymgenius/domain/enums/experience_level.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/engines/workout_engine/models/muscle_split.dart';

import 'focus_split_factory.dart';

/// Validates a predefined weekly split against explicit user focus areas.
///
/// Focus areas mean:
///
///     "I want to work only these muscles."
///
/// Therefore a predefined split is retained only when its individual
/// workout days are compatible with the requested focus.
///
/// A split is NOT considered compatible merely because the focus appears
/// somewhere else during the week.
///
/// Example:
///
/// Push / Pull / Legs
/// focus = Abs/Core
///
/// is incompatible because Push and Pull introduce unrelated primary
/// muscles, even if Legs happens to contain Abs/Core.
///
/// In such cases a specialized focus split is created.
class SplitFocusValidator {
  const SplitFocusValidator({
    FocusSplitFactory factory = const FocusSplitFactory(),
  }) : _factory = factory;

  final FocusSplitFactory _factory;

  List<MuscleSplit> validate({
    required List<MuscleSplit> baseSplits,
    required List<MuscleGroup> focusMuscles,
    required int workoutDays,
    ExperienceLevel? experience,
  }) {
    if (baseSplits.isEmpty) {
      return const [];
    }

    final normalizedFocus = _normalizeFocus(focusMuscles);

    if (normalizedFocus.isEmpty) {
      return List<MuscleSplit>.from(baseSplits);
    }

    final template = _fitTemplateToDays(
      baseSplits,
      _normalizeWorkoutDays(workoutDays),
    );

    if (_isBroadFocus(normalizedFocus)) {
      return template;
    }

    if (_isCompatibleTemplate(
      template: template,
      focusMuscles: normalizedFocus,
    )) {
      return template;
    }

    return _factory.createWeek(
      focusMuscles: normalizedFocus,
      workoutDays: template.length,
    );
  }

  //===========================================================================
  // Compatibility
  //===========================================================================

  bool _isCompatibleTemplate({
    required List<MuscleSplit> template,
    required List<MuscleGroup> focusMuscles,
  }) {
    for (final split in template) {
      if (!_isDayCompatible(
        split: split,
        focusMuscles: focusMuscles,
      )) {
        return false;
      }
    }

    return true;
  }

  bool _isDayCompatible({
    required MuscleSplit split,
    required List<MuscleGroup> focusMuscles,
  }) {
    if (split.muscles.isEmpty) {
      return false;
    }

    final focus = focusMuscles.toSet();

    // A predefined split is compatible when its primary session identity
    // belongs to the user's requested focus.
    //
    // The complete split scope may contain secondary/supporting muscles.
    //
    // Example:
    //
    // Push
    //   primary = Chest
    //   secondary = Shoulders, Triceps, Core
    //
    // focus = Chest
    //   -> compatible
    //
    // This prevents secondary muscles from incorrectly invalidating a
    // historically valid predefined split.
    final primaryMuscles = split.primaryMuscles;

    if (primaryMuscles.isEmpty) {
      return false;
    }

    return primaryMuscles.every(focus.contains);
  }

  //===========================================================================
  // Broad focus
  //===========================================================================

  bool _isBroadFocus(List<MuscleGroup> focusMuscles) {
    final normalized = _normalizeFocus(focusMuscles);

    if (normalized.isEmpty) {
      return false;
    }

    // A broad explicit selection means the user selected enough major
    // muscle groups to request a balanced program.
    //
    // 7+ muscles is always considered broad.
    if (normalized.length >= 7) {
      return true;
    }

    // Three or more major muscle regions also represent a balanced request.
    final regions = normalized.map(_regionOf).toSet();

    if (regions.length >= 3) {
      return true;
    }

    // Standard hypertrophy/default focus:
    // Chest + Back + Shoulders must keep the predefined split structure.
    //
    // This prevents the default build-muscle focus from being interpreted
    // as a narrow specialized program.
    const standardUpperHypertrophyFocus = {
      MuscleGroup.chest,
      MuscleGroup.back,
      MuscleGroup.shoulders,
    };

    if (normalized.length == standardUpperHypertrophyFocus.length &&
        normalized.toSet().containsAll(standardUpperHypertrophyFocus)) {
      return true;
    }

    return false;
  }

  //===========================================================================
  // Template
  //===========================================================================

  List<MuscleSplit> _fitTemplateToDays(
    List<MuscleSplit> baseSplits,
    int workoutDays,
  ) {
    if (baseSplits.length == workoutDays) {
      return List<MuscleSplit>.from(baseSplits);
    }

    if (baseSplits.length > workoutDays) {
      return List<MuscleSplit>.from(
        baseSplits.take(workoutDays),
      );
    }

    final result = <MuscleSplit>[];

    for (var i = 0; i < workoutDays; i++) {
      result.add(
        baseSplits[i % baseSplits.length],
      );
    }

    return result;
  }

  //===========================================================================
  // Normalization
  //===========================================================================

  List<MuscleGroup> _normalizeFocus(
    Iterable<MuscleGroup> muscles,
  ) {
    final seen = <MuscleGroup>{};
    final result = <MuscleGroup>[];

    for (final muscle in muscles) {
      if (seen.add(muscle)) {
        result.add(muscle);
      }
    }

    return result;
  }

  int _normalizeWorkoutDays(
    int workoutDays,
  ) {
    if (workoutDays <= 1) {
      return 1;
    }

    if (workoutDays >= 7) {
      return 7;
    }

    return workoutDays;
  }

  //===========================================================================
  // Muscle regions
  //===========================================================================

  String _regionOf(
    MuscleGroup muscle,
  ) {
    switch (muscle) {
      case MuscleGroup.chest:
      case MuscleGroup.back:
      case MuscleGroup.shoulders:
      case MuscleGroup.biceps:
      case MuscleGroup.triceps:
      case MuscleGroup.forearms:
      case MuscleGroup.traps:
        return 'upper';

      case MuscleGroup.quadriceps:
      case MuscleGroup.hamstrings:
      case MuscleGroup.glutes:
      case MuscleGroup.calves:
      case MuscleGroup.adductors:
        return 'lower';

      case MuscleGroup.absCore:
        return 'core';
    }
  }
}

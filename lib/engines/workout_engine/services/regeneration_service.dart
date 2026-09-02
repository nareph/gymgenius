import 'package:gymgenius/core/logger/logger_service.dart';

import 'package:gymgenius/domain/entities/exercise.dart';
import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/domain/enums/exports.dart';

import 'package:gymgenius/engines/workout_engine/generators/workout_day_generator.dart';
import 'package:gymgenius/engines/workout_engine/models/muscle_split.dart';
import 'package:gymgenius/engines/workout_engine/models/workout_days_result.dart';
import 'package:gymgenius/engines/workout_engine/planner/split_planner.dart';
import 'package:gymgenius/engines/workout_engine/planner/workout_frequency_planner.dart';
import 'package:gymgenius/engines/workout_engine/services/generation_service.dart';
import 'package:gymgenius/engines/workout_engine/shared/profile_coherence.dart';
import 'package:gymgenius/engines/workout_engine/shared/workout_constants.dart';

/// Handles program regeneration with specific options.
///
/// `options` comes from `RegenerationOptions.toMap()`.
///
/// Supported regeneration types:
///
/// - `specificDay`
///   Regenerates ONLY the requested day.
///
/// - `singleExercise`
///   Replaces ONE exercise within the requested day.
///
/// - `fullProgram` / `withPreferences`
///   Regenerates every scheduled day.
///
/// When `keepStructure == true`, the existing workout-day structure is
/// preserved as much as the currently available domain information allows:
///
/// • same scheduled workout days
/// • same number of exercises per day
/// • same planner-derived split mapping for the current profile
///
/// When `keepStructure == false`, the complete program is regenerated from
/// scratch through [GenerationService].
class RegenerationService {
  final GenerationService _generationService;
  final WorkoutDayGenerator _dayGenerator;
  final WorkoutFrequencyPlanner _frequencyPlanner;
  final SplitPlanner _splitPlanner;

  static const _tag = 'RegenerationService';

  RegenerationService({
    GenerationService? generationService,
    WorkoutDayGenerator? dayGenerator,
    WorkoutFrequencyPlanner? frequencyPlanner,
    SplitPlanner? splitPlanner,
  })  : _generationService = generationService ?? GenerationService(),
        _dayGenerator = dayGenerator ?? WorkoutDayGenerator(),
        _frequencyPlanner = frequencyPlanner ?? const WorkoutFrequencyPlanner(),
        _splitPlanner = splitPlanner ?? const SplitPlanner();

  //===========================================================================
  // Public API
  //===========================================================================

  Future<TrainingProgram> regenerate({
    required HealthProfile profile,
    required TrainingProgram previousProgram,
    required Map<String, dynamic> options,
  }) async {
    final type = options['type'] as String?;

    Log.debug(
      'regenerate() dispatching on type="$type", options: $options',
      tag: _tag,
    );

    if (type == 'specificDay') {
      final targetDay = options['targetDay'] as String?;

      if (targetDay == null) {
        Log.warning(
          'type=specificDay but targetDay is missing '
          '— returning program unchanged.',
          tag: _tag,
        );

        return previousProgram;
      }

      return _regenerateSingleDay(
        profile: profile,
        previousProgram: previousProgram,
        targetDay: targetDay.toLowerCase(),
        options: options,
      );
    }

    if (type == 'singleExercise') {
      final targetDay = options['targetDay'] as String?;
      final targetExerciseId = options['targetExerciseId'] as String?;

      if (targetDay == null || targetExerciseId == null) {
        Log.warning(
          'type=singleExercise but targetDay/targetExerciseId is missing '
          '— returning program unchanged.',
          tag: _tag,
        );

        return previousProgram;
      }

      return _regenerateSingleExercise(
        profile: profile,
        previousProgram: previousProgram,
        targetDay: targetDay.toLowerCase(),
        targetExerciseId: targetExerciseId,
        options: options,
      );
    }

    return _regenerateFullProgram(
      profile: profile,
      previousProgram: previousProgram,
      options: options,
    );
  }

  //===========================================================================
  // Single-day regeneration
  //===========================================================================

  Future<TrainingProgram> _regenerateSingleDay({
    required HealthProfile profile,
    required TrainingProgram previousProgram,
    required String targetDay,
    required Map<String, dynamic> options,
  }) async {
    final adjustedProfile = _profileWithAdjustments(
      profile,
      options,
    );

    final split = _findSplitForDay(
      adjustedProfile,
      targetDay,
    );

    if (split == null) {
      Log.warning(
        '"$targetDay" is not a scheduled workout day in the current split '
        '— nothing to regenerate, returning the program unchanged.',
        tag: _tag,
      );

      return previousProgram;
    }

    //-----------------------------------------------------------------------
    // Keep all exercise IDs from the other days.
    //-----------------------------------------------------------------------

    final weeklyUsedExerciseIds = <String>{};

    for (final entry in previousProgram.weeklySchedule.entries) {
      if (entry.key == targetDay) {
        continue;
      }

      for (final exercise in entry.value) {
        weeklyUsedExerciseIds.add(
          exercise.id,
        );
      }
    }

    //-----------------------------------------------------------------------
    // Regenerate only the requested day.
    //-----------------------------------------------------------------------

    final newDayExercises = _dayGenerator.generate(
      split: split,
      profile: adjustedProfile,
      previousProgram: previousProgram,
      excludeMuscles: _parseExcludeMuscles(options),
      intensityOverride: _intensityString(options),
      weeklyUsedExerciseIds: weeklyUsedExerciseIds,
    );

    final updatedSchedule = Map<String, List<Exercise>>.from(
      previousProgram.weeklySchedule,
    );

    updatedSchedule[targetDay] = newDayExercises;

    Log.debug(
      'Regenerated only "$targetDay" '
      '(${newDayExercises.length} exercises), '
      'all other days kept as-is.',
      tag: _tag,
    );

    return previousProgram.copyWith(
      weeklySchedule: updatedSchedule,
    );
  }

  //===========================================================================
  // Single-exercise regeneration
  //===========================================================================

  Future<TrainingProgram> _regenerateSingleExercise({
    required HealthProfile profile,
    required TrainingProgram previousProgram,
    required String targetDay,
    required String targetExerciseId,
    required Map<String, dynamic> options,
  }) async {
    final dayExercises = previousProgram.weeklySchedule[targetDay];

    if (dayExercises == null || dayExercises.isEmpty) {
      Log.warning(
        '"$targetDay" has no exercises to replace '
        '— returning program unchanged.',
        tag: _tag,
      );

      return previousProgram;
    }

    final targetIndex = _findTargetExerciseIndex(
      dayExercises,
      targetExerciseId,
    );

    if (targetIndex == -1) {
      Log.warning(
        'Could not find exercise "$targetExerciseId" on "$targetDay" '
        '— returning program unchanged.',
        tag: _tag,
      );

      return previousProgram;
    }

    final adjustedProfile = _profileWithAdjustments(
      profile,
      options,
    );

    final split = _findSplitForDay(
      adjustedProfile,
      targetDay,
    );

    if (split == null) {
      Log.warning(
        '"$targetDay" is not a scheduled workout day in the current split '
        '— returning program unchanged.',
        tag: _tag,
      );

      return previousProgram;
    }

    //-----------------------------------------------------------------------
    // Collect every exercise ID already present in the program.
    //-----------------------------------------------------------------------

    final weeklyUsedExerciseIds = <String>{};

    for (final entry in previousProgram.weeklySchedule.entries) {
      for (final exercise in entry.value) {
        weeklyUsedExerciseIds.add(
          exercise.id,
        );
      }
    }

    //-----------------------------------------------------------------------
    // Remove the exercise currently being replaced.
    //-----------------------------------------------------------------------

    weeklyUsedExerciseIds.remove(
      targetExerciseId,
    );

    //-----------------------------------------------------------------------
    // Generate one replacement.
    //-----------------------------------------------------------------------

    final replacementDay = _dayGenerator.generate(
      split: split,
      profile: adjustedProfile,
      previousProgram: previousProgram,
      excludeMuscles: _parseExcludeMuscles(options),
      intensityOverride: _intensityString(options),
      desiredCountOverride: 1,
      weeklyUsedExerciseIds: weeklyUsedExerciseIds,
    );

    if (replacementDay.isEmpty) {
      Log.warning(
        'No replacement exercise found for "$targetDay" '
        '(equipment/exclusions may be too restrictive) '
        '— returning program unchanged.',
        tag: _tag,
      );

      return previousProgram;
    }

    final updatedDayExercises = List<Exercise>.from(
      dayExercises,
    );

    updatedDayExercises[targetIndex] = replacementDay.first;

    final updatedSchedule = Map<String, List<Exercise>>.from(
      previousProgram.weeklySchedule,
    );

    updatedSchedule[targetDay] = updatedDayExercises;

    Log.debug(
      'Replaced exercise at index $targetIndex on "$targetDay" '
      '("${dayExercises[targetIndex].name}" '
      '-> "${replacementDay.first.name}"). '
      'Day exercise count: ${updatedDayExercises.length} (unchanged).',
      tag: _tag,
    );

    return previousProgram.copyWith(
      weeklySchedule: updatedSchedule,
    );
  }

  int _findTargetExerciseIndex(
    List<Exercise> dayExercises,
    String targetExerciseId,
  ) {
    //-----------------------------------------------------------------------
    // Primary lookup: canonical exercise ID.
    //-----------------------------------------------------------------------

    final byId = dayExercises.indexWhere(
      (exercise) => exercise.id == targetExerciseId,
    );

    if (byId != -1) {
      return byId;
    }

    //-----------------------------------------------------------------------
    // Backward-compatible fallback.
    //-----------------------------------------------------------------------

    final match = RegExp(r'^exercise_(\d+)$').firstMatch(
      targetExerciseId,
    );

    if (match != null) {
      final index = int.tryParse(
        match.group(1)!,
      );

      if (index != null && index >= 0 && index < dayExercises.length) {
        return index;
      }
    }

    return -1;
  }

  //===========================================================================
  // Full-program regeneration
  //===========================================================================

  Future<TrainingProgram> _regenerateFullProgram({
    required HealthProfile profile,
    required TrainingProgram previousProgram,
    required Map<String, dynamic> options,
  }) async {
    final adjustedProfile = _profileWithAdjustments(
      profile,
      options,
    );

    final keepStructure = options['keepStructure'] as bool? ?? true;

    Log.debug(
      '_regenerateFullProgram: keepStructure=$keepStructure',
      tag: _tag,
    );

    if (!keepStructure) {
      Log.debug(
        '-> from-scratch regeneration via GenerationService',
        tag: _tag,
      );

      return _generationService.generate(
        profile: adjustedProfile,
        previousProgram: previousProgram,
        options: options,
      );
    }

    return _regenerateKeepingStructure(
      profile: adjustedProfile,
      previousProgram: previousProgram,
      options: options,
    );
  }

  Future<TrainingProgram> _regenerateKeepingStructure({
    required HealthProfile profile,
    required TrainingProgram previousProgram,
    required Map<String, dynamic> options,
  }) async {
    //-----------------------------------------------------------------------
    // Preserve the actual workout days from the previous program.
    //-----------------------------------------------------------------------

    final workoutDays = previousProgram.weeklySchedule.entries
        .where(
          (entry) => entry.value.isNotEmpty,
        )
        .map(
          (entry) => entry.key,
        )
        .toList();

    if (workoutDays.isEmpty) {
      Log.warning(
        'previousProgram has no workout days to preserve '
        '— falling back to a full from-scratch regeneration.',
        tag: _tag,
      );

      return _generationService.generate(
        profile: profile,
        previousProgram: previousProgram,
        options: options,
      );
    }

    //-----------------------------------------------------------------------
    // Re-plan the split structure using the current profile.
    //-----------------------------------------------------------------------

    final selectedSplit = _planSplitsForWorkoutDays(
      profile: profile,
      workoutDayCount: workoutDays.length,
    );

    if (selectedSplit.length != workoutDays.length) {
      Log.warning(
        'SplitPlanner returned ${selectedSplit.length} splits for '
        '${workoutDays.length} workout days '
        '— falling back to from-scratch generation.',
        tag: _tag,
      );

      return _generationService.generate(
        profile: profile,
        previousProgram: previousProgram,
        options: options,
      );
    }

    //-----------------------------------------------------------------------
    // Initialize schedule.
    //-----------------------------------------------------------------------

    final updatedSchedule = <String, List<Exercise>>{
      for (final day in WorkoutConstants.daysOfWeek) day: <Exercise>[],
    };

    final excludeMuscles = _parseExcludeMuscles(options);

    final intensityOverride = _intensityString(options);

    //-----------------------------------------------------------------------
    // Track newly generated exercise IDs across the entire regenerated week.
    //-----------------------------------------------------------------------

    final weeklyUsedExerciseIds = <String>{};

    //-----------------------------------------------------------------------
    // Regenerate each scheduled day.
    //-----------------------------------------------------------------------

    for (var i = 0; i < workoutDays.length && i < selectedSplit.length; i++) {
      final day = workoutDays[i];

      final previousExercises =
          previousProgram.weeklySchedule[day] ?? const <Exercise>[];

      final desiredCount = previousExercises.length;

      final dayExercises = _dayGenerator.generate(
        split: selectedSplit[i],
        profile: profile,
        previousProgram: previousProgram,
        excludeMuscles: excludeMuscles,
        intensityOverride: intensityOverride,
        desiredCountOverride: desiredCount,
        weeklyUsedExerciseIds: weeklyUsedExerciseIds,
      );

      updatedSchedule[day] = dayExercises;

      //---------------------------------------------------------------------
      // Register selected canonical exercise IDs.
      //---------------------------------------------------------------------

      for (final exercise in dayExercises) {
        weeklyUsedExerciseIds.add(
          exercise.id,
        );
      }
    }

    Log.debug(
      'Regenerated all ${workoutDays.length} days '
      'keeping workout days and per-day exercise counts.',
      tag: _tag,
    );

    return previousProgram.copyWith(
      weeklySchedule: updatedSchedule,
    );
  }

  //===========================================================================
  // Split planning
  //===========================================================================

  List<MuscleSplit> _planSplitsForWorkoutDays({
    required HealthProfile profile,
    required int workoutDayCount,
  }) {
    final focusMuscles = ProfileCoherence.resolveFocusAreas(
      goal: profile.training.goal,
      userFocusAreas: profile.training.focusAreas,
    );

    return _splitPlanner.plan(
      workoutDays: workoutDayCount,
      experience: profile.training.experience,
      focusMuscles: focusMuscles,
    );
  }

  //===========================================================================
  // Split resolution for one day
  //===========================================================================

  MuscleSplit? _findSplitForDay(
    HealthProfile profile,
    String targetDay,
  ) {
    final training = profile.training;

    final daysResult = _frequencyPlanner.calculateWorkoutDays(
      frequency: training.frequency,
      preferredDays: training.preferredDays
          .map(
            (day) => day.value,
          )
          .toList(),
    );

    final workoutDays = _resolveWorkoutDays(
      profile: profile,
      daysResult: daysResult,
    );

    final focusMuscles = ProfileCoherence.resolveFocusAreas(
      goal: training.goal,
      userFocusAreas: training.focusAreas,
    );

    final selectedSplit = _splitPlanner.plan(
      workoutDays: workoutDays.length,
      experience: training.experience,
      focusMuscles: focusMuscles,
    );

    if (selectedSplit.length != workoutDays.length) {
      return null;
    }

    final normalizedTargetDay = targetDay.trim().toLowerCase();

    final dayIndex = workoutDays.indexWhere(
      (day) => day.trim().toLowerCase() == normalizedTargetDay,
    );

    if (dayIndex == -1 || dayIndex >= selectedSplit.length) {
      return null;
    }

    return selectedSplit[dayIndex];
  }

  List<String> _resolveWorkoutDays({
    required HealthProfile profile,
    required WorkoutDaysResult daysResult,
  }) {
    final training = profile.training;

    if (daysResult.useSpecifiedDays && training.preferredDays.isNotEmpty) {
      return training.preferredDays
          .map(
            (day) => day.value,
          )
          .take(7)
          .toList();
    }

    return WorkoutConstants.defaultWorkoutDays(
      daysResult.count.clamp(1, 7),
    );
  }

  //===========================================================================
  // Profile adjustments
  //===========================================================================

  HealthProfile _profileWithAdjustments(
    HealthProfile profile,
    Map<String, dynamic> options,
  ) {
    var training = profile.training;
    var changed = false;

    //-----------------------------------------------------------------------
    // Focus muscles
    //
    // Explicit regeneration focus options REPLACE the existing selection.
    //-----------------------------------------------------------------------

    final focusRaw = options['focusMuscles'];

    if (focusRaw is List && focusRaw.isNotEmpty) {
      final requested = focusRaw
          .map(
            (value) => MuscleGroupExtension.fromValue(
              value.toString(),
            ),
          )
          .toSet()
          .toList();

      if (requested.isNotEmpty &&
          !_sameMuscleList(
            training.focusAreas,
            requested,
          )) {
        training = training.copyWith(
          focusAreas: requested,
        );

        changed = true;
      }
    }

    //-----------------------------------------------------------------------
    // Equipment
    //-----------------------------------------------------------------------

    final newEquipment = options['newEquipment'] as String?;

    if (newEquipment != null) {
      final equipment = EquipmentTypeExtension.fromValue(
        newEquipment,
      );

      if (!training.equipment.contains(
        equipment,
      )) {
        training = training.copyWith(
          equipment: [
            ...training.equipment,
            equipment,
          ],
        );

        changed = true;
      }
    }

    //-----------------------------------------------------------------------
    // Avoided muscles
    //-----------------------------------------------------------------------

    final avoidRaw = options['avoidMuscles'];

    if (avoidRaw is List && avoidRaw.isNotEmpty) {
      final extra = avoidRaw
          .map(
            (value) => MuscleGroupExtension.fromValue(
              value.toString(),
            ),
          )
          .toSet()
          .toList();

      final merged = {
        ...training.avoidedMuscles,
        ...extra,
      }.toList();

      if (!_sameMuscleList(
        training.avoidedMuscles,
        merged,
      )) {
        training = training.copyWith(
          avoidedMuscles: merged,
        );

        changed = true;
      }
    }

    //-----------------------------------------------------------------------
    // Return original profile when nothing changed.
    //-----------------------------------------------------------------------

    if (!changed) {
      return profile;
    }

    return profile.copyWith(
      training: training,
    );
  }

  //===========================================================================
  // Option parsing
  //===========================================================================

  List<MuscleGroup>? _parseExcludeMuscles(
    Map<String, dynamic> options,
  ) {
    final raw = options['avoidMuscles'];

    if (raw is! List) {
      return null;
    }

    final muscles = raw
        .map(
          (value) => MuscleGroupExtension.fromValue(
            value.toString(),
          ),
        )
        .toSet()
        .toList();

    return muscles.isEmpty ? null : muscles;
  }

  String? _intensityString(
    Map<String, dynamic> options,
  ) {
    return options['intensity'] as String?;
  }

  //===========================================================================
  // Utilities
  //===========================================================================

  bool _sameMuscleList(
    List<MuscleGroup> first,
    List<MuscleGroup> second,
  ) {
    final firstSet = first.toSet();
    final secondSet = second.toSet();

    return firstSet.length == secondSet.length &&
        firstSet.containsAll(secondSet);
  }
}

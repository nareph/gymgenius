import 'package:gymgenius/domain/entities/exercise.dart';
import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/engines/workout_engine/generators/split_generator.dart';
import 'package:gymgenius/engines/workout_engine/generators/workout_day_generator.dart';
import 'package:gymgenius/engines/workout_engine/models/muscle_split.dart';
import 'package:gymgenius/engines/workout_engine/services/generation_service.dart';
import 'package:gymgenius/engines/workout_engine/shared/workout_constants.dart';
import 'package:gymgenius/core/logger/logger_service.dart';

import '../../../domain/enums/exports.dart';

/// Handles program regeneration with specific options.
///
/// `options` comes from `RegenerationOptions.toMap()`
/// (regeneration_options_sheet.dart). Dispatch is on `options['type']`,
/// one of the 4 `RegenerationType` values:
///
/// - `'specificDay'` (+ `targetDay`): regenerates ONLY that day.
/// - `'singleExercise'` (+ `targetDay` + `targetExerciseId`): replaces
///   ONE exercise within that day.
/// - `'fullProgram'` / `'withPreferences'`: regenerates every day.
///   `keepStructure` (always present, default true in the UI) decides
///   HOW: `true` reuses the previous program's exact day list, per-day
///   split, and per-day exercise count (only exercise SELECTION
///   changes — e.g. equipment changed); `false` recomputes everything
///   from scratch via [GenerationService].
class RegenerationService {
  final GenerationService _generationService;
  final WorkoutDayGenerator _dayGenerator;
  static const _tag = 'RegenerationService';

  RegenerationService({
    GenerationService? generationService,
    WorkoutDayGenerator? dayGenerator,
  })  : _generationService = generationService ?? GenerationService(),
        _dayGenerator = dayGenerator ?? WorkoutDayGenerator();

  Future<TrainingProgram> regenerate({
    required HealthProfile profile,
    required TrainingProgram previousProgram,
    required Map<String, dynamic> options,
  }) async {
    final type = options['type'] as String?;
    Log.debug('regenerate() dispatching on type="$type", options: $options',
        tag: _tag);

    if (type == 'specificDay') {
      final targetDay = options['targetDay'] as String?;
      if (targetDay == null) {
        Log.warning(
            'type=specificDay but targetDay is missing — returning program unchanged.',
            tag: _tag);
        return previousProgram;
      }
      Log.debug('-> _regenerateSingleDay', tag: _tag);
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
            tag: _tag);
        return previousProgram;
      }
      Log.debug('-> _regenerateSingleExercise', tag: _tag);
      return _regenerateSingleExercise(
        profile: profile,
        previousProgram: previousProgram,
        targetDay: targetDay.toLowerCase(),
        targetExerciseId: targetExerciseId,
        options: options,
      );
    }

    // 'fullProgram', 'withPreferences', or anything unrecognized.
    Log.debug('-> _regenerateFullProgram', tag: _tag);
    return _regenerateFullProgram(
      profile: profile,
      previousProgram: previousProgram,
      options: options,
    );
  }

  // ------------------------------------------------------------------
  // Single-day regeneration
  // ------------------------------------------------------------------

  Future<TrainingProgram> _regenerateSingleDay({
    required HealthProfile profile,
    required TrainingProgram previousProgram,
    required String targetDay,
    required Map<String, dynamic> options,
  }) async {
    final split = _findSplitForDay(profile, targetDay);
    if (split == null) {
      Log.warning(
          '"$targetDay" is not a scheduled workout day in the current split '
          '— nothing to regenerate, returning the program unchanged.',
          tag: _tag);
      return previousProgram;
    }

    final adjustedProfile = _profileWithAdjustments(profile, options);

    final newDayExercises = _dayGenerator.generate(
      split: split,
      profile: adjustedProfile,
      previousProgram: previousProgram,
      excludeMuscles: _parseExcludeMuscles(options),
      intensityOverride: _intensityString(options),
    );

    final updatedSchedule =
        Map<String, List<Exercise>>.from(previousProgram.weeklySchedule);
    updatedSchedule[targetDay] = newDayExercises;

    Log.debug(
        'Regenerated only "$targetDay" (${newDayExercises.length} exercises), '
        'all other days kept as-is.',
        tag: _tag);

    return previousProgram.copyWith(weeklySchedule: updatedSchedule);
  }

  // ------------------------------------------------------------------
  // Single-exercise regeneration
  // ------------------------------------------------------------------

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
          '"$targetDay" has no exercises to replace — returning program unchanged.',
          tag: _tag);
      return previousProgram;
    }

    final targetIndex =
        _findTargetExerciseIndex(dayExercises, targetExerciseId);
    if (targetIndex == -1) {
      Log.warning(
          'Could not find exercise "$targetExerciseId" on "$targetDay" '
          '— returning program unchanged.',
          tag: _tag);
      return previousProgram;
    }

    final split = _findSplitForDay(profile, targetDay);
    if (split == null) {
      Log.warning(
          '"$targetDay" is not a scheduled workout day in the current split '
          '— returning program unchanged.',
          tag: _tag);
      return previousProgram;
    }

    final adjustedProfile = _profileWithAdjustments(profile, options);

    final replacementDay = _dayGenerator.generate(
      split: split,
      profile: adjustedProfile,
      previousProgram: previousProgram,
      excludeMuscles: _parseExcludeMuscles(options),
      intensityOverride: _intensityString(options),
      desiredCountOverride: 1,
    );

    if (replacementDay.isEmpty) {
      Log.warning(
          'No replacement exercise found for "$targetDay" (equipment/exclusions '
          'may be too restrictive) — returning program unchanged.',
          tag: _tag);
      return previousProgram;
    }

    final updatedDayExercises = List<Exercise>.from(dayExercises);
    updatedDayExercises[targetIndex] = replacementDay.first;

    final updatedSchedule =
        Map<String, List<Exercise>>.from(previousProgram.weeklySchedule);
    updatedSchedule[targetDay] = updatedDayExercises;

    Log.debug(
        'Replaced exercise at index $targetIndex on "$targetDay" '
        '("${dayExercises[targetIndex].name}" -> "${replacementDay.first.name}"). '
        'Day exercise count: ${updatedDayExercises.length} (unchanged).',
        tag: _tag);

    return previousProgram.copyWith(weeklySchedule: updatedSchedule);
  }

  int _findTargetExerciseIndex(
    List<Exercise> dayExercises,
    String targetExerciseId,
  ) {
    final byId = dayExercises.indexWhere((e) => e.id == targetExerciseId);
    if (byId != -1) return byId;

    final match = RegExp(r'^exercise_(\d+)$').firstMatch(targetExerciseId);
    if (match != null) {
      final index = int.tryParse(match.group(1)!);
      if (index != null && index >= 0 && index < dayExercises.length) {
        return index;
      }
    }

    return -1;
  }

  // ------------------------------------------------------------------
  // Full-program regeneration
  // ------------------------------------------------------------------

  Future<TrainingProgram> _regenerateFullProgram({
    required HealthProfile profile,
    required TrainingProgram previousProgram,
    required Map<String, dynamic> options,
  }) async {
    final adjustedProfile = _profileWithAdjustments(profile, options);
    final keepStructure = options['keepStructure'] as bool? ?? true;

    Log.debug('_regenerateFullProgram: keepStructure=$keepStructure',
        tag: _tag);

    if (!keepStructure) {
      Log.debug('-> from-scratch regeneration via GenerationService',
          tag: _tag);
      return _generationService.generate(
        profile: adjustedProfile,
        previousProgram: previousProgram,
        options: options,
      );
    }

    Log.debug('-> _regenerateKeepingStructure', tag: _tag);
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
    final training = profile.training;

    final workoutDays = previousProgram.weeklySchedule.entries
        .where((e) => e.value.isNotEmpty)
        .map((e) => e.key)
        .toList();

    if (workoutDays.isEmpty) {
      Log.warning(
          'previousProgram has no workout days to preserve — falling back '
          'to a full from-scratch regeneration.',
          tag: _tag);
      return _generationService.generate(
        profile: profile,
        previousProgram: previousProgram,
        options: options,
      );
    }

    final selectedSplit = SplitGenerator.determineMuscleSplit(
      workoutDays.length,
      training.experience.value,
    );

    final updatedSchedule = <String, List<Exercise>>{
      for (final day in WorkoutConstants.daysOfWeek) day: <Exercise>[],
    };

    final excludeMuscles = _parseExcludeMuscles(options);
    final intensityOverride = _intensityString(options);

    for (var i = 0; i < workoutDays.length && i < selectedSplit.length; i++) {
      final day = workoutDays[i];
      final desiredCount = previousProgram.weeklySchedule[day]!.length;

      updatedSchedule[day] = _dayGenerator.generate(
        split: selectedSplit[i],
        profile: profile,
        previousProgram: previousProgram,
        excludeMuscles: excludeMuscles,
        intensityOverride: intensityOverride,
        desiredCountOverride: desiredCount,
      );
    }

    Log.debug(
        'Regenerated all ${workoutDays.length} days keeping structure '
        '(same days: $workoutDays, same per-day exercise counts), '
        'new equipment/profile applied.',
        tag: _tag);

    return previousProgram.copyWith(weeklySchedule: updatedSchedule);
  }

  // ------------------------------------------------------------------
  // Shared helpers
  // ------------------------------------------------------------------

  MuscleSplit? _findSplitForDay(HealthProfile profile, String targetDay) {
    final training = profile.training;

    final daysResult = SplitGenerator.calculateWorkoutDays(
      frequency: _frequencyValue(training.frequency),
      preferredDays: training.preferredDays.map((d) => d.value).toList(),
    );

    final workoutDays =
        (daysResult.useSpecifiedDays && training.preferredDays.isNotEmpty)
            ? training.preferredDays.map((d) => d.value).toList()
            : WorkoutConstants.defaultWorkoutDays(daysResult.count);

    final selectedSplit = SplitGenerator.determineMuscleSplit(
      daysResult.count,
      training.experience.value,
    );

    final dayIndex = workoutDays.indexOf(targetDay);
    if (dayIndex == -1 || dayIndex >= selectedSplit.length) return null;

    return selectedSplit[dayIndex];
  }

  HealthProfile _profileWithAdjustments(
    HealthProfile profile,
    Map<String, dynamic> options,
  ) {
    var training = profile.training;
    var changed = false;

    final focusRaw = options['focusMuscles'];
    if (focusRaw is List && focusRaw.isNotEmpty) {
      final requested =
          focusRaw.map((v) => MuscleGroupExtension.fromValue(v.toString()));
      training = training.copyWith(
        focusAreas: {...training.focusAreas, ...requested}.toList(),
      );
      changed = true;
    }

    final newEquipment = options['newEquipment'] as String?;
    if (newEquipment != null) {
      final equipment = EquipmentTypeExtension.fromValue(newEquipment);
      if (!training.equipment.contains(equipment)) {
        training = training.copyWith(
          equipment: [...training.equipment, equipment],
        );
        changed = true;
      }
    }

    if (!changed) return profile;
    return profile.copyWith(training: training);
  }

  List<MuscleGroup>? _parseExcludeMuscles(Map<String, dynamic> options) {
    final raw = options['avoidMuscles'];
    if (raw is! List) return null;
    return raw
        .map((v) => MuscleGroupExtension.fromValue(v.toString()))
        .toList();
  }

  String? _intensityString(Map<String, dynamic> options) {
    return options['intensity'] as String?;
  }

  String _frequencyValue(WorkoutFrequency frequency) {
    switch (frequency) {
      case WorkoutFrequency.oneToTwo:
        return '1-2';
      case WorkoutFrequency.threeToFour:
        return '3-4';
      case WorkoutFrequency.fivePlus:
        return '5-plus';
    }
  }
}

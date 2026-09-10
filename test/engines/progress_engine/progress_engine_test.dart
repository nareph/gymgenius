import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/domain/entities/daily_checkin.dart';
import 'package:gymgenius/domain/entities/logged_exercise.dart';
import 'package:gymgenius/domain/entities/logged_set.dart';
import 'package:gymgenius/domain/entities/today_workout.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/domain/entities/workout_log.dart';
import 'package:gymgenius/domain/enums/energy_level.dart';
import 'package:gymgenius/domain/enums/experience_level.dart';
import 'package:gymgenius/domain/enums/fitness_goal.dart';
import 'package:gymgenius/domain/enums/generator_type.dart';
import 'package:gymgenius/domain/enums/program_phase.dart';
import 'package:gymgenius/domain/enums/progress_period.dart';
import 'package:gymgenius/domain/enums/soreness_level.dart';
import 'package:gymgenius/domain/enums/split_type.dart';
import 'package:gymgenius/engines/decision_engine/Progression/deload_planner.dart';
import 'package:gymgenius/engines/decision_engine/Progression/mesocycle_planner.dart';
import 'package:gymgenius/engines/decision_engine/Progression/week_progression_calculator.dart';
import 'package:gymgenius/engines/decision_engine/models/decision_context.dart';
import 'package:gymgenius/engines/decision_engine/models/program_progress.dart';
import 'package:gymgenius/engines/decision_engine/rules/progress_rule.dart';
import 'package:gymgenius/engines/progress_engine/progress_engine.dart';

import '../nutrition_engine/calorie_macro_test.dart';

TrainingProgram _program() {
  final now = DateTime(2026, 8, 11);
  return TrainingProgram(
    id: 'p1',
    userId: 'u1',
    name: 'Stub',
    goal: FitnessGoal.buildMuscle,
    split: SplitType.pushPullLegs,
    experience: ExperienceLevel.intermediate,
    durationWeeks: 12,
    weeklySchedule: const {},
    generatorType: GeneratorType.local,
    generatorVersion: '1.0',
    createdAt: now,
    expiresAt: now.add(const Duration(days: 84)),
  );
}

ProgramProgress _progress() {
  return const ProgramProgress(
    currentWeek: 1,
    totalWeeks: 12,
    currentPhase: ProgramPhase.base,
    mesocycleInfo: MesocycleInfo(mesocycle: 1, microcycle: 1),
    weekProgression: WeekProgression(
      phase: ProgramPhase.base,
      volumeMultiplier: 1.0,
      intensityMultiplier: 1.0,
      targetRpe: 7.0,
      isDeload: false,
    ),
    deloadPlan: DeloadPlan(
      isDeload: false,
      volumeMultiplier: 1.0,
      intensityMultiplier: 1.0,
    ),
    weeksRemaining: 11,
    completion: 0.0,
  );
}

void main() {
  const engine = ProgressEngine();
  const progressRule = ProgressRule();
  final now = DateTime(2026, 8, 11);

  group('ProgressEngine', () {
    test('produces snapshot with sufficient weight and workout data', () {
      final checkIns = List.generate(
        5,
        (i) => DailyCheckIn(
          userId: 'u1',
          date: now.subtract(Duration(days: 10 - i * 2)),
          sleepHours: 7,
          sorenessLevel: SorenessLevel.none,
          energyLevel: EnergyLevel.high,
          mood: 4,
          weightKg: 80 - i * 0.3,
        ),
      );

      final logs = [
        WorkoutLog(
          id: 'w1',
          userId: 'u1',
          programId: 'p1',
          week: 1,
          day: 'monday',
          startedAt: now.subtract(const Duration(days: 7)),
          endedAt: now.subtract(const Duration(days: 7)),
          durationSeconds: 3600,
          completionScore: 100,
          exercises: [
            LoggedExercise(
              exerciseId: 'squat',
              name: 'Squat',
              targetSets: 3,
              targetReps: '5',
              targetRestSeconds: 120,
              isTimed: false,
              sets: [
                LoggedSet(
                  setNumber: 1,
                  reps: 5,
                  weightKg: 100,
                  loggedAt: now,
                ),
              ],
              completed: true,
            ),
          ],
          savedAt: now.subtract(const Duration(days: 7)),
        ),
        WorkoutLog(
          id: 'w2',
          userId: 'u1',
          programId: 'p1',
          week: 1,
          day: 'wednesday',
          startedAt: now,
          endedAt: now,
          durationSeconds: 3600,
          completionScore: 100,
          exercises: [
            LoggedExercise(
              exerciseId: 'squat',
              name: 'Squat',
              targetSets: 3,
              targetReps: '5',
              targetRestSeconds: 120,
              isTimed: false,
              sets: [
                LoggedSet(
                  setNumber: 1,
                  reps: 5,
                  weightKg: 105,
                  loggedAt: now,
                ),
              ],
              completed: true,
            ),
          ],
          savedAt: now,
        ),
      ];

      // NEW: targetPerWeek = 4 (WorkoutFrequency.threeToFour.toDays())
      const targetPerWeek = 4;

      final snapshot = engine.computeSnapshot(
        userId: 'u1',
        now: now,
        period: ProgressPeriod.weekly,
        checkIns: checkIns,
        workoutLogs: logs,
        targetPerWeek: targetPerWeek,
        targetWeightKg: 75,
      );

      expect(snapshot.hasSufficientData, isTrue);
      expect(snapshot.weightTrend?.hasSufficientData, isTrue);
      expect(snapshot.strengthProgress?.hasSufficientData, isTrue);
      expect(snapshot.consistency?.hasSufficientData, isTrue);
      expect(snapshot.reasons, isNotEmpty);
    });

    test('handles new user with no history', () {
      const targetPerWeek = 4;

      final snapshot = engine.computeSnapshot(
        userId: 'u1',
        now: now,
        checkIns: const [],
        workoutLogs: const [],
        targetPerWeek: targetPerWeek,
      );

      expect(snapshot.hasSufficientData, isFalse);
      expect(snapshot.reasons.first, contains('Insufficient'));
    });
  });

  group('ProgressRule', () {
    test('is observe-only and never adapts workout', () {
      final decision = progressRule.evaluate(
        DecisionContext(
          now: now,
          healthProfile: buildTestProfile(),
          trainingProgram: _program(),
          programProgress: _progress(),
          todayWorkout: TodayWorkout(
            date: now,
            dayKey: 'tuesday',
            plannedExercises: const [],
            finalExercises: const [],
            splitDisplayName: '',
          ),
        ),
      );
      expect(decision.requiresAdaptation, isFalse);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/domain/entities/progress_snapshot.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/domain/entities/workout_consistency.dart';
import 'package:gymgenius/domain/enums/experience_level.dart';
import 'package:gymgenius/domain/enums/fitness_goal.dart';
import 'package:gymgenius/domain/enums/generator_type.dart';
import 'package:gymgenius/domain/enums/progress_period.dart';
import 'package:gymgenius/domain/enums/program_phase.dart';
import 'package:gymgenius/domain/enums/split_type.dart';
import 'package:gymgenius/domain/enums/trend_direction.dart';
import 'package:gymgenius/engines/decision_engine/Progression/deload_planner.dart';
import 'package:gymgenius/engines/decision_engine/Progression/mesocycle_planner.dart';
import 'package:gymgenius/engines/decision_engine/Progression/week_progression_calculator.dart';
import 'package:gymgenius/engines/decision_engine/models/program_progress.dart';
import 'package:gymgenius/engines/decision_engine/policies/program_refresh_policy.dart';

TrainingProgram _program({
  required DateTime createdAt,
  required DateTime expiresAt,
}) {
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
    createdAt: createdAt,
    expiresAt: expiresAt,
  );
}

ProgramProgress _progress({bool deload = false}) {
  return ProgramProgress(
    currentWeek: deload ? 4 : 3,
    totalWeeks: 12,
    currentPhase: ProgramPhase.base,
    mesocycleInfo: const MesocycleInfo(mesocycle: 1, microcycle: 3),
    weekProgression: WeekProgression(
      phase: ProgramPhase.base,
      volumeMultiplier: deload ? 0.7 : 1.0,
      intensityMultiplier: 1.0,
      targetRpe: 7.0,
      isDeload: deload,
    ),
    deloadPlan: DeloadPlan(
      isDeload: deload,
      volumeMultiplier: deload ? 0.7 : 1.0,
      intensityMultiplier: 1.0,
    ),
    weeksRemaining: 9,
    completion: 0.25,
  );
}

ProgressSnapshot _snapshot({
  int planned = 8,
  int completed = 7,
  bool plateau = false,
}) {
  final now = DateTime(2026, 8, 11);
  return ProgressSnapshot(
    userId: 'u1',
    computedAt: now,
    period: ProgressPeriod.weekly,
    consistency: WorkoutConsistency(
      plannedWorkouts: planned,
      completedWorkouts: completed,
      consistencyScore: planned == 0
          ? 0
          : ((completed / planned) * 100).round(),
      weeklyFrequency: 3,
      consecutiveTrainingDays: 1,
      trend: TrendDirection.stable,
    ),
    weightPlateauDetected: plateau,
    strengthPlateauDetected: plateau,
  );
}

void main() {
  final now = DateTime(2026, 8, 11);

  group('ProgramRefreshPolicy', () {
    test('does not refresh a young healthy program', () {
      final decision = ProgramRefreshPolicy.evaluate(
        program: _program(
          createdAt: now.subtract(const Duration(days: 7)),
          expiresAt: now.add(const Duration(days: 77)),
        ),
        progress: _progress(),
        snapshot: _snapshot(plateau: true),
        now: now,
      );
      expect(decision.shouldRegenerate, isFalse);
    });

    test('refreshes when the program is expired', () {
      final decision = ProgramRefreshPolicy.evaluate(
        program: _program(
          createdAt: now.subtract(const Duration(days: 90)),
          expiresAt: now.subtract(const Duration(days: 1)),
        ),
        progress: _progress(),
        now: now,
      );
      expect(decision.shouldRegenerate, isTrue);
      expect(decision.reason, ProgramRefreshReason.expired);
    });

    test('refreshes on low consistency after the cooldown', () {
      final decision = ProgramRefreshPolicy.evaluate(
        program: _program(
          createdAt: now.subtract(const Duration(days: 21)),
          expiresAt: now.add(const Duration(days: 63)),
        ),
        progress: _progress(),
        snapshot: _snapshot(planned: 8, completed: 2),
        now: now,
      );
      expect(decision.shouldRegenerate, isTrue);
      expect(decision.reason, ProgramRefreshReason.lowConsistency);
    });

    test('refreshes on plateau with sufficient data after cooldown', () {
      final decision = ProgramRefreshPolicy.evaluate(
        program: _program(
          createdAt: now.subtract(const Duration(days: 21)),
          expiresAt: now.add(const Duration(days: 63)),
        ),
        progress: _progress(),
        snapshot: _snapshot(plateau: true),
        now: now,
      );
      expect(decision.shouldRegenerate, isTrue);
      expect(decision.reason, ProgramRefreshReason.plateau);
    });

    test('does not refresh for plateau during a deload week', () {
      final decision = ProgramRefreshPolicy.evaluate(
        program: _program(
          createdAt: now.subtract(const Duration(days: 21)),
          expiresAt: now.add(const Duration(days: 63)),
        ),
        progress: _progress(deload: true),
        snapshot: _snapshot(plateau: true),
        now: now,
      );
      expect(decision.shouldRegenerate, isFalse);
    });
  });
}

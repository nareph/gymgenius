import 'package:gymgenius/data/datasources/local/hive/models/blood_glucose_hive_model.dart';
import 'package:gymgenius/data/datasources/local/hive/models/blood_pressure_hive_model.dart';
import 'package:gymgenius/data/datasources/local/hive/models/habit_hive_model.dart';
import 'package:gymgenius/data/datasources/local/hive/models/habit_log_hive_model.dart';
import 'package:gymgenius/data/datasources/local/hive/models/hydration_log_hive_model.dart';
import 'package:gymgenius/data/datasources/local/hive/models/mental_wellness_hive_model.dart';
import 'package:gymgenius/domain/entities/blood_glucose_reading.dart';
import 'package:gymgenius/domain/entities/blood_pressure_reading.dart';
import 'package:gymgenius/domain/entities/habit.dart';
import 'package:gymgenius/domain/entities/habit_log.dart';
import 'package:gymgenius/domain/entities/hydration_log.dart';
import 'package:gymgenius/domain/entities/mental_wellness_checkin.dart';
import 'package:gymgenius/domain/enums/energy_level.dart';
import 'package:gymgenius/domain/enums/glucose_context.dart';
import 'package:gymgenius/domain/enums/habit_frequency.dart';
import 'package:gymgenius/domain/enums/stress_level.dart';

class HealthPlatformMapper {
  const HealthPlatformMapper._();

  static BloodPressureReading toBloodPressure(BloodPressureHiveModel m) =>
      BloodPressureReading(
        id: m.id,
        userId: m.userId,
        systolic: m.systolic,
        diastolic: m.diastolic,
        heartRateBpm: m.heartRateBpm,
        measuredAt: m.measuredAt,
        note: m.note,
      );

  static BloodPressureHiveModel fromBloodPressure(BloodPressureReading e) =>
      BloodPressureHiveModel(
        id: e.id,
        userId: e.userId,
        systolic: e.systolic,
        diastolic: e.diastolic,
        heartRateBpm: e.heartRateBpm,
        measuredAt: e.measuredAt,
        note: e.note,
      );

  static BloodGlucoseReading toBloodGlucose(BloodGlucoseHiveModel m) =>
      BloodGlucoseReading(
        id: m.id,
        userId: m.userId,
        valueMmolL: m.valueMmolL,
        context: GlucoseContextExtension.fromValue(m.context),
        measuredAt: m.measuredAt,
        note: m.note,
      );

  static BloodGlucoseHiveModel fromBloodGlucose(BloodGlucoseReading e) =>
      BloodGlucoseHiveModel(
        id: e.id,
        userId: e.userId,
        valueMmolL: e.valueMmolL,
        context: e.context.value,
        measuredAt: e.measuredAt,
        note: e.note,
      );

  static HydrationLog toHydration(HydrationLogHiveModel m) => HydrationLog(
        id: m.id,
        userId: m.userId,
        amountMl: m.amountMl,
        loggedAt: m.loggedAt,
        note: m.note,
      );

  static HydrationLogHiveModel fromHydration(HydrationLog e) =>
      HydrationLogHiveModel(
        id: e.id,
        userId: e.userId,
        amountMl: e.amountMl,
        loggedAt: e.loggedAt,
        note: e.note,
      );

  static MentalWellnessCheckIn toMental(MentalWellnessHiveModel m) =>
      MentalWellnessCheckIn(
        id: m.id,
        userId: m.userId,
        date: m.date,
        mood: m.mood,
        stress: StressLevelExtension.fromValue(m.stress),
        energy: EnergyLevelExtension.fromValue(m.energy),
        notes: m.notes,
      );

  static MentalWellnessHiveModel fromMental(MentalWellnessCheckIn e) =>
      MentalWellnessHiveModel(
        id: e.id,
        userId: e.userId,
        date: e.date,
        mood: e.mood,
        stress: e.stress.value,
        energy: e.energy.value,
        notes: e.notes,
      );

  static Habit toHabit(HabitHiveModel m) => Habit(
        id: m.id,
        userId: m.userId,
        name: m.name,
        frequency: HabitFrequencyExtension.fromValue(m.frequency),
        isActive: m.isActive,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
      );

  static HabitHiveModel fromHabit(Habit e) => HabitHiveModel(
        id: e.id,
        userId: e.userId,
        name: e.name,
        frequency: e.frequency.value,
        isActive: e.isActive,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  static HabitLog toHabitLog(HabitLogHiveModel m) => HabitLog(
        id: m.id,
        userId: m.userId,
        habitId: m.habitId,
        date: m.date,
        completed: m.completed,
        loggedAt: m.loggedAt,
      );

  static HabitLogHiveModel fromHabitLog(HabitLog e) => HabitLogHiveModel(
        id: e.id,
        userId: e.userId,
        habitId: e.habitId,
        date: e.date,
        completed: e.completed,
        loggedAt: e.loggedAt,
      );
}

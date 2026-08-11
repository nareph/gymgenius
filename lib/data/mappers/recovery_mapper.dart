import 'package:gymgenius/data/datasources/local/hive/models/daily_checkin_hive_model.dart';
import 'package:gymgenius/data/datasources/local/hive/models/recovery_status_hive_model.dart';
import 'package:gymgenius/domain/entities/daily_checkin.dart';
import 'package:gymgenius/domain/entities/recovery_status.dart';
import 'package:gymgenius/domain/enums/energy_level.dart';
import 'package:gymgenius/domain/enums/recommended_intensity.dart';
import 'package:gymgenius/domain/enums/soreness_level.dart';

class RecoveryMapper {
  const RecoveryMapper._();

  static RecoveryStatus toStatusDomain(RecoveryStatusHiveModel model) {
    return RecoveryStatus(
      userId: model.userId,
      date: model.date,
      recoveryScore: model.recoveryScore,
      fatigueScore: model.fatigueScore,
      readinessScore: model.readinessScore,
      recommendedIntensity:
          RecommendedIntensityExtension.fromValue(model.recommendedIntensity),
      volumeMultiplier: model.volumeMultiplier,
      reasons: List<String>.from(model.reasons),
      generatedBy: model.generatedBy,
    );
  }

  static RecoveryStatusHiveModel toStatusHive(RecoveryStatus entity) {
    return RecoveryStatusHiveModel(
      userId: entity.userId,
      date: entity.date,
      recoveryScore: entity.recoveryScore,
      fatigueScore: entity.fatigueScore,
      readinessScore: entity.readinessScore,
      recommendedIntensity: entity.recommendedIntensity.value,
      volumeMultiplier: entity.volumeMultiplier,
      reasons: List<String>.from(entity.reasons),
      generatedBy: entity.generatedBy,
    );
  }

  static DailyCheckIn toCheckInDomain(DailyCheckInHiveModel model) {
    return DailyCheckIn(
      userId: model.userId,
      date: model.date,
      weightKg: model.weightKg,
      sleepHours: model.sleepHours,
      sorenessLevel: SorenessLevelExtension.fromValue(model.sorenessLevel),
      energyLevel: EnergyLevelExtension.fromValue(model.energyLevel),
      mood: model.mood,
    );
  }

  static DailyCheckInHiveModel toCheckInHive(DailyCheckIn entity) {
    return DailyCheckInHiveModel(
      userId: entity.userId,
      date: entity.date,
      weightKg: entity.weightKg,
      sleepHours: entity.sleepHours,
      sorenessLevel: entity.sorenessLevel.value,
      energyLevel: entity.energyLevel.value,
      mood: entity.mood,
    );
  }
}

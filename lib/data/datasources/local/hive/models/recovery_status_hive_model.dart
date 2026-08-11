import 'package:hive/hive.dart';

part 'recovery_status_hive_model.g.dart';

@HiveType(typeId: 13)
class RecoveryStatusHiveModel extends HiveObject {
  @HiveField(0)
  String userId;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  int recoveryScore;

  @HiveField(3)
  int fatigueScore;

  @HiveField(4)
  int readinessScore;

  /// Stored as string value from [RecommendedIntensity.value].
  @HiveField(5)
  String recommendedIntensity;

  @HiveField(6)
  double volumeMultiplier;

  @HiveField(7)
  List<String> reasons;

  @HiveField(8)
  String generatedBy;

  RecoveryStatusHiveModel({
    required this.userId,
    required this.date,
    required this.recoveryScore,
    required this.fatigueScore,
    required this.readinessScore,
    required this.recommendedIntensity,
    required this.volumeMultiplier,
    required this.reasons,
    required this.generatedBy,
  });
}

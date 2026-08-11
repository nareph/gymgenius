import 'package:hive/hive.dart';

part 'coach_cache_hive_model.g.dart';

/// Cached daily coaching or weekly summary payload.
@HiveType(typeId: 17)
class CoachCacheHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  /// `daily` or `weekly`
  @HiveField(2)
  String kind;

  @HiveField(3)
  DateTime periodStart;

  @HiveField(4)
  DateTime generatedAt;

  @HiveField(5)
  String responseJson;

  @HiveField(6)
  String providerId;

  CoachCacheHiveModel({
    required this.id,
    required this.userId,
    required this.kind,
    required this.periodStart,
    required this.generatedAt,
    required this.responseJson,
    required this.providerId,
  });
}

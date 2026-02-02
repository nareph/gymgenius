// lib/models/hive/routine_model.dart
import 'package:hive/hive.dart';

part 'routine_model.g.dart';

@HiveType(typeId: 1)
class RoutineModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String name;

  @HiveField(3)
  int durationInWeeks;

  @HiveField(4)
  Map<String, dynamic> dailyWorkouts;

  @HiveField(5)
  DateTime generatedAt;

  @HiveField(6)
  DateTime expiresAt;

  RoutineModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.durationInWeeks,
    required this.dailyWorkouts,
    required this.generatedAt,
    required this.expiresAt,
  });

  bool isExpired() => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'durationInWeeks': durationInWeeks,
      'dailyWorkouts': dailyWorkouts,
      'generatedAt': generatedAt.millisecondsSinceEpoch,
      'expiresAt': expiresAt.millisecondsSinceEpoch,
    };
  }

  factory RoutineModel.fromMap(Map<String, dynamic> map) {
    return RoutineModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      name: map['name'] as String,
      durationInWeeks: map['durationInWeeks'] as int,
      dailyWorkouts: map['dailyWorkouts'] as Map<String, dynamic>,
      generatedAt: DateTime.fromMillisecondsSinceEpoch(map['generatedAt'] as int),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(map['expiresAt'] as int),
    );
  }
}


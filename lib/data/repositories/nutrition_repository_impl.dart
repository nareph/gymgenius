import 'package:gymgenius/data/datasources/local/hive/boxes/hive_datasource.dart';
import 'package:gymgenius/data/mappers/nutrition_mapper.dart';
import 'package:gymgenius/domain/entities/nutrition_log.dart';
import 'package:gymgenius/domain/entities/nutrition_plan.dart';
import 'package:gymgenius/domain/entities/nutrition_profile.dart';
import 'package:gymgenius/domain/repositories/nutrition_repository.dart';

class NutritionRepositoryImpl implements NutritionRepository {
  const NutritionRepositoryImpl();

  @override
  Future<NutritionProfile?> getCurrentNutritionProfile(String userId) async {
    final model = HiveDatasource.getNutritionProfile(userId);
    if (model == null) return null;
    return NutritionMapper.toProfileDomain(model);
  }

  @override
  Future<void> saveNutritionProfile(NutritionProfile profile) async {
    await HiveDatasource.saveNutritionProfile(
      NutritionMapper.toProfileHive(profile),
    );
  }

  @override
  Future<void> deleteNutritionProfile(String userId) async {
    await HiveDatasource.deleteNutritionProfile(userId);
  }

  @override
  Future<NutritionPlan?> getPlanForDate(String userId, DateTime date) async {
    final key = NutritionMapper.planKey(userId, date);
    final model = HiveDatasource.getNutritionPlan(key);
    if (model == null) return null;
    return NutritionMapper.toPlanDomain(model);
  }

  @override
  Future<void> savePlan(NutritionPlan plan) async {
    await HiveDatasource.saveNutritionPlan(NutritionMapper.toPlanHive(plan));
  }

  @override
  Future<void> deletePlansForUser(String userId) async {
    await HiveDatasource.deleteNutritionPlansForUser(userId);
  }

  @override
  Future<void> saveNutritionLog(NutritionLog log) async {
    await HiveDatasource.saveNutritionLog(NutritionMapper.toLogHive(log));
  }

  @override
  Future<List<NutritionLog>> getNutritionLogsForDay(
    String userId,
    DateTime day,
  ) async {
    return HiveDatasource.getNutritionLogsForDay(userId, day)
        .map(NutritionMapper.toLogDomain)
        .toList();
  }

  @override
  Future<List<NutritionLog>> getNutritionLogHistory(String userId) async {
    return HiveDatasource.getNutritionLogs(userId)
        .map(NutritionMapper.toLogDomain)
        .toList();
  }

  @override
  Future<void> deleteNutritionLog(String id) async {
    await HiveDatasource.deleteNutritionLog(id);
  }

  @override
  Future<void> deleteNutritionLogsForUser(String userId) async {
    await HiveDatasource.deleteNutritionLogsForUser(userId);
  }
}

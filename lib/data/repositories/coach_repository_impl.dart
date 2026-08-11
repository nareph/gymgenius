import 'package:gymgenius/data/datasources/local/hive/boxes/hive_datasource.dart';
import 'package:gymgenius/data/mappers/coach_mapper.dart';
import 'package:gymgenius/domain/entities/weekly_progress_report.dart';
import 'package:gymgenius/domain/repositories/coach_repository.dart';
import 'package:gymgenius/engines/ai_coach/models/coach_response.dart';
import 'package:gymgenius/engines/ai_coach/models/conversation.dart';
import 'package:gymgenius/engines/decision_engine/models/daily_plan.dart';

class CoachRepositoryImpl implements CoachRepository {
  const CoachRepositoryImpl();

  @override
  Future<Conversation?> getLatestConversation(String userId) async {
    final model = HiveDatasource.getLatestConversation(userId);
    if (model == null) return null;
    return CoachMapper.toConversation(model);
  }

  @override
  Future<Conversation> getOrCreateConversation(String userId) async {
    final existing = await getLatestConversation(userId);
    if (existing != null) return existing;

    final now = DateTime.now();
    final conversation = Conversation(
      id: '${userId}_coach_${now.millisecondsSinceEpoch}',
      userId: userId,
      createdAt: now,
      updatedAt: now,
    );
    await saveConversation(conversation);
    return conversation;
  }

  @override
  Future<void> saveConversation(Conversation conversation) async {
    await HiveDatasource.saveConversation(
      CoachMapper.fromConversation(conversation),
    );
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    await HiveDatasource.deleteConversation(conversationId);
  }

  DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

  String _dailyId(String userId, DateTime day) {
    final d = _dayKey(day);
    return '${userId}_daily_${d.toIso8601String()}';
  }

  String _weeklyId(String userId, DateTime weekStart) {
    final d = _dayKey(weekStart);
    return '${userId}_weekly_${d.toIso8601String()}';
  }

  @override
  Future<CoachResponse?> getDailyCoaching(String userId, DateTime day) async {
    final model = HiveDatasource.getCoachCache(_dailyId(userId, day));
    if (model == null) return null;
    return CoachMapper.toCoachResponse(model);
  }

  @override
  Future<void> saveDailyCoaching(
    String userId,
    DateTime day,
    CoachResponse response,
  ) async {
    final model = CoachMapper.fromCoachResponse(
      id: _dailyId(userId, day),
      userId: userId,
      kind: 'daily',
      periodStart: _dayKey(day),
      response: response,
    );
    await HiveDatasource.saveCoachCache(model);
  }

  @override
  Future<CoachResponse?> getWeeklySummary(
    String userId,
    DateTime weekStart,
  ) async {
    final model = HiveDatasource.getCoachCache(_weeklyId(userId, weekStart));
    if (model == null) return null;
    return CoachMapper.toCoachResponse(model);
  }

  @override
  Future<void> saveWeeklySummary(
    String userId,
    DateTime weekStart,
    CoachResponse response,
  ) async {
    final model = CoachMapper.fromCoachResponse(
      id: _weeklyId(userId, weekStart),
      userId: userId,
      kind: 'weekly',
      periodStart: _dayKey(weekStart),
      response: response,
    );
    await HiveDatasource.saveCoachCache(model);
  }

  @override
  Future<CoachResponse> getOrCreateDailyCoaching({
    required String userId,
    required DailyPlan plan,
    required Future<CoachResponse> Function() generate,
  }) async {
    final day = _dayKey(plan.generatedAt);
    final cached = await getDailyCoaching(userId, day);
    if (cached != null) return cached;

    final fresh = await generate();
    await saveDailyCoaching(userId, day, fresh);
    return fresh;
  }

  @override
  Future<CoachResponse> getOrCreateWeeklySummary({
    required String userId,
    required DateTime weekStart,
    required WeeklyProgressReport report,
    required Future<CoachResponse> Function() generate,
  }) async {
    final cached = await getWeeklySummary(userId, weekStart);
    if (cached != null) return cached;

    final fresh = await generate();
    await saveWeeklySummary(userId, weekStart, fresh);
    return fresh;
  }
}

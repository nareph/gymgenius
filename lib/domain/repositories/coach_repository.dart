import 'package:gymgenius/domain/entities/weekly_progress_report.dart';
import 'package:gymgenius/engines/ai_coach/models/coach_response.dart';
import 'package:gymgenius/engines/ai_coach/models/conversation.dart';
import 'package:gymgenius/engines/decision_engine/models/daily_plan.dart';

/// Persistence for AI Coach conversations and cached coaching responses.
abstract interface class CoachRepository {
  Future<Conversation?> getLatestConversation(String userId);

  Future<Conversation> getOrCreateConversation(String userId);

  Future<void> saveConversation(Conversation conversation);

  Future<void> deleteConversation(String conversationId);

  Future<CoachResponse?> getDailyCoaching(String userId, DateTime day);

  Future<void> saveDailyCoaching(
    String userId,
    DateTime day,
    CoachResponse response,
  );

  Future<CoachResponse?> getWeeklySummary(String userId, DateTime weekStart);

  Future<void> saveWeeklySummary(
    String userId,
    DateTime weekStart,
    CoachResponse response,
  );

  /// Convenience: generate via engine if missing, then cache.
  Future<CoachResponse> getOrCreateDailyCoaching({
    required String userId,
    required DailyPlan plan,
    required Future<CoachResponse> Function() generate,
  });

  Future<CoachResponse> getOrCreateWeeklySummary({
    required String userId,
    required DateTime weekStart,
    required WeeklyProgressReport report,
    required Future<CoachResponse> Function() generate,
  });
}

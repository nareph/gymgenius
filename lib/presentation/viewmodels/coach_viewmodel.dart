import 'package:flutter/foundation.dart';
import 'package:gymgenius/core/logger/logger_service.dart';
import 'package:gymgenius/domain/entities/weekly_progress_report.dart';
import 'package:gymgenius/domain/repositories/coach_repository.dart';
import 'package:gymgenius/domain/repositories/progress_repository.dart';
import 'package:gymgenius/domain/repositories/user_repository.dart';
import 'package:gymgenius/engines/ai_coach/ai_coach_engine.dart';
import 'package:gymgenius/engines/ai_coach/ai_config.dart';
import 'package:gymgenius/engines/ai_coach/models/coach_response.dart';
import 'package:gymgenius/engines/ai_coach/models/conversation.dart';
import 'package:gymgenius/engines/decision_engine/models/daily_plan.dart';

enum CoachUiState { initial, loading, ready, error }

class CoachViewModel extends ChangeNotifier {
  final AICoachEngine _engine;
  final CoachRepository _coachRepository;
  final ProgressRepository _progressRepository;
  final UserRepository _userRepository;

  CoachViewModel({
    required AICoachEngine engine,
    required CoachRepository coachRepository,
    required ProgressRepository progressRepository,
    required UserRepository userRepository,
  })  : _engine = engine,
        _coachRepository = coachRepository,
        _progressRepository = progressRepository,
        _userRepository = userRepository;

  CoachUiState _state = CoachUiState.initial;
  CoachUiState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  CoachResponse? _daily;
  CoachResponse? get daily => _daily;

  CoachResponse? _weekly;
  CoachResponse? get weekly => _weekly;

  WeeklyProgressReport? _weeklyReport;
  WeeklyProgressReport? get weeklyReport => _weeklyReport;

  Conversation? _conversation;
  Conversation? get conversation => _conversation;

  bool _sending = false;
  bool get sending => _sending;

  bool get isOfflineMode => !AIConfig.canUseCoachCloud;

  DailyPlan? _plan;

  Future<void> bootstrap(DailyPlan? plan) async {
    _plan = plan;
    _state = CoachUiState.loading;
    notifyListeners();

    try {
      final user = await _userRepository.getCurrentUser();
      if (user == null) {
        throw Exception('Not authenticated');
      }

      _conversation = await _coachRepository.getOrCreateConversation(user.id);

      if (plan != null) {
        _daily = await _coachRepository.getOrCreateDailyCoaching(
          userId: user.id,
          plan: plan,
          generate: () => _engine.generateDailyCoaching(plan),
        );

        final weekStart = _mondayOf(DateTime.now());
        _weeklyReport =
            await _progressRepository.computeWeeklyReport(user.id, weekStart: weekStart);
        _weekly = await _coachRepository.getOrCreateWeeklySummary(
          userId: user.id,
          weekStart: weekStart,
          report: _weeklyReport!,
          generate: () => _engine.generateWeeklySummary(
            plan: plan,
            report: _weeklyReport!,
          ),
        );
      }

      _state = CoachUiState.ready;
    } catch (e, s) {
      Log.error('CoachViewModel bootstrap failed', error: e, stackTrace: s);
      _errorMessage = e.toString();
      _state = CoachUiState.error;
    }
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    final plan = _plan;
    final conversation = _conversation;
    if (plan == null || conversation == null || text.trim().isEmpty) return;

    _sending = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final userMsg = ConversationMessage(
        id: 'u_${now.millisecondsSinceEpoch}',
        role: CoachMessageRole.user,
        content: text.trim(),
        timestamp: now,
      );

      var updated = conversation.copyWith(
        messages: [...conversation.messages, userMsg],
        updatedAt: now,
      );

      final response = await _engine.chat(
        plan: plan,
        question: text.trim(),
        history: updated.messages,
      );

      final assistantMsg = ConversationMessage(
        id: 'a_${DateTime.now().millisecondsSinceEpoch}',
        role: CoachMessageRole.assistant,
        content: response.message,
        timestamp: DateTime.now(),
      );

      updated = updated.copyWith(
        messages: [...updated.messages, assistantMsg],
        updatedAt: DateTime.now(),
      );

      // Cap history on disk.
      if (updated.messages.length > AIConfig.coachMaxHistoryMessages * 2) {
        updated = updated.copyWith(
          messages: updated.messages
              .sublist(updated.messages.length - AIConfig.coachMaxHistoryMessages * 2),
        );
      }

      await _coachRepository.saveConversation(updated);
      _conversation = updated;
    } catch (e, s) {
      Log.error('Coach chat failed', error: e, stackTrace: s);
      _errorMessage = e.toString();
    } finally {
      _sending = false;
      notifyListeners();
    }
  }

  Future<void> refreshDaily() async {
    final plan = _plan;
    final user = await _userRepository.getCurrentUser();
    if (plan == null || user == null) return;

    _state = CoachUiState.loading;
    notifyListeners();
    try {
      // Force regenerate by overwriting cache.
      final fresh = await _engine.generateDailyCoaching(plan);
      await _coachRepository.saveDailyCoaching(user.id, plan.generatedAt, fresh);
      _daily = fresh;
      _state = CoachUiState.ready;
    } catch (e) {
      _errorMessage = e.toString();
      _state = CoachUiState.error;
    }
    notifyListeners();
  }

  DateTime _mondayOf(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return day.subtract(Duration(days: day.weekday - 1));
  }
}

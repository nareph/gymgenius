import 'dart:convert';

import 'package:gymgenius/domain/entities/weekly_progress_report.dart';
import 'package:gymgenius/engines/ai_coach/ai_config.dart';
import 'package:gymgenius/engines/ai_coach/builders/coach_context_builder.dart';
import 'package:gymgenius/engines/ai_coach/models/coach_context.dart';
import 'package:gymgenius/engines/ai_coach/models/coach_response.dart';
import 'package:gymgenius/engines/ai_coach/models/conversation.dart';
import 'package:gymgenius/engines/ai_coach/prompts/coach_prompts.dart';
import 'package:gymgenius/engines/ai_coach/providers/ai_provider.dart';
import 'package:gymgenius/engines/ai_coach/providers/coach_request_options.dart';
import 'package:gymgenius/engines/ai_coach/providers/local_coach_provider.dart';
import 'package:gymgenius/engines/ai_coach/validators/coach_response_validator.dart';
import 'package:gymgenius/engines/decision_engine/models/daily_plan.dart';

/// Orchestrates AI Coach flows. Never mutates domain engines or persistence.
class AICoachEngine {
  final AIProvider _primary;
  final LocalCoachProvider _local;
  final CoachContextBuilder _contextBuilder;
  final CoachResponseValidator _validator;

  AICoachEngine({
    required AIProvider primary,
    LocalCoachProvider local = const LocalCoachProvider(),
    CoachContextBuilder contextBuilder = const CoachContextBuilder(),
    CoachResponseValidator? validator,
  })  : _primary = primary,
        _local = local,
        _contextBuilder = contextBuilder,
        _validator = validator ?? CoachResponseValidator();

  CoachContext buildContext(DailyPlan plan) => _contextBuilder.build(plan);

  Future<CoachResponse> generateDailyCoaching(DailyPlan plan) async {
    final context = _contextBuilder.build(plan);
    final contextJson = jsonEncode(context.toPromptMap());

    return _completeStructured(
      context: context,
      systemPrompt: CoachPrompts.system,
      userPrompt: CoachPrompts.dailyUser(contextJson),
      localBuilder: () => _local.buildDaily(context),
    );
  }

  Future<CoachResponse> generateWeeklySummary({
    required DailyPlan plan,
    required WeeklyProgressReport report,
  }) async {
    final context = _contextBuilder.build(plan);
    final weeklyMap = {
      'weekStart': report.weekStart.toIso8601String(),
      'weekEnd': report.weekEnd.toIso8601String(),
      'weightStartKg': report.weightStartKg,
      'weightEndKg': report.weightEndKg,
      'weightChangeKg': report.weightChangeKg,
      'workoutsCompleted': report.workoutsCompleted,
      'workoutsPlanned': report.workoutsPlanned,
      'consistencyScore': report.consistencyScore,
      'strengthChangePercent': report.strengthChangePercent,
      'averageReadiness': report.averageReadiness,
      'positives': report.positives,
      'improvements': report.improvements,
    };

    return _completeStructured(
      context: context,
      systemPrompt: CoachPrompts.system,
      userPrompt: CoachPrompts.weeklyUser(
        jsonEncode(context.toPromptMap()),
        jsonEncode(weeklyMap),
      ),
      localBuilder: () => _local.buildWeekly(
        context: context,
        weeklyReport: weeklyMap,
      ),
    );
  }

  Future<CoachResponse> chat({
    required DailyPlan plan,
    required String question,
    List<ConversationMessage> history = const [],
  }) async {
    final context = _contextBuilder.build(plan);
    final clipped = history.length > AIConfig.coachMaxHistoryMessages
        ? history.sublist(history.length - AIConfig.coachMaxHistoryMessages)
        : history;
    final historyJson = jsonEncode(
      clipped
          .map((m) => {
                'role': m.role.value,
                'content': m.content,
              })
          .toList(),
    );

    return _completeStructured(
      context: context,
      systemPrompt: CoachPrompts.system,
      userPrompt: CoachPrompts.chatUser(
        contextJson: jsonEncode(context.toPromptMap()),
        historyJson: historyJson,
        question: question,
      ),
      localBuilder: () => _local.buildChat(context: context, question: question),
    );
  }

  Future<CoachResponse> _completeStructured({
    required CoachContext context,
    required String systemPrompt,
    required String userPrompt,
    required CoachResponse Function() localBuilder,
  }) async {
    final now = DateTime.now();

    if (!_primary.isAvailable || !AIConfig.canUseCoachCloud) {
      return localBuilder();
    }

    try {
      final raw = await _primary
          .complete(
            systemPrompt: systemPrompt,
            userPrompt: userPrompt,
            options: const CoachRequestOptions(
              temperature: 0.4,
              maxTokens: AIConfig.coachMaxOutputTokens,
              timeout: AIConfig.coachTimeout,
            ),
          )
          .timeout(AIConfig.coachTimeout);

      final parsed = _validator.tryParse(
        raw: raw,
        context: context,
        providerId: _primary.id,
        promptVersion: CoachPrompts.promptVersion,
        generatedAt: now,
      );

      if (parsed != null) return parsed;

      return _validator.textFallback(
        message: raw,
        context: context,
        providerId: _primary.id,
        promptVersion: CoachPrompts.promptVersion,
        generatedAt: now,
      );
    } catch (_) {
      return localBuilder();
    }
  }
}

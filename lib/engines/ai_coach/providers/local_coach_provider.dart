import 'dart:convert';

import 'package:gymgenius/engines/ai_coach/models/coach_context.dart';
import 'package:gymgenius/engines/ai_coach/models/coach_response.dart';
import 'package:gymgenius/engines/ai_coach/prompts/coach_prompts.dart';
import 'package:gymgenius/engines/ai_coach/providers/ai_provider.dart';
import 'package:gymgenius/engines/ai_coach/providers/coach_request_options.dart';

/// Deterministic offline coach — templates from [CoachContext], no network.
class LocalCoachProvider implements AIProvider {
  const LocalCoachProvider();

  @override
  String get id => 'local';

  @override
  bool get isAvailable => true;

  @override
  Future<String> complete({
    required String systemPrompt,
    required String userPrompt,
    CoachRequestOptions options = const CoachRequestOptions(),
  }) async {
    // Local provider ignores free-form prompts and expects context embedded
    // via engine helpers; engine prefers [buildDaily]/buildWeekly]/buildChat].
    return jsonEncode({
      'message':
          'Follow today\'s Decision Engine plan. Cloud AI is unavailable — local coaching active.',
      'insights': <Map<String, dynamic>>[],
      'recommendations': [
        {
          'category': 'general',
          'text': 'Stick to the recommended session and recovery cues.',
          'reason': 'Local fallback',
          'alignsWithDecision': true,
          'actionTag': 'follow_plan',
        }
      ],
      'tone': 'supportive',
      'promptVersion': CoachPrompts.promptVersion,
    });
  }

  CoachResponse buildDaily(CoachContext context) {
    final buffer = StringBuffer();
    if (context.isRestDay) {
      buffer.write('Today is a rest day. Recover well');
      if (context.readinessScore != null) {
        buffer.write(' (readiness ${context.readinessScore})');
      }
      buffer.write('.');
    } else if (context.volumeWasReduced) {
      buffer.write(
        'Your plan was adapted with ${context.workoutAdjustment.replaceAll('_', ' ')}. ',
      );
      buffer.write('Follow the reduced session — do not add extra volume.');
    } else {
      buffer.write('You are cleared for today\'s planned workout');
      if (context.readinessScore != null) {
        buffer.write(' (readiness ${context.readinessScore})');
      }
      buffer.write('.');
    }

    if (context.weightPlateau || context.strengthPlateau) {
      buffer.write(' A plateau signal is present — stay consistent.');
    }

    final insights = <CoachInsight>[];
    if (context.readinessScore != null) {
      insights.add(
        CoachInsight(
          type: 'recovery',
          title: 'Readiness',
          body: 'Readiness score: ${context.readinessScore}.',
          priority: context.readinessScore! < 60
              ? CoachPriority.high
              : CoachPriority.medium,
        ),
      );
    }
    if (context.consistencyScore != null) {
      insights.add(
        CoachInsight(
          type: 'progress',
          title: 'Consistency',
          body: 'Consistency score: ${context.consistencyScore}%.',
        ),
      );
    }

    return CoachResponse(
      message: buffer.toString(),
      insights: insights,
      recommendations: [
        CoachRecommendation(
          category: CoachRecommendationCategory.workout,
          text: context.volumeWasReduced
              ? 'Complete the adapted workout without adding sets.'
              : context.isRestDay
                  ? 'Prioritize sleep and light movement.'
                  : 'Complete the planned session as written.',
          reason: context.healthReason ?? 'Decision Engine plan',
          alignsWithDecision: true,
          actionTag: context.volumeWasReduced
              ? 'follow_reduced_volume'
              : 'follow_plan',
        ),
      ],
      providerId: id,
      promptVersion: CoachPrompts.promptVersion,
      generatedAt: DateTime.now(),
      usedFallback: true,
    );
  }

  CoachResponse buildWeekly({
    required CoachContext context,
    required Map<String, dynamic> weeklyReport,
  }) {
    final completed = weeklyReport['workoutsCompleted'];
    final planned = weeklyReport['workoutsPlanned'];
    final consistency = weeklyReport['consistencyScore'];
    final weightChange = weeklyReport['weightChangeKg'];
    final positives = (weeklyReport['positives'] as List?)?.cast<String>() ?? [];
    final improvements =
        (weeklyReport['improvements'] as List?)?.cast<String>() ?? [];

    final message = StringBuffer('Weekly summary: ');
    if (completed != null && planned != null) {
      message.write('$completed/$planned workouts completed');
      if (consistency != null) message.write(' (consistency $consistency%)');
      message.write('. ');
    }
    if (weightChange != null) {
      message.write('Weight change: $weightChange kg. ');
    }
    if (positives.isNotEmpty) {
      message.write('Positives: ${positives.join('; ')}. ');
    }
    if (improvements.isNotEmpty) {
      message.write('Focus next week: ${improvements.join('; ')}.');
    }

    return CoachResponse(
      message: message.toString().trim(),
      insights: [
        if (consistency != null)
          CoachInsight(
            type: 'progress',
            title: 'Consistency',
            body: '$consistency%',
          ),
      ],
      recommendations: [
        CoachRecommendation(
          category: CoachRecommendationCategory.progress,
          text: improvements.isNotEmpty
              ? improvements.first
              : 'Keep logging workouts and weight.',
          reason: 'Weekly report',
          alignsWithDecision: true,
          actionTag: 'follow_plan',
        ),
      ],
      providerId: id,
      promptVersion: CoachPrompts.promptVersion,
      generatedAt: DateTime.now(),
      usedFallback: true,
    );
  }

  CoachResponse buildChat({
    required CoachContext context,
    required String question,
  }) {
    final q = question.toLowerCase();
    String message;
    if (q.contains('why') || q.contains('pourquoi')) {
      message = context.decisionReasons.isNotEmpty
          ? 'Today\'s decision reasons: ${context.decisionReasons.join(', ')}.'
          : 'Today follows the scheduled plan from the Decision Engine.';
    } else if (q.contains('nutrition') || q.contains('meal')) {
      message = context.nutritionCalories != null
          ? 'Today\'s nutrition target is ${context.nutritionCalories} kcal'
              '${context.nutritionProteinG != null ? ' with ${context.nutritionProteinG}g protein' : ''}.'
          : 'Nutrition data is not available yet.';
    } else if (q.contains('recovery') || q.contains('sleep')) {
      message = context.readinessScore != null
          ? 'Readiness is ${context.readinessScore}'
              '${context.volumeWasReduced ? ' — volume was reduced accordingly' : ''}.'
          : 'No recovery check-in is available for today.';
    } else if (q.contains('progress') || q.contains('plateau')) {
      if (context.weightPlateau || context.strengthPlateau) {
        message =
            'A plateau was detected. Stay consistent; the Progress Rule does not auto-change your program.';
      } else if (context.consistencyScore != null) {
        message = 'Consistency is at ${context.consistencyScore}%.';
      } else {
        message = 'Not enough progress data yet.';
      }
    } else {
      message =
          'I can explain today\'s workout, recovery, nutrition, or progress using your real data.';
    }

    return CoachResponse(
      message: message,
      providerId: id,
      promptVersion: CoachPrompts.promptVersion,
      generatedAt: DateTime.now(),
      usedFallback: true,
    );
  }
}

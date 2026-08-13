import 'dart:convert';

import 'package:gymgenius/domain/enums/workout_adjustment.dart';
import 'package:gymgenius/engines/ai_coach/models/coach_context.dart';
import 'package:gymgenius/engines/ai_coach/models/coach_response.dart';
import 'package:gymgenius/engines/ai_coach/repair/json_repair_service.dart';

/// Validates and guardrails AI Coach JSON responses.
class CoachResponseValidator {
  final JsonRepairService _jsonRepair;

  CoachResponseValidator({
    JsonRepairService? jsonRepair,
  }) : _jsonRepair = jsonRepair ?? JsonRepairService();

  /// Forbidden action tags when the Decision Engine reduced load or prescribed rest.
  static const forbiddenWhenProtective = {
    'increase_volume',
    'increase_intensity',
    'push_harder',
    'add_sets',
    'skip_rest',
    'train_harder',
  };

  CoachResponse? tryParse({
    required String raw,
    required CoachContext context,
    required String providerId,
    required String promptVersion,
    DateTime? generatedAt,
  }) {
    try {
      final decoded = _jsonRepair.parseJsonWithRepair(raw, 'coach_response');
      var response = CoachResponse.fromJson(
        decoded,
        providerId: providerId,
        promptVersion: promptVersion,
        generatedAt: generatedAt,
      );

      if (response.message.trim().isEmpty) return null;

      response = _applyGuardrails(response, context);
      return response;
    } catch (_) {
      // Last resort: try extracting a bare JSON object.
      try {
        final start = raw.indexOf('{');
        final end = raw.lastIndexOf('}');
        if (start >= 0 && end > start) {
          final decoded =
              jsonDecode(raw.substring(start, end + 1)) as Map<String, dynamic>;
          var response = CoachResponse.fromJson(
            decoded,
            providerId: providerId,
            promptVersion: promptVersion,
            generatedAt: generatedAt,
          );
          if (response.message.trim().isEmpty) return null;
          return _applyGuardrails(response, context);
        }
      } catch (_) {}
      return null;
    }
  }

  CoachResponse _applyGuardrails(CoachResponse response, CoachContext context) {
    if (!context.isProtectiveDay) return response;

    final filtered = response.recommendations.where((r) {
      if (!r.alignsWithDecision &&
          r.category == CoachRecommendationCategory.workout) {
        return false;
      }
      final tag = r.actionTag?.toLowerCase() ?? '';
      final text = r.text.toLowerCase();
      if (forbiddenWhenProtective.contains(tag)) return false;
      if (text.contains('increase volume') ||
          text.contains('add more sets') ||
          text.contains('train harder') ||
          text.contains('push harder') ||
          text.contains('skip rest')) {
        return false;
      }
      return true;
    }).toList();

    return response.copyWith(recommendations: filtered);
  }

  /// Textual fallback wrapping when structured parse fails.
  CoachResponse textFallback({
    required String message,
    required CoachContext context,
    required String providerId,
    required String promptVersion,
    DateTime? generatedAt,
  }) {
    return CoachResponse(
      message: message.trim().isEmpty
          ? 'Follow today\'s plan from the Decision Engine.'
          : message.trim(),
      insights: const [],
      recommendations: [
        CoachRecommendation(
          category: CoachRecommendationCategory.general,
          text: context.isAdapted
              ? 'Follow the adapted workout (${context.workoutAdjustment}).'
              : 'Complete your planned session.',
          reason: 'Aligned with Decision Engine',
          alignsWithDecision: true,
          actionTag: fallbackActionTag(context),
        ),
      ],
      providerId: providerId,
      promptVersion: promptVersion,
      generatedAt: generatedAt ?? DateTime.now(),
      usedFallback: true,
    );
  }

  static String fallbackActionTag(CoachContext context) {
    if (context.isRestDay ||
        context.workoutAdjustment == WorkoutAdjustment.restDay.value ||
        context.workoutAdjustment == WorkoutAdjustment.skipWorkout.value) {
      return 'rest';
    }
    if (context.workoutAdjustment ==
        WorkoutAdjustment.recoverySession.value) {
      return 'follow_recovery';
    }
    if (context.volumeWasReduced) return 'follow_reduced_volume';
    return 'follow_plan';
  }
}

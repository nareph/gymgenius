// lib/engines/ai_coach/validators/coach_response_validator.dart
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

  /// Tries to parse a structured CoachResponse from raw text.
  /// Returns null if parsing fails.
  CoachResponse? tryParse({
    required String raw,
    required CoachContext context,
    required String providerId,
    required String promptVersion,
    DateTime? generatedAt,
  }) {
    // Step 1: Clean and try direct parse
    try {
      final decoded = _jsonRepair.parseJsonWithRepair(raw, 'coach_response');
      var response = CoachResponse.fromJson(
        decoded,
        providerId: providerId,
        promptVersion: promptVersion,
        generatedAt: generatedAt,
      );

      // If message is empty, try to build one from insights or recommendations
      if (response.message.trim().isEmpty) {
        if (response.insights.isNotEmpty) {
          response = response.copyWith(
            message: response.insights.map((i) => i.body).join(' '),
          );
        } else if (response.recommendations.isNotEmpty) {
          response = response.copyWith(
            message: response.recommendations.map((r) => r.text).join(' '),
          );
        } else {
          return null;
        }
      }

      response = _applyGuardrails(response, context);
      return response;
    } catch (_) {
      // Continue to next strategy
    }

    // Step 2: Try to extract a bare JSON object using brace matching
    try {
      final start = raw.indexOf('{');
      final end = raw.lastIndexOf('}');
      if (start >= 0 && end > start) {
        final substring = raw.substring(start, end + 1);
        final decoded = jsonDecode(substring) as Map<String, dynamic>;
        var response = CoachResponse.fromJson(
          decoded,
          providerId: providerId,
          promptVersion: promptVersion,
          generatedAt: generatedAt,
        );
        if (response.message.trim().isEmpty) {
          if (response.insights.isNotEmpty) {
            response = response.copyWith(
              message: response.insights.map((i) => i.body).join(' '),
            );
          } else if (response.recommendations.isNotEmpty) {
            response = response.copyWith(
              message: response.recommendations.map((r) => r.text).join(' '),
            );
          } else {
            return null;
          }
        }
        return _applyGuardrails(response, context);
      }
    } catch (_) {
      // Continue
    }

    // Step 3: Check if the raw text is a JSON object with a nested "message" field
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final message = decoded['message'] as String?;
      if (message != null && message.trim().startsWith('{')) {
        final nested = jsonDecode(message) as Map<String, dynamic>;
        var response = CoachResponse.fromJson(
          nested,
          providerId: providerId,
          promptVersion: promptVersion,
          generatedAt: generatedAt,
        );
        if (response.message.trim().isNotEmpty) {
          return _applyGuardrails(response, context);
        }
      }
    } catch (_) {
      // Continue
    }

    return null;
  }

  /// Applies guardrails to filter out unsafe or conflicting recommendations.
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

  /// Textual fallback when structured parse fails.
  /// Attempts to extract a JSON object from the message before falling back to plain text.
  CoachResponse textFallback({
    required String message,
    required CoachContext context,
    required String providerId,
    required String promptVersion,
    DateTime? generatedAt,
  }) {
    final trimmed = message.trim();

    // If the message looks like JSON, try to parse it
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      try {
        final decoded = jsonDecode(trimmed) as Map<String, dynamic>;
        final parsed = CoachResponse.fromJson(
          decoded,
          providerId: providerId,
          promptVersion: promptVersion,
          generatedAt: generatedAt,
        );
        if (parsed.message.trim().isNotEmpty) {
          return _applyGuardrails(parsed, context);
        }
        if (parsed.insights.isNotEmpty) {
          return parsed.copyWith(
            message: parsed.insights.map((i) => i.body).join(' '),
          );
        }
        if (parsed.recommendations.isNotEmpty) {
          return parsed.copyWith(
            message: parsed.recommendations.map((r) => r.text).join(' '),
          );
        }
      } catch (_) {
        // Not valid JSON, continue
      }
    }

    // Build a sensible fallback message
    final cleanMessage = trimmed.isEmpty
        ? 'Follow today\'s plan from the Decision Engine.'
        : trimmed;

    final recommendations = <CoachRecommendation>[
      CoachRecommendation(
        category: CoachRecommendationCategory.general,
        text: context.isAdapted
            ? 'Follow the adapted workout (${context.workoutAdjustment}).'
            : 'Complete your planned session.',
        reason: 'Aligned with Decision Engine',
        alignsWithDecision: true,
        actionTag: fallbackActionTag(context),
      ),
    ];

    // Try to extract insights from the raw message
    final insights = <CoachInsight>[];
    if (cleanMessage.contains('insight') ||
        cleanMessage.contains('recommendation')) {
      final sentences = cleanMessage.split(RegExp(r'[.!?]\s+'));
      for (final sentence in sentences) {
        if (sentence.length > 20 && !sentence.contains('insight')) {
          insights.add(
            CoachInsight(
              type: 'insight',
              title: 'AI Coach Insight',
              body: sentence.trim(),
              priority: CoachPriority.medium,
            ),
          );
        }
      }
    }

    return CoachResponse(
      message: cleanMessage,
      insights: insights.isNotEmpty ? insights : const [],
      recommendations: insights.isEmpty
          ? recommendations
          : [
              ...recommendations,
              ...insights.map(
                (i) => CoachRecommendation(
                  category: CoachRecommendationCategory.general,
                  text: i.body,
                  reason: 'Extracted from AI response',
                  alignsWithDecision: true,
                  actionTag: fallbackActionTag(context),
                ),
              ),
            ],
      providerId: providerId,
      promptVersion: promptVersion,
      generatedAt: generatedAt ?? DateTime.now(),
      usedFallback: true,
    );
  }

  /// Determines a safe fallback action tag based on the context.
  static String fallbackActionTag(CoachContext context) {
    if (context.isRestDay ||
        context.workoutAdjustment == WorkoutAdjustment.restDay.value ||
        context.workoutAdjustment == WorkoutAdjustment.skipWorkout.value) {
      return 'rest';
    }
    if (context.workoutAdjustment == WorkoutAdjustment.recoverySession.value) {
      return 'follow_recovery';
    }
    if (context.volumeWasReduced) return 'follow_reduced_volume';
    return 'follow_plan';
  }
}

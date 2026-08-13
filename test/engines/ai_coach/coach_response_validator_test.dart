import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/domain/enums/workout_adjustment.dart';
import 'package:gymgenius/engines/ai_coach/models/coach_context.dart';
import 'package:gymgenius/engines/ai_coach/validators/coach_response_validator.dart';

CoachContext _ctx({
  required bool volumeReduced,
  bool restDay = false,
  String? adjustment,
}) {
  final resolvedAdjustment = adjustment ??
      (volumeReduced
          ? WorkoutAdjustment.reduceVolume.value
          : restDay
              ? WorkoutAdjustment.restDay.value
              : WorkoutAdjustment.none.value);
  return CoachContext(
    userId: 'u1',
    now: DateTime(2026, 8, 11),
    isRestDay: restDay,
    isAdapted: volumeReduced || restDay,
    workoutAdjustment: resolvedAdjustment,
    decisionReasons: const ['low_recovery'],
    plannedExerciseCount: restDay ? 0 : 2,
    volumeMultiplier: volumeReduced ? 0.7 : 1.0,
    decisionConfidence: 0.9,
  );
}

void main() {
  final validator = CoachResponseValidator();

  test('parses valid JSON coach response', () {
    final raw = jsonEncode({
      'message': 'Train smart today.',
      'insights': [
        {
          'type': 'recovery',
          'title': 'Readiness',
          'body': 'OK',
          'priority': 'medium',
        }
      ],
      'recommendations': [
        {
          'category': 'workout',
          'text': 'Complete the session',
          'reason': 'Plan',
          'alignsWithDecision': true,
          'actionTag': 'follow_plan',
        }
      ],
      'tone': 'supportive',
    });

    final parsed = validator.tryParse(
      raw: raw,
      context: _ctx(volumeReduced: false),
      providerId: 'test',
      promptVersion: 'v1',
    );

    expect(parsed, isNotNull);
    expect(parsed!.message, 'Train smart today.');
    expect(parsed.insights, hasLength(1));
    expect(parsed.recommendations, hasLength(1));
  });

  test('strips increase_volume when Decision Engine reduced volume', () {
    final raw = jsonEncode({
      'message': 'Go easy.',
      'recommendations': [
        {
          'category': 'workout',
          'text': 'Add more sets and increase volume',
          'reason': 'Bad advice',
          'alignsWithDecision': false,
          'actionTag': 'increase_volume',
        },
        {
          'category': 'workout',
          'text': 'Complete the adapted workout',
          'reason': 'DE',
          'alignsWithDecision': true,
          'actionTag': 'follow_reduced_volume',
        },
      ],
    });

    final parsed = validator.tryParse(
      raw: raw,
      context: _ctx(volumeReduced: true),
      providerId: 'test',
      promptVersion: 'v1',
    );

    expect(parsed, isNotNull);
    expect(parsed!.recommendations, hasLength(1));
    expect(parsed.recommendations.first.actionTag, 'follow_reduced_volume');
  });

  test('returns null for empty message', () {
    final parsed = validator.tryParse(
      raw: '{"message":"   "}',
      context: _ctx(volumeReduced: false),
      providerId: 'test',
      promptVersion: 'v1',
    );
    expect(parsed, isNull);
  });

  test('textFallback wraps unstructured text', () {
    final fb = validator.textFallback(
      message: 'Plain advice',
      context: _ctx(volumeReduced: true),
      providerId: 'test',
      promptVersion: 'v1',
    );
    expect(fb.message, 'Plain advice');
    expect(fb.usedFallback, isTrue);
    expect(fb.recommendations.first.actionTag, 'follow_reduced_volume');
  });

  test('strips push_harder on rest days', () {
    final raw = jsonEncode({
      'message': 'Rest today.',
      'recommendations': [
        {
          'category': 'workout',
          'text': 'Push harder anyway',
          'reason': 'Bad advice',
          'alignsWithDecision': false,
          'actionTag': 'push_harder',
        },
        {
          'category': 'recovery',
          'text': 'Sleep and hydrate',
          'reason': 'DE',
          'alignsWithDecision': true,
          'actionTag': 'rest',
        },
      ],
    });

    final parsed = validator.tryParse(
      raw: raw,
      context: _ctx(volumeReduced: false, restDay: true),
      providerId: 'test',
      promptVersion: 'v1',
    );

    expect(parsed, isNotNull);
    expect(parsed!.recommendations, hasLength(1));
    expect(parsed.recommendations.first.actionTag, 'rest');
  });

  test('strips increase_volume on recovery sessions', () {
    final raw = jsonEncode({
      'message': 'Keep it light.',
      'recommendations': [
        {
          'category': 'workout',
          'text': 'Increase volume',
          'reason': 'Bad',
          'alignsWithDecision': true,
          'actionTag': 'increase_volume',
        },
      ],
    });

    final parsed = validator.tryParse(
      raw: raw,
      context: _ctx(
        volumeReduced: false,
        adjustment: WorkoutAdjustment.recoverySession.value,
      ),
      providerId: 'test',
      promptVersion: 'v1',
    );

    expect(parsed, isNotNull);
    expect(parsed!.recommendations, isEmpty);
  });

  test('textFallback uses rest tag on rest days', () {
    final fb = validator.textFallback(
      message: 'Rest',
      context: _ctx(volumeReduced: false, restDay: true),
      providerId: 'test',
      promptVersion: 'v1',
    );
    expect(fb.recommendations.first.actionTag, 'rest');
  });
}

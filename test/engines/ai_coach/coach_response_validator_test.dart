import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/domain/enums/workout_adjustment.dart';
import 'package:gymgenius/engines/ai_coach/models/coach_context.dart';
import 'package:gymgenius/engines/ai_coach/validators/coach_response_validator.dart';

CoachContext _ctx({required bool volumeReduced}) {
  return CoachContext(
    userId: 'u1',
    now: DateTime(2026, 8, 11),
    isRestDay: false,
    isAdapted: volumeReduced,
    workoutAdjustment: volumeReduced
        ? WorkoutAdjustment.reduceVolume.value
        : WorkoutAdjustment.none.value,
    decisionReasons: const ['low_recovery'],
    plannedExerciseCount: 2,
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
}

import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/core/services/workout_audio_service.dart';

void main() {
  group('WorkoutAudioService.shouldPlayCountdownTick', () {
    test('plays tick only for 3, 2, and 1 seconds remaining', () {
      expect(WorkoutAudioService.shouldPlayCountdownTick(4), isFalse);
      expect(WorkoutAudioService.shouldPlayCountdownTick(3), isTrue);
      expect(WorkoutAudioService.shouldPlayCountdownTick(2), isTrue);
      expect(WorkoutAudioService.shouldPlayCountdownTick(1), isTrue);
      expect(WorkoutAudioService.shouldPlayCountdownTick(0), isFalse);
    });
  });

  group('adjustRestSeconds', () {
    test('adds and subtracts within bounds', () {
      expect(adjustRestSeconds(45, 10), 55);
      expect(adjustRestSeconds(45, -10), 35);
      expect(adjustRestSeconds(5, -10), 0);
      expect(adjustRestSeconds(595, 10), 600);
      expect(adjustRestSeconds(600, 10), 600);
    });
  });
}

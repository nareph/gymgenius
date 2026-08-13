import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/data/repositories/workout_session_settings_repository.dart';
import 'package:gymgenius/domain/entities/workout_session_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WorkoutSessionSettingsRepository', () {
    late WorkoutSessionSettingsRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      repository = WorkoutSessionSettingsRepository();
    });

    test('returns defaults when nothing saved', () async {
      final settings = await repository.load();
      expect(settings, WorkoutSessionSettings.defaults);
    });

    test('persists updated settings', () async {
      const updated = WorkoutSessionSettings(
        soundsEnabled: false,
        hapticsEnabled: false,
        voiceCountdownEnabled: true,
        backgroundNotificationsEnabled: false,
      );

      await repository.save(updated);
      final loaded = await repository.load();

      expect(loaded, updated);
    });
  });
}

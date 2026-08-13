import 'package:gymgenius/domain/entities/workout_session_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkoutSessionSettingsRepository {
  WorkoutSessionSettingsRepository({SharedPreferences? preferences})
      : _preferences = preferences;

  SharedPreferences? _preferences;

  static const _keySounds = 'workout_sounds_enabled';
  static const _keyHaptics = 'workout_haptics_enabled';
  static const _keyVoice = 'workout_voice_countdown_enabled';
  static const _keyBackgroundNotif = 'workout_background_notifications_enabled';

  Future<SharedPreferences> _prefs() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<WorkoutSessionSettings> load() async {
    final prefs = await _prefs();
    return WorkoutSessionSettings(
      soundsEnabled: prefs.getBool(_keySounds) ??
          WorkoutSessionSettings.defaults.soundsEnabled,
      hapticsEnabled: prefs.getBool(_keyHaptics) ??
          WorkoutSessionSettings.defaults.hapticsEnabled,
      voiceCountdownEnabled: prefs.getBool(_keyVoice) ??
          WorkoutSessionSettings.defaults.voiceCountdownEnabled,
      backgroundNotificationsEnabled: prefs.getBool(_keyBackgroundNotif) ??
          WorkoutSessionSettings.defaults.backgroundNotificationsEnabled,
    );
  }

  Future<void> save(WorkoutSessionSettings settings) async {
    final prefs = await _prefs();
    await prefs.setBool(_keySounds, settings.soundsEnabled);
    await prefs.setBool(_keyHaptics, settings.hapticsEnabled);
    await prefs.setBool(_keyVoice, settings.voiceCountdownEnabled);
    await prefs.setBool(
      _keyBackgroundNotif,
      settings.backgroundNotificationsEnabled,
    );
  }
}

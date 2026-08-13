import 'package:flutter/foundation.dart';
import 'package:gymgenius/core/logger/logger_service.dart';
import 'package:gymgenius/data/repositories/workout_session_settings_repository.dart';
import 'package:gymgenius/domain/entities/workout_session_settings.dart';
import 'package:gymgenius/presentation/providers/workout_session_manager.dart';

class WorkoutSessionSettingsController extends ChangeNotifier {
  WorkoutSessionSettingsController({
    required WorkoutSessionSettingsRepository repository,
    required WorkoutSessionManager sessionManager,
  })  : _repository = repository,
        _sessionManager = sessionManager;

  final WorkoutSessionSettingsRepository _repository;
  final WorkoutSessionManager _sessionManager;

  WorkoutSessionSettings _settings = WorkoutSessionSettings.defaults;
  bool _isLoading = true;

  WorkoutSessionSettings get settings => _settings;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _settings = await _repository.load();
      await _sessionManager.applySettings(_settings);
    } catch (e, s) {
      Log.error('WorkoutSessionSettingsController: load failed',
          error: e, stackTrace: s);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSettings(WorkoutSessionSettings newSettings) async {
    _settings = newSettings;
    notifyListeners();
    try {
      await _repository.save(newSettings);
      await _sessionManager.applySettings(newSettings);
    } catch (e, s) {
      Log.error('WorkoutSessionSettingsController: save failed',
          error: e, stackTrace: s);
    }
  }

  Future<void> setSoundsEnabled(bool value) =>
      updateSettings(_settings.copyWith(soundsEnabled: value));

  Future<void> setHapticsEnabled(bool value) =>
      updateSettings(_settings.copyWith(hapticsEnabled: value));

  Future<void> setVoiceCountdownEnabled(bool value) =>
      updateSettings(_settings.copyWith(voiceCountdownEnabled: value));

  Future<void> setBackgroundNotificationsEnabled(bool value) =>
      updateSettings(_settings.copyWith(backgroundNotificationsEnabled: value));
}

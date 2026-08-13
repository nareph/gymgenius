import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:gymgenius/core/logger/logger_service.dart';
import 'package:gymgenius/core/services/workout_voice_service.dart';

/// Audio cues during active workouts (exercise countdown + rest timer).
class WorkoutAudioService {
  WorkoutAudioService({
    AudioPlayer? tickPlayer,
    AudioPlayer? completePlayer,
    WorkoutVoiceService? voiceService,
    this.hapticsEnabled = true,
    this.soundsEnabled = true,
    this.voiceCountdownEnabled = false,
  })  : _tickPlayer = tickPlayer ?? AudioPlayer(),
        _completePlayer = completePlayer ?? AudioPlayer(),
        _voice = voiceService ?? WorkoutVoiceService();

  final AudioPlayer _tickPlayer;
  final AudioPlayer _completePlayer;
  final WorkoutVoiceService _voice;

  bool hapticsEnabled = true;
  bool soundsEnabled = true;
  bool voiceCountdownEnabled = false;
  bool useFrenchVoice = false;

  WorkoutVoiceService get voiceService => _voice;

  int? _lastCountdownSecond;
  WorkoutTimerKind? _lastCountdownKind;

  static bool shouldPlayCountdownTick(int secondsRemaining) =>
      secondsRemaining >= 1 && secondsRemaining <= 3;

  Future<void> initializeVoice({required String languageCode}) async {
    useFrenchVoice = languageCode.startsWith('fr');
    await _voice.initialize(
      languageCode: useFrenchVoice ? 'fr-FR' : 'en-US',
    );
    _voice.enabled = voiceCountdownEnabled;
  }

  void applyPreferences({
    required bool sounds,
    required bool haptics,
    required bool voice,
  }) {
    soundsEnabled = sounds;
    hapticsEnabled = haptics;
    voiceCountdownEnabled = voice;
    _voice.enabled = voice;
  }

  void resetCountdownState() {
    _lastCountdownSecond = null;
    _lastCountdownKind = null;
  }

  Future<void> onTimerSecond({
    required int secondsRemaining,
    required WorkoutTimerKind kind,
  }) async {
    if (!shouldPlayCountdownTick(secondsRemaining)) return;
    if (_lastCountdownSecond == secondsRemaining &&
        _lastCountdownKind == kind) {
      return;
    }
    _lastCountdownSecond = secondsRemaining;
    _lastCountdownKind = kind;

    await _playTick();
    if (voiceCountdownEnabled) {
      await _voice.speakCountdown(secondsRemaining);
    }
    _pulseHaptic(light: true);
  }

  Future<void> playExerciseComplete() async {
    resetCountdownState();
    await _playAsset('exercise_complete.mp3', player: _completePlayer);
    if (voiceCountdownEnabled) {
      await _voice.speakGo(french: useFrenchVoice);
    }
    _pulseHaptic(light: false);
  }

  Future<void> playRestComplete() async {
    resetCountdownState();
    await _playAsset('rest_complete.mp3', player: _completePlayer);
    if (voiceCountdownEnabled) {
      await _voice.speakRestComplete(french: useFrenchVoice);
    }
    _pulseHaptic(light: false);
  }

  Future<void> _playTick() async {
    await _playAsset('tick.mp3', player: _tickPlayer);
  }

  Future<void> _playAsset(
    String fileName, {
    required AudioPlayer player,
  }) async {
    if (!soundsEnabled) return;
    try {
      await player.stop();
      await player.play(AssetSource('sounds/$fileName'));
    } catch (e, stackTrace) {
      Log.error(
        "WorkoutAudioService: failed to play sounds/$fileName",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _pulseHaptic({required bool light}) {
    if (!hapticsEnabled) return;
    if (light) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> dispose() async {
    await _tickPlayer.dispose();
    await _completePlayer.dispose();
    await _voice.dispose();
  }
}

enum WorkoutTimerKind { exercise, rest }

/// Clamps adjusted rest duration between bounds used by +/- controls.
int adjustRestSeconds(int current, int delta,
    {int min = 0, int max = 600}) {
  return (current + delta).clamp(min, max);
}

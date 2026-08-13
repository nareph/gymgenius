import 'package:flutter_tts/flutter_tts.dart';
import 'package:gymgenius/core/logger/logger_service.dart';

/// Optional spoken countdown ("3, 2, 1, go") during workout timers.
class WorkoutVoiceService {
  WorkoutVoiceService({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  bool enabled = false;
  bool _initialized = false;

  Future<void> initialize({String languageCode = 'en-US'}) async {
    if (_initialized) return;
    try {
      await _tts.setLanguage(languageCode);
      await _tts.setSpeechRate(0.45);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _initialized = true;
    } catch (e, s) {
      Log.error('WorkoutVoiceService: init failed', error: e, stackTrace: s);
    }
  }

  Future<void> speakCountdown(int secondsRemaining) async {
    if (!enabled || !_initialized) return;
    try {
      await _tts.speak('$secondsRemaining');
    } catch (e, s) {
      Log.error('WorkoutVoiceService: countdown failed', error: e, stackTrace: s);
    }
  }

  Future<void> speakGo({bool french = false}) async {
    if (!enabled || !_initialized) return;
    try {
      await _tts.speak(french ? 'Allez' : 'Go');
    } catch (e, s) {
      Log.error('WorkoutVoiceService: go failed', error: e, stackTrace: s);
    }
  }

  Future<void> speakRestComplete({bool french = false}) async {
    if (!enabled || !_initialized) return;
    try {
      await _tts.speak(french ? 'Repos terminé' : 'Rest complete');
    } catch (e, s) {
      Log.error('WorkoutVoiceService: rest complete failed',
          error: e, stackTrace: s);
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

  Future<void> dispose() async {
    await stop();
  }
}

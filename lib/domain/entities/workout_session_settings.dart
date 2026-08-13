import 'package:equatable/equatable.dart';

/// User preferences for in-session audio, haptics, voice, and notifications.
class WorkoutSessionSettings extends Equatable {
  final bool soundsEnabled;
  final bool hapticsEnabled;
  final bool voiceCountdownEnabled;
  final bool backgroundNotificationsEnabled;

  const WorkoutSessionSettings({
    required this.soundsEnabled,
    required this.hapticsEnabled,
    required this.voiceCountdownEnabled,
    required this.backgroundNotificationsEnabled,
  });

  static const WorkoutSessionSettings defaults = WorkoutSessionSettings(
    soundsEnabled: true,
    hapticsEnabled: true,
    voiceCountdownEnabled: false,
    backgroundNotificationsEnabled: true,
  );

  WorkoutSessionSettings copyWith({
    bool? soundsEnabled,
    bool? hapticsEnabled,
    bool? voiceCountdownEnabled,
    bool? backgroundNotificationsEnabled,
  }) {
    return WorkoutSessionSettings(
      soundsEnabled: soundsEnabled ?? this.soundsEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      voiceCountdownEnabled:
          voiceCountdownEnabled ?? this.voiceCountdownEnabled,
      backgroundNotificationsEnabled: backgroundNotificationsEnabled ??
          this.backgroundNotificationsEnabled,
    );
  }

  @override
  List<Object?> get props => [
        soundsEnabled,
        hapticsEnabled,
        voiceCountdownEnabled,
        backgroundNotificationsEnabled,
      ];
}

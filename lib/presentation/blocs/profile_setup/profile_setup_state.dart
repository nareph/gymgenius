part of 'profile_setup_bloc.dart';

enum ProfileSetupStatus { initial, loading, complete, error }

class ProfileSetupState extends Equatable {
  final Map<String, dynamic> answers; // temporary raw answers
  final HealthProfile? profile; // built profile when complete
  final ProfileSetupStatus status;
  final String? errorMessage;

  const ProfileSetupState({
    this.answers = const {},
    this.profile,
    this.status = ProfileSetupStatus.initial,
    this.errorMessage,
  });

  ProfileSetupState copyWith({
    Map<String, dynamic>? answers,
    HealthProfile? profile,
    ProfileSetupStatus? status,
    String? errorMessage,
  }) {
    return ProfileSetupState(
      answers: answers ?? this.answers,
      profile: profile ?? this.profile,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [answers, profile, status, errorMessage];
}

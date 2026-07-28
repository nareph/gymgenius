part of 'profile_setup_bloc.dart';

abstract class ProfileSetupEvent extends Equatable {
  const ProfileSetupEvent();
  @override
  List<Object?> get props => [];
}

/// Update a single question answer (map key → value)
class UpdateAnswer extends ProfileSetupEvent {
  final String questionId;
  final dynamic answerValue;
  const UpdateAnswer({required this.questionId, required this.answerValue});
  @override
  List<Object?> get props => [questionId, answerValue];
}

/// Finish profile setup (either pre-signup or post-login)
class CompleteProfileSetup extends ProfileSetupEvent {
  final bool isPostLogin;
  const CompleteProfileSetup({this.isPostLogin = false});
  @override
  List<Object?> get props => [isPostLogin];
}

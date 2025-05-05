part of 'onboarding_bloc.dart';

// --- Events ---
sealed class OnboardingEvent extends Equatable {
  // Utiliser Equatable pour les tests
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

// Événement pour mettre à jour la réponse d'UNE question
class UpdateAnswer extends OnboardingEvent {
  final String questionId;
  final dynamic
      answerValue; // Peut être String (single) ou List<String> (multi)

  const UpdateAnswer({required this.questionId, required this.answerValue});

  @override
  List<Object?> get props => [questionId, answerValue];
}

// Événement déclenché quand l'utilisateur termine ou skip
class CompleteOnboarding extends OnboardingEvent {}

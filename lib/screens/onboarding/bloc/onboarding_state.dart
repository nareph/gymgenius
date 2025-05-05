part of 'onboarding_bloc.dart';

// --- Status Enum ---
enum OnboardingStatus {
  initial, // Pas encore commencé ou en cours
  validating, // Optionnel: si validation asynchrone nécessaire
  complete, // Toutes les données sont prêtes pour la soumission/navigation
  error, // Optionnel: en cas d'erreur
}

// --- State ---
class OnboardingState extends Equatable {
  final Map<String, dynamic>
      answers; // Clé = questionId, Valeur = String ou List<String>
  final OnboardingStatus status;

  const OnboardingState({
    this.answers = const {}, // Initialiser comme map vide
    this.status = OnboardingStatus.initial,
  });

  OnboardingState copyWith({
    Map<String, dynamic>? answers,
    OnboardingStatus? status,
  }) {
    return OnboardingState(
      answers: answers ?? this.answers,
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [answers, status]; // Important pour Equatable/Bloc
}

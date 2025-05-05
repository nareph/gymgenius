import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart'; // Pour debugPrint

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(const OnboardingState()) {
    // Utilise le constructeur const
    // Gère la mise à jour d'une réponse
    on<UpdateAnswer>((event, emit) {
      // Crée une nouvelle map basée sur l'état actuel
      final newAnswers = Map<String, dynamic>.from(state.answers);
      // Met à jour ou ajoute la réponse pour la question donnée
      newAnswers[event.questionId] = event.answerValue;

      // Émet le nouvel état avec les réponses mises à jour
      emit(state.copyWith(
          answers: newAnswers, status: OnboardingStatus.initial));
      debugPrint(
          "Bloc State Updated: ${state.copyWith(answers: newAnswers).answers}"); // Debug
    });

    // Gère la fin de l'onboarding (Skip ou dernière question)
    on<CompleteOnboarding>((event, emit) {
      debugPrint(
          "Onboarding Completion Requested. Final Answers: ${state.answers}");
      // Émet simplement un état indiquant que c'est terminé
      // La navigation sera gérée par le BlocListener dans l'UI
      emit(state.copyWith(status: OnboardingStatus.complete));
    });
  }
}

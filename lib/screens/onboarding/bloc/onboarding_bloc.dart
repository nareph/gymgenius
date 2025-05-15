// lib/bloc/onboarding_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(const OnboardingState()) {
    on<UpdateAnswer>((event, emit) {
      final newAnswers = Map<String, dynamic>.from(state.answers);
      newAnswers[event.questionId] = event.answerValue;
      emit(state.copyWith(
        answers: newAnswers,
      ));
      debugPrint(
          "OnboardingBloc State Updated - Answers: ${state.copyWith(answers: newAnswers).answers}");
    });

    on<CompleteOnboarding>((event, emit) {
      // Créer une copie des réponses actuelles pour y ajouter 'completed': true
      final Map<String, dynamic> completedAnswers = Map<String, dynamic>.from(state.answers);
      completedAnswers['completed'] = true; // <<--- AJOUT CRUCIAL

      debugPrint(
          "OnboardingBloc: CompleteOnboarding event received. Current answers: ${state.answers}. Answers to be emitted: $completedAnswers");

      // Émettre un état indiquant que le processus d'onboarding est terminé,
      // ET que les réponses incluent maintenant 'completed': true.
      // Le BlocListener dans OnboardingScreen utilisera state.answers (qui est maintenant completedAnswers)
      // pour le passer à SignUpScreen.
      emit(state.copyWith(
        answers: completedAnswers, // <<--- Utiliser les réponses mises à jour
        status: OnboardingStatus.complete,
      ));
      debugPrint(
          "OnboardingBloc State Updated - Status: ${OnboardingStatus.complete}, Emitted Answers: $completedAnswers");
    });
  }
}
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
      final Map<String, dynamic> completedAnswers =
          Map<String, dynamic>.from(state.answers);
      completedAnswers['completed'] = true;

      debugPrint(
          "OnboardingBloc: CompleteOnboarding event received. Current answers: ${state.answers}. Answers to be emitted: $completedAnswers");

      emit(state.copyWith(
        answers: completedAnswers,
        status: OnboardingStatus.complete,
      ));
      debugPrint(
          "OnboardingBloc State Updated - Status: ${OnboardingStatus.complete}, Emitted Answers: $completedAnswers");
    });
  }
}

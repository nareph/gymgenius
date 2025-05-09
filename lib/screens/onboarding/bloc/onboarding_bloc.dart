// lib/bloc/onboarding_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(const OnboardingState()) {
    // Uses const constructor for initial state

    // Handles updating an answer for a specific question
    on<UpdateAnswer>((event, emit) {
      // Create a new map based on the current state's answers (immutability)
      final newAnswers = Map<String, dynamic>.from(state.answers);

      // Update or add the answer for the given questionId
      newAnswers[event.questionId] = event.answerValue;

      // Emit the new state with the updated answers
      // Status remains 'initial' or 'inProgress' as onboarding is not yet complete
      emit(state.copyWith(
        answers: newAnswers,
        // status: OnboardingStatus.initial // Or OnboardingStatus.inProgress if you have such a state
        // Keeping it initial seems fine as per original logic.
      ));
      debugPrint(
          "OnboardingBloc State Updated - Answers: ${state.copyWith(answers: newAnswers).answers}"); // Debug log
    });

    // Handles the completion of the onboarding process (e.g., user skips or answers the last question)
    on<CompleteOnboarding>((event, emit) {
      debugPrint(
          "OnboardingBloc: CompleteOnboarding event received. Final Answers: ${state.answers}");

      // Emit a state indicating that the onboarding process is complete.
      // Navigation will typically be handled by a BlocListener in the UI layer
      // listening for this status change.
      emit(state.copyWith(status: OnboardingStatus.complete));
      debugPrint(
          "OnboardingBloc State Updated - Status: ${state.copyWith(status: OnboardingStatus.complete).status}"); // Debug log
    });
  }
}

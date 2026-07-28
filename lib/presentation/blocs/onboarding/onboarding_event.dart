// onboarding_event.dart
part of 'onboarding_bloc.dart';

// --- Onboarding Events ---
// All onboarding events will extend this sealed class.
// Using Equatable for value comparison, which is useful for testing and state management.
sealed class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props =>
      []; // Default props for events without specific data
}

// Event triggered to update the answer for a single question
class UpdateAnswer extends OnboardingEvent {
  final String questionId; // The ID of the question being answered
  final dynamic answerValue; // The value of the answer.
  // Can be a String (e.g., for single choice)
  // or List<String> (e.g., for multiple choice)
  // or Map<String, dynamic> (e.g., for numeric inputs like physical_stats)

  const UpdateAnswer({required this.questionId, required this.answerValue});

  @override
  List<Object?> get props =>
      [questionId, answerValue]; // Include properties for Equatable comparison
}

// Event triggered when the user completes or skips the onboarding process
class CompleteOnboarding extends OnboardingEvent {
  // This event might not need specific data if it simply signals completion.
  // If, for example, the method of completion (skipped vs. fully answered) matters,
  // you could add properties here.
}

// onboarding_state.dart
part of 'onboarding_bloc.dart';

// --- Onboarding Status Enum ---
// Represents the different states the onboarding process can be in.
enum OnboardingStatus {
  initial, // Not yet started or in progress.
  // inProgress, // Could be an alternative or addition to 'initial' if more granularity is needed.
  validating, // Optional: if asynchronous validation of answers is required.
  complete, // All necessary data is gathered, ready for submission or navigation.
  error, // Optional: if an error occurs during the onboarding process (e.g., data validation failure).
}

// --- Onboarding State ---
// Represents the current state of the onboarding process, including user answers and status.
class OnboardingState extends Equatable {
  // Stores the user's answers. Key = questionId, Value can be:
  // - String (for single-choice answers)
  // - List<String> (for multiple-choice answers)
  // - Map<String, dynamic> (for complex inputs like physical_stats)
  final Map<String, dynamic> answers;
  final OnboardingStatus status;

  const OnboardingState({
    this.answers = const {}, // Initialize with an empty map of answers.
    this.status = OnboardingStatus.initial, // Default status is 'initial'.
  });

  // Utility method to create a new state instance with updated values (immutability).
  OnboardingState copyWith({
    Map<String, dynamic>? answers,
    OnboardingStatus? status,
  }) {
    return OnboardingState(
      answers: answers ??
          this.answers, // Use new value if provided, else keep current.
      status: status ??
          this.status, // Use new value if provided, else keep current.
    );
  }

  @override
  // Properties included for Equatable comparison.
  // This ensures that the BLoC only emits new states if 'answers' or 'status' actually change.
  List<Object> get props => [answers, status];
}

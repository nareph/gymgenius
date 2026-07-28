// lib/utils/enums.dart

/// Represents the different states of the AI routine generation process.
enum RoutineGenerationState {
  idle, // No generation process is active
  loading, // Generation is currently in progress
  success, // Generation completed successfully
  error // An error occurred during generation
}

// You can add other enums here as your app grows, for example:
// enum WorkoutDayStatus { planned, completed, skipped }
// enum ExerciseType { strength, cardio, flexibility }

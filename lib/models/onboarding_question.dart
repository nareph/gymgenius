// lib/models/onboarding_question.dart

enum QuestionType {
  singleChoice,
  multipleChoice,
  numericInput // New type for stats
}

class AnswerOption {
  final String value; // The value to be stored/sent to backend
  final String text; // The text displayed to the user
  const AnswerOption({required this.value, required this.text});
}

class OnboardingQuestion {
  final String id; // Unique identifier for the question
  final String text; // The question text displayed to the user
  final List<AnswerOption> options; // Can be empty for numericInput
  final QuestionType type; // Type of question/view to use

  const OnboardingQuestion({
    required this.id,
    required this.text,
    this.options = const [], // Defaults to an empty list
    required this.type,
  });
}

// --- Updated and added questions ---
// This list is global and intended to be imported where needed, e.g., in ProfileTabScreen.
final List<OnboardingQuestion> defaultOnboardingQuestions = [
  // 1. Goal
  OnboardingQuestion(
    id: "goal",
    text: "What is your primary fitness goal?",
    options: [
      AnswerOption(value: "build_muscle", text: "Build Muscle"),
      AnswerOption(value: "improve_endurance", text: "Improve Endurance"),
      AnswerOption(value: "lose_fat", text: "Lose Fat"),
      AnswerOption(value: "increase_strength", text: "Increase Strength"),
    ],
    type: QuestionType.singleChoice,
  ),
  // 2. Gender
  OnboardingQuestion(
    id: "gender",
    text: "What's your gender?",
    options: [
      AnswerOption(value: "male", text: "Male"),
      AnswerOption(value: "female", text: "Female"),
      // Consider adding "Prefer not to say" or "Other" if relevant for your app
    ],
    type: QuestionType.singleChoice,
  ),
  // 3. Physical Stats
  OnboardingQuestion(
    id: "physical_stats", // This ID is used for special handling of numeric inputs
    text: "Tell us a bit about yourself", // General title for the stats section
    type: QuestionType
        .numericInput, // Indicates this is for numeric inputs (likely handled as a nested map in data)
  ),
  // 4. Experience Level
  OnboardingQuestion(
    id: "experience",
    text: "What is your current fitness level?",
    options: [
      AnswerOption(value: "beginner", text: "Beginner (New to exercise)"),
      AnswerOption(
          value: "intermediate", text: "Intermediate (Consistent 6+ months)"),
      AnswerOption(value: "advanced", text: "Advanced (Years of experience)"),
    ],
    type: QuestionType.singleChoice,
  ),
  // 5. Frequency (How many times)
  OnboardingQuestion(
    id: "frequency",
    text: "How often can you train per week?",
    options: [
      AnswerOption(value: "2-3", text: "2-3 days/week"),
      AnswerOption(value: "4-5", text: "4-5 days/week"),
      AnswerOption(value: "6-7", text: "6-7 days/week"),
    ],
    type: QuestionType.singleChoice,
  ),
  // 6. Available Days (When)
  OnboardingQuestion(
    id: "workout_days",
    text: "When can you exercise? (Select preferred days)",
    options: [
      AnswerOption(value: "mon", text: "Monday"),
      AnswerOption(value: "tue", text: "Tuesday"),
      AnswerOption(value: "wed", text: "Wednesday"),
      AnswerOption(value: "thu", text: "Thursday"),
      AnswerOption(value: "fri", text: "Friday"),
      AnswerOption(value: "sat", text: "Saturday"),
      AnswerOption(value: "sun", text: "Sunday"),
    ],
    type: QuestionType.multipleChoice,
  ),
  // 7. Equipment
  OnboardingQuestion(
    id: "equipment",
    text: "What equipment do you have access to? (Select all that apply)",
    options: [
      AnswerOption(
          value: "full_gym", text: "Full Gym (Machines & Free Weights)"),
      AnswerOption(value: "basic_home", text: "Basic Home (Dumbbells, Bands)"),
      AnswerOption(value: "bodyweight", text: "Bodyweight Only"),
    ],
    type: QuestionType.multipleChoice,
  ),
  // 8. Focus Areas
  OnboardingQuestion(
    id: "focus_areas",
    text: "Any specific body parts you want to focus on? (Optional)",
    options: [
      AnswerOption(value: "abs", text: "Abs"),
      AnswerOption(value: "chest", text: "Chest"),
      AnswerOption(value: "back", text: "Back"),
      AnswerOption(value: "shoulders", text: "Shoulders"),
      AnswerOption(value: "arms", text: "Arms"),
      AnswerOption(value: "legs", text: "Legs"),
      AnswerOption(value: "buttocks", text: "Buttocks / Glutes"),
    ],
    type: QuestionType.multipleChoice,
  ),
];

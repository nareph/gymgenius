// lib/models/onboarding_question.dart

enum QuestionType {
  singleChoice,
  multipleChoice,
  numericInput // Nouveau type pour les stats
}

class AnswerOption {
  final String value;
  final String text;
  const AnswerOption({required this.value, required this.text});
}

class OnboardingQuestion {
  final String id;
  final String text;
  final List<AnswerOption> options; // Peut être vide pour numericInput
  final QuestionType type; // Type de question/vue à utiliser

  const OnboardingQuestion({
    required this.id,
    required this.text,
    this.options = const [], // Par défaut liste vide
    required this.type,
  });
}

// --- Mise à jour et ajout des questions ---
// Cette liste est maintenant globale et sera importée dans ProfileTabScreen
final List<OnboardingQuestion> defaultOnboardingQuestions = [
  // 1. Objectif
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
  // 2. Genre
  OnboardingQuestion(
    id: "gender",
    text: "What's your gender?",
    options: [
      AnswerOption(value: "male", text: "Male"),
      AnswerOption(value: "female", text: "Female"),
    ],
    type: QuestionType.singleChoice,
  ),
  // 3. Stats Physiques
  OnboardingQuestion(
    id: "physical_stats", // Cet ID est utilisé pour le traitement spécial
    text:
        "Tell us a bit about yourself", // Titre général pour la section des stats
    type: QuestionType
        .numericInput, // Indique que c'est pour des saisies numériques (map imbriqué)
  ),
  // 4. Niveau d'Expérience
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
  // 5. Fréquence (Combien de fois)
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
  // 6. Jours disponibles (Quand)
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
  // 7. Équipement
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
  // 8. Zones Focus
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

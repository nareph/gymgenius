// lib/presentation/question/profile_questions.dart

import 'package:gymgenius/domain/enums/activity_level.dart';
import 'package:gymgenius/domain/enums/budget_level.dart';
import 'package:gymgenius/domain/enums/equipment_type.dart';
import 'package:gymgenius/domain/enums/experience_level.dart';
import 'package:gymgenius/domain/enums/fitness_goal.dart';
import 'package:gymgenius/domain/enums/gender.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/domain/enums/session_duration.dart';
import 'package:gymgenius/domain/enums/workout_day.dart';
import 'package:gymgenius/domain/enums/workout_frequency.dart';

// ============================================================
// Enums & Helpers
// ============================================================

enum QuestionType {
  singleChoice,
  multipleChoice,
  numericInput,
}

class AnswerOption {
  final String value;
  final String text;
  const AnswerOption({required this.value, required this.text});
}

class ProfileQuestion {
  final String id;
  final String text;
  final List<AnswerOption> options;
  final QuestionType type;
  final bool isRequired;

  const ProfileQuestion({
    required this.id,
    required this.text,
    this.options = const [],
    required this.type,
    this.isRequired = true,
  });
}

/// Metadata for physical stats fields.
const List<({String key, String unit, String label, String hint})>
    statSubKeyEntries = [
  (key: 'age', unit: 'years', label: 'Age', hint: 'e.g., 25'),
  (key: 'height_m', unit: 'm', label: 'Height', hint: 'e.g., 1.75'),
  (key: 'weight_kg', unit: 'kg', label: 'Weight', hint: 'e.g., 70.5'),
  (
    key: 'target_weight_kg',
    unit: 'kg',
    label: 'Target Weight',
    hint: 'e.g., 65 (optional)'
  ),
];

// ============================================================
// All questions
// ============================================================

/// All questions required to build a complete HealthProfile.
final List<ProfileQuestion> defaultProfileQuestions = [
  // ============================================================
  // 1. Goal
  // ============================================================
  ProfileQuestion(
    id: "goal",
    text: "What is your primary fitness goal?",
    options: FitnessGoal.values
        .map((e) => AnswerOption(
              value: e.value,
              text: e.displayName,
            ))
        .toList(),
    type: QuestionType.singleChoice,
  ),

  // ============================================================
  // 2. Gender
  // ============================================================
  ProfileQuestion(
    id: "gender",
    text: "What's your gender?",
    options: Gender.values
        .map((e) => AnswerOption(
              value: e.value,
              text: e.displayName,
            ))
        .toList(),
    type: QuestionType.singleChoice,
  ),

  // ============================================================
  // 3. Physical Stats (numeric)
  // ============================================================
  ProfileQuestion(
    id: "physical_stats",
    text: "Tell us a bit about yourself",
    type: QuestionType.numericInput,
  ),

  // ============================================================
  // 4. Experience Level
  // ============================================================
  ProfileQuestion(
    id: "experience",
    text: "What is your current fitness/strength training experience level?",
    options: ExperienceLevel.values
        .map((e) => AnswerOption(
              value: e.value,
              text: e.displayName,
            ))
        .toList(),
    type: QuestionType.singleChoice,
  ),

  // ============================================================
  // 5. Activity Level
  // ============================================================
  ProfileQuestion(
    id: "activity_level",
    text: "How active are you outside of your workouts?",
    options: ActivityLevel.values
        .map((e) => AnswerOption(
              value: e.value,
              text: e.displayName,
            ))
        .toList(),
    type: QuestionType.singleChoice,
  ),

  // ============================================================
  // 6. Workout Frequency
  // ============================================================
  ProfileQuestion(
    id: "frequency",
    text: "How many days per week can you train?",
    options: WorkoutFrequency.values
        .map((e) => AnswerOption(
              value: e.value,
              text: e.displayName,
            ))
        .toList(),
    type: QuestionType.singleChoice,
  ),

  // ============================================================
  // 7. Session Duration
  // ============================================================
  ProfileQuestion(
    id: "session_duration_minutes",
    text: "How much time can you dedicate to each workout session, on average?",
    options: SessionDuration.values
        .map((e) => AnswerOption(
              value: e.value,
              text: e.displayName,
            ))
        .toList(),
    type: QuestionType.singleChoice,
  ),

  // ============================================================
  // 8. Preferred Workout Days
  // ============================================================
  ProfileQuestion(
    id: "workout_days",
    text: "Which days do you prefer to train? (Select all that apply)",
    options: WorkoutDay.values
        .map((e) => AnswerOption(
              value: e.value,
              text: e.displayName,
            ))
        .toList(),
    type: QuestionType.multipleChoice,
  ),

  // ============================================================
  // 9. Equipment
  // ============================================================
  ProfileQuestion(
    id: "equipment",
    text: "What equipment do you have access to? (Check all that apply)",
    options: EquipmentType.values
        .map((e) => AnswerOption(
              value: e.value,
              text: e.displayName,
            ))
        .toList(),
    type: QuestionType.multipleChoice,
  ),

  // ============================================================
  // 10. Focus Areas (optional)
  // ============================================================
  ProfileQuestion(
    id: "focus_areas",
    text: "Any specific body parts you'd like to focus on? (Optional)",
    options: MuscleGroup.values
        .map((e) => AnswerOption(
              value: e.value,
              text: e.displayName,
            ))
        .toList(),
    type: QuestionType.multipleChoice,
    isRequired: false,
  ),

  // ============================================================
  // 11. Avoided Muscles (optional)
  // ============================================================
  ProfileQuestion(
    id: "avoided_muscles",
    text:
        "Any body parts you need to avoid because of injury or pain? (Optional)",
    options: MuscleGroup.values
        .map((e) => AnswerOption(
              value: e.value,
              text: e.displayName,
            ))
        .toList(),
    type: QuestionType.multipleChoice,
    isRequired: false,
  ),

  // ============================================================
  // 12. Food Budget (optional)
  // ============================================================
  ProfileQuestion(
    id: "food_budget",
    text: "What's your budget for groceries and meals? (Optional)",
    options: BudgetLevel.values
        .map((e) => AnswerOption(
              value: e.value,
              text: e.displayName,
            ))
        .toList(),
    type: QuestionType.singleChoice,
    isRequired: false,
  ),

  // ============================================================
  // 13. Food Restrictions / Allergies (optional)
  // ============================================================
  ProfileQuestion(
    id: "food_restrictions",
    text: "Any food allergies or restrictions we should know about? (Optional)",
    options: [
      AnswerOption(value: "vegetarian", text: "Vegetarian"),
      AnswerOption(value: "vegan", text: "Vegan"),
      AnswerOption(value: "peanut", text: "Peanut / Groundnut Allergy"),
      AnswerOption(value: "fish", text: "Fish / Seafood Allergy"),
      AnswerOption(value: "egg", text: "Egg Allergy"),
      AnswerOption(value: "dairy", text: "Dairy / Lactose Intolerance"),
      AnswerOption(value: "gluten", text: "Gluten Intolerance"),
    ],
    type: QuestionType.multipleChoice,
    isRequired: false,
  ),

  // ============================================================
  // 14. Food Preferences (optional)
  // ============================================================
  ProfileQuestion(
    id: "food_preferences",
    text:
        "Any foods you especially enjoy? We'll prioritize them when possible. (Optional)",
    options: [
      AnswerOption(value: "rice", text: "Rice"),
      AnswerOption(value: "plantain", text: "Plantain"),
      AnswerOption(value: "cassava", text: "Cassava"),
      AnswerOption(value: "beans", text: "Beans"),
      AnswerOption(value: "fish", text: "Fish"),
      AnswerOption(value: "chicken", text: "Chicken"),
      AnswerOption(value: "beef", text: "Beef"),
      AnswerOption(value: "vegetables", text: "Vegetables"),
      AnswerOption(value: "fruits", text: "Fruits"),
      AnswerOption(value: "eggs", text: "Eggs"),
    ],
    type: QuestionType.multipleChoice,
    isRequired: false,
  ),

  // ============================================================
  // 15. Country
  // ============================================================
  ProfileQuestion(
    id: "country",
    text: "Which country do you currently live in?",
    options: [
      AnswerOption(value: "Cameroon", text: "Cameroon"),
      AnswerOption(value: "Nigeria", text: "Nigeria"),
      AnswerOption(value: "Ghana", text: "Ghana"),
      AnswerOption(value: "Kenya", text: "Kenya"),
      AnswerOption(value: "South Africa", text: "South Africa"),
      AnswerOption(value: "USA", text: "USA"),
      AnswerOption(value: "UK", text: "United Kingdom"),
      AnswerOption(value: "France", text: "France"),
      AnswerOption(value: "Germany", text: "Germany"),
      AnswerOption(value: "Other", text: "Other"),
    ],
    type: QuestionType.singleChoice,
  ),
];

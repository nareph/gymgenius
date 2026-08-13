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

  const ProfileQuestion({
    required this.id,
    required this.text,
    this.options = const [],
    required this.type,
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

/// All questions required to build a complete HealthProfile.
final List<ProfileQuestion> defaultProfileQuestions = [
  // 1. Goal
  ProfileQuestion(
    id: "goal",
    text: "What is your primary fitness goal?",
    options: [
      AnswerOption(value: "build_muscle", text: "Build Muscle / Hypertrophy"),
      AnswerOption(value: "increase_strength", text: "Increase Strength"),
      AnswerOption(value: "lose_fat", text: "Lose Fat / Get Lean"),
      AnswerOption(
          value: "improve_endurance", text: "Improve Cardiovascular Endurance"),
      AnswerOption(
          value: "general_fitness", text: "General Fitness / Well-being"),
    ],
    type: QuestionType.singleChoice,
  ),
  // 2. Gender
  ProfileQuestion(
    id: "gender",
    text: "What's your gender?",
    options: [
      AnswerOption(value: "male", text: "Male"),
      AnswerOption(value: "female", text: "Female"),
      AnswerOption(value: "prefer_not_to_say", text: "Prefer not to say"),
    ],
    type: QuestionType.singleChoice,
  ),
  // 3. Physical Stats (age, height, weight, target weight)
  ProfileQuestion(
    id: "physical_stats",
    text: "Tell us a bit about yourself",
    type: QuestionType.numericInput,
  ),
  // 4. Experience Level
  ProfileQuestion(
    id: "experience",
    text: "What is your current fitness/strength training experience level?",
    options: [
      AnswerOption(
          value: "beginner",
          text: "Beginner (Less than 6 months of consistent training)"),
      AnswerOption(
          value: "intermediate",
          text: "Intermediate (6 months to 2 years of consistent training)"),
      AnswerOption(
          value: "advanced",
          text: "Advanced (More than 2 years of serious, structured training)"),
    ],
    type: QuestionType.singleChoice,
  ),
  // 5. Activity Level (NEW)
  ProfileQuestion(
    id: "activity_level",
    text: "How active are you outside of your workouts?",
    options: [
      AnswerOption(
          value: "sedentary",
          text: "Sedentary (desk job, little daily movement)"),
      AnswerOption(
          value: "lightly_active",
          text: "Lightly Active (some walking or light activity)"),
      AnswerOption(
          value: "moderately_active",
          text: "Moderately Active (active job or regular walking)"),
      AnswerOption(
          value: "very_active",
          text: "Very Active (physically demanding job or daily sports)"),
      AnswerOption(
          value: "extra_active",
          text: "Extra Active (athlete, heavy physical labor)"),
    ],
    type: QuestionType.singleChoice,
  ),
  // 6. Frequency
  ProfileQuestion(
    id: "frequency",
    text: "How many days per week can you train?",
    options: [
      AnswerOption(value: "1-2", text: "1-2 days / week"),
      AnswerOption(value: "3-4", text: "3-4 days / week"),
      AnswerOption(value: "5-plus", text: "5+ days / week"),
    ],
    type: QuestionType.singleChoice,
  ),
  // 7. Session Duration
  ProfileQuestion(
    id: "session_duration_minutes",
    text: "How much time can you dedicate to each workout session, on average?",
    options: [
      AnswerOption(
          value: "short_30_max", text: "30 minutes or less (Quick session)"),
      AnswerOption(value: "medium_45", text: "Around 45 minutes"),
      AnswerOption(
          value: "standard_60", text: "Around 60 minutes (Standard session)"),
      AnswerOption(value: "long_75_90", text: "75-90 minutes (Longer session)"),
      AnswerOption(
          value: "very_long_90_plus",
          text: "More than 90 minutes (Extended session)"),
    ],
    type: QuestionType.singleChoice,
  ),
  // 8. Preferred Workout Days
  ProfileQuestion(
    id: "workout_days",
    text: "Which days do you prefer to train? (Select all that apply)",
    options: [
      AnswerOption(value: "monday", text: "Monday"),
      AnswerOption(value: "tuesday", text: "Tuesday"),
      AnswerOption(value: "wednesday", text: "Wednesday"),
      AnswerOption(value: "thursday", text: "Thursday"),
      AnswerOption(value: "friday", text: "Friday"),
      AnswerOption(value: "saturday", text: "Saturday"),
      AnswerOption(value: "sunday", text: "Sunday"),
    ],
    type: QuestionType.multipleChoice,
  ),
  // 9. Equipment
  ProfileQuestion(
    id: "equipment",
    text: "What equipment do you have access to? (Check all that apply)",
    options: [
      AnswerOption(value: "bodyweight", text: "Bodyweight (no equipment)"),
      AnswerOption(
          value: "resistance_bands",
          text: "Resistance Bands (elastic loops or tubes)"),
      AnswerOption(value: "jump_rope", text: "Jump Rope"),
      AnswerOption(
          value: "stairs_or_step", text: "Stairs or a sturdy step/low bench"),
      AnswerOption(
          value: "chair_or_simple_bench",
          text: "Sturdy Chair or Simple Bench (non-adjustable)"),
      AnswerOption(
          value: "dumbbells", text: "Dumbbells (fixed or adjustable pair)"),
      AnswerOption(value: "kettlebell", text: "Kettlebell(s)"),
      AnswerOption(
          value: "homemade_weights",
          text: "Homemade Weights (e.g., sandbags, filled water bottles)"),
      AnswerOption(
          value: "barbell_and_plates", text: "Barbell and Weight Plates"),
      AnswerOption(
          value: "pull_up_bar_accessible",
          text: "Access to a Pull-up Bar (doorway, wall-mounted, or station)"),
      AnswerOption(
          value: "dip_station_or_parallel_bars",
          text: "Access to Dip Bars / Parallel Bars"),
      AnswerOption(
          value: "adjustable_bench",
          text: "Adjustable Bench (incline/decline)"),
      AnswerOption(
          value: "gym_machines_selectorized",
          text: "Selectorized Weight Machines (pin-loaded)"),
      AnswerOption(
          value: "cable_machine_pulley",
          text: "Cable Machine / Pulley System (functional trainer)"),
      AnswerOption(
          value: "smith_machine", text: "Smith Machine (guided barbell)"),
      AnswerOption(value: "leg_press_machine", text: "Leg Press Machine"),
      AnswerOption(value: "hack_squat_machine", text: "Hack Squat Machine"),
      AnswerOption(
          value: "leg_extension_machine", text: "Leg Extension Machine"),
      AnswerOption(
          value: "leg_curl_machine",
          text: "Leg Curl Machine (lying or seated)"),
      AnswerOption(value: "cardio_treadmill", text: "Treadmill"),
      AnswerOption(value: "cardio_stationary_bike", text: "Stationary Bike"),
      AnswerOption(value: "cardio_elliptical", text: "Elliptical Trainer"),
      AnswerOption(value: "cardio_rowing_machine", text: "Rowing Machine"),
      AnswerOption(
          value: "open_space_for_running_sprints",
          text: "Open Space for Running / Sprints"),
      AnswerOption(value: "fitness_mat", text: "Fitness / Yoga Mat"),
      AnswerOption(
          value: "foam_roller_massage_ball",
          text: "Foam Roller / Massage Ball"),
      AnswerOption(value: "ab_wheel", text: "Ab Wheel"),
    ],
    type: QuestionType.multipleChoice,
  ),
  // 10. Focus Areas (optional)
  ProfileQuestion(
    id: "focus_areas",
    text: "Any specific body parts you'd like to focus on? (Optional)",
    options: [
      AnswerOption(value: "chest", text: "Chest"),
      AnswerOption(value: "back", text: "Back"),
      AnswerOption(value: "shoulders", text: "Shoulders"),
      AnswerOption(value: "biceps", text: "Biceps"),
      AnswerOption(value: "triceps", text: "Triceps"),
      AnswerOption(value: "quadriceps", text: "Quadriceps (front of thighs)"),
      AnswerOption(value: "hamstrings", text: "Hamstrings (back of thighs)"),
      AnswerOption(value: "glutes", text: "Glutes (buttocks)"),
      AnswerOption(value: "calves", text: "Calves"),
      AnswerOption(value: "abs_core", text: "Abs / Core"),
    ],
    type: QuestionType.multipleChoice,
  ),
  // 10b. Avoided muscles (optional — injury / medical restriction)
  ProfileQuestion(
    id: "avoided_muscles",
    text:
        "Any body parts you need to avoid because of injury or pain? (Optional)",
    options: [
      AnswerOption(value: "chest", text: "Chest"),
      AnswerOption(value: "back", text: "Back"),
      AnswerOption(value: "shoulders", text: "Shoulders"),
      AnswerOption(value: "biceps", text: "Biceps"),
      AnswerOption(value: "triceps", text: "Triceps"),
      AnswerOption(value: "quadriceps", text: "Quadriceps (front of thighs)"),
      AnswerOption(value: "hamstrings", text: "Hamstrings (back of thighs)"),
      AnswerOption(value: "glutes", text: "Glutes (buttocks)"),
      AnswerOption(value: "calves", text: "Calves"),
      AnswerOption(value: "abs_core", text: "Abs / Core"),
      AnswerOption(value: "forearms", text: "Forearms"),
      AnswerOption(value: "traps", text: "Traps"),
    ],
    type: QuestionType.multipleChoice,
  ),
  // 11. Country (NEW – used for nutrition localization)
  ProfileQuestion(
    id: "country",
    text: "Which country do you currently live in?",
    options: [
      // You can expand this list as needed.
      // For now, we keep a basic list; you can add more countries.
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

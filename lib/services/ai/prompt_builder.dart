// lib/services/ai/prompt_builder.dart
import 'package:gymgenius/services/ai/types.dart';

class PromptBuilder {
  static String buildRoutinePrompt({
    required OnboardingDataAI onboarding,
    required List<MuscleSplit> selectedSplit,
    required int workoutDaysCount,
    required bool useSpecifiedDays,
    List<AggregatedPerformanceData>? aggregatedPerformanceSummary,
    Map<String, dynamic>? previousRoutine,
    List<String>? regenerationInstructions,
  }) {
    final sections = <String>[];
// Core instruction
    sections.add(
      "Expert fitness AI. Generate ONLY valid JSON. Follow muscle split EXACTLY. "
      "No markdown, no explanations.",
    );

// User profile
    sections.add(
      "\n=== USER ===\n"
      "Goal: ${onboarding.goal ?? 'fitness'} | "
      "Level: ${onboarding.experience ?? 'beginner'} | "
      "Gender: ${onboarding.gender ?? 'n/a'}",
    );

// Session duration
    _addCompactSessionDuration(sections, onboarding);

// Muscle split
    _addCompactMuscleSplit(
      sections,
      selectedSplit,
      workoutDaysCount,
      useSpecifiedDays,
      onboarding,
    );

// Equipment
    _addCompactEquipment(sections, onboarding);

// Focus areas
    if (onboarding.focusAreas != null && onboarding.focusAreas!.isNotEmpty) {
      sections.add("Focus: ${onboarding.focusAreas!.join(', ')}");
    }

// Physical stats
    if (onboarding.physicalStats != null) {
      final stats = onboarding.physicalStats!;
      sections.add(
        "Stats: Age ${stats.age ?? 'N/A'}, "
        "${stats.weightKg ?? 'N/A'}kg → ${stats.targetWeightKg ?? 'N/A'}kg",
      );
    }

// Previous routine
    if (previousRoutine != null && previousRoutine['name'] != null) {
      sections.add(
        "Previous: ${previousRoutine['name']} "
        "(${previousRoutine['durationInWeeks'] ?? 'N/A'} weeks)",
      );
    }

// Regeneration instructions
    if (regenerationInstructions != null &&
        regenerationInstructions.isNotEmpty) {
      sections.add("\n=== REGENERATION ===");
      for (final instruction in regenerationInstructions) {
        sections.add("• $instruction");
      }
    }

// JSON structure with CRITICAL weight/timer instructions
    _addCompactJsonStructure(sections);

// Minimal example
    _addMinimalJsonExample(sections);

    return sections.join('\n');
  }

  static void _addCompactSessionDuration(
    List<String> sections,
    OnboardingDataAI onboarding,
  ) {
    String exerciseCount = "4-6 exercises";
    switch (onboarding.sessionDurationMinutes) {
      case 'short_30_max':
        exerciseCount = "3-4 exercises";
        break;
      case 'medium_45':
        exerciseCount = "4-5 exercises";
        break;
      case 'standard_60':
        exerciseCount = "5-6 exercises";
        break;
      case 'long_75_90':
        exerciseCount = "6-8 exercises";
        break;
      case 'very_long_90_plus':
        exerciseCount = "7-9 exercises";
        break;
    }

    sections.add(
      "Duration: ${onboarding.sessionDurationMinutes ?? 'standard_60'} → $exerciseCount",
    );
  }

  static void _addCompactMuscleSplit(
    List<String> sections,
    List<MuscleSplit> selectedSplit,
    int workoutDaysCount,
    bool useSpecifiedDays,
    OnboardingDataAI onboarding,
  ) {
    sections.add("\n=== $workoutDaysCount-DAY SPLIT ===");
    if (useSpecifiedDays &&
        onboarding.workoutDays != null &&
        onboarding.workoutDays!.isNotEmpty) {
      final workoutDays =
          onboarding.workoutDays!.map((d) => d.toLowerCase()).toList();

      for (int i = 0; i < workoutDays.length && i < selectedSplit.length; i++) {
        final day = workoutDays[i];
        final split = selectedSplit[i];
        sections.add(
          "${day.toUpperCase()}: ${split.theme} (${split.muscles.join(', ')})",
        );
      }

      sections.add("OTHER DAYS: Rest (empty array [])");
    } else {
      for (int i = 0; i < workoutDaysCount && i < selectedSplit.length; i++) {
        final split = selectedSplit[i];
        sections
            .add("Day ${i + 1}: ${split.theme} (${split.muscles.join(', ')})");
      }
    }

    sections.add(
      "\nRULES: Compound first. Synergistic muscles. 48-72h rest between same muscle.",
    );
  }

  static void _addCompactEquipment(
    List<String> sections,
    OnboardingDataAI onboarding,
  ) {
    if (onboarding.equipment != null && onboarding.equipment!.isNotEmpty) {
      final equipment = onboarding.equipment!;
      sections.add("Equipment: ${equipment.join(', ')} ONLY");
// Special note for resistance bands
      if (equipment.any((e) => e.toLowerCase().contains('resistance band'))) {
        sections.add(
          "IMPORTANT: Resistance band exercises use 'Bodyweight' for weightSuggestionKg. "
          "Bands provide resistance, not weight in kg.",
        );
      }
    } else {
      sections.add("Equipment: Bodyweight ONLY");
    }
  }

// Update JSON structure section
  static void _addCompactJsonStructure(List<String> sections) {
    sections.add(
      "\n=== JSON OUTPUT ===\n"
      "{\n"
      '  "name": "X-Day Split Name",\n'
      '  "durationInWeeks": 6,\n'
      '  "dailyWorkouts": {\n'
      '    "monday": [...], "tuesday": [], ..., "sunday": []\n'
      "  }\n"
      "}\n\n"
      "Exercise object:\n"
      "{\n"
      '  "name": "Exercise Name",\n'
      '  "sets": 3,\n'
      '  "reps": "8-12",  // OR "30s" for timed\n'
      '  "description": "Target: Muscles | Split: Theme\n\n1. Step\n2. Step",\n'
      '  "weightSuggestionKg": "Bodyweight",  // OR "20" for dumbbells/barbells\n'
      '  "restBetweenSetsSeconds": 60,\n'
      '  "usesWeight": false,  // true ONLY for dumbbells/barbells with numeric kg\n'
      '  "isTimed": false,  // true if reps contains "s" or duration\n'
      '  "targetDurationSeconds": 30  // ONLY if isTimed = true\n'
      "}\n\n"
      "WEIGHT RULES:\n"
      "- Dumbbells/Barbells: usesWeight=true, weightSuggestionKg='20'\n"
      "- Resistance Bands: usesWeight=false, weightSuggestionKg='Bodyweight'\n"
      "- Bodyweight: usesWeight=false, weightSuggestionKg='Bodyweight'\n"
      "- Homemade weights: usesWeight=true, weightSuggestionKg='15'\n\n"
      "TIMER RULES:\n"
      '- isTimed=true → MUST include "targetDurationSeconds"\n'
      '- isTimed=true → reps should be "30s" format\n'
      '- isTimed=false → NO "targetDurationSeconds"\n'
      "- Planks, holds, wall sits → isTimed=true",
    );
  }

  static void _addMinimalJsonExample(List<String> sections) {
    sections.add(
      "\n=== EXAMPLES ===\n"
      "Weighted exercise:\n"
      '{\n'
      '  "name": "Dumbbell Rows",\n'
      '  "sets": 3,\n'
      '  "reps": "10-12",\n'
      '  "description": "Target: Back | Split: Pull\n\n1. Bend at hips\n2. Pull weight to chest",\n'
      '  "weightSuggestionKg": "12.5",\n'
      '  "restBetweenSetsSeconds": 90,\n'
      '  "usesWeight": true,\n'
      '  "isTimed": false\n'
      '}\n\n'
      "Timed exercise:\n"
      '{\n'
      '  "name": "Plank Hold",\n'
      '  "sets": 3,\n'
      '  "reps": "45s",\n'
      '  "description": "Target: Core | Split: Core Work\n\n1. Forearm position\n2. Hold body straight",\n'
      '  "weightSuggestionKg": "Bodyweight",\n'
      '  "restBetweenSetsSeconds": 60,\n'
      '  "usesWeight": false,\n'
      '  "isTimed": true,\n'
      '  "targetDurationSeconds": 45\n'
      '}\n\n'
      "Bodyweight exercise:\n"
      '{\n'
      '  "name": "Push-ups",\n'
      '  "sets": 3,\n'
      '  "reps": "12-15",\n'
      '  "description": "Target: Chest, Triceps | Split: Push\n\n1. Plank\n2. Lower\n3. Push up",\n'
      '  "weightSuggestionKg": "Bodyweight",\n'
      '  "restBetweenSetsSeconds": 60,\n'
      '  "usesWeight": false,\n'
      '  "isTimed": false\n'
      '}\n\n'
      "CRITICAL: Output ONLY valid JSON. All 7 days MUST be present. "
      "Workout days = exercises array. Rest days = empty array [].\n"
      "ALWAYS set usesWeight and isTimed correctly!",
    );
  }
}

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

// Core instruction - ultra concise
    sections.add(
      "Expert fitness AI. Generate ONLY valid JSON. Follow muscle split EXACTLY. "
      "No markdown, no explanations.",
    );

// User profile - condensed
    sections.add(
      "\n=== USER ===\n"
      "Goal: ${onboarding.goal ?? 'fitness'} | "
      "Level: ${onboarding.experience ?? 'beginner'} | "
      "Gender: ${onboarding.gender ?? 'n/a'}",
    );

// Session duration - compact
    _addCompactSessionDuration(sections, onboarding);

// Muscle split - condensed
    _addCompactMuscleSplit(
      sections,
      selectedSplit,
      workoutDaysCount,
      useSpecifiedDays,
      onboarding,
    );

// Equipment - minimal
    _addCompactEquipment(sections, onboarding);

// Focus areas - if present
    if (onboarding.focusAreas != null && onboarding.focusAreas!.isNotEmpty) {
      sections.add("Focus: ${onboarding.focusAreas!.join(', ')}");
    }

// Physical stats - minimal
    if (onboarding.physicalStats != null) {
      final stats = onboarding.physicalStats!;
      sections.add(
        "Stats: Age ${stats.age ?? 'N/A'}, "
        "${stats.weightKg ?? 'N/A'}kg → ${stats.targetWeightKg ?? 'N/A'}kg",
      );
    }

// Previous routine context
    if (previousRoutine != null && previousRoutine['name'] != null) {
      sections.add(
        "Previous: ${previousRoutine['name']} "
        "(${previousRoutine['durationInWeeks'] ?? 'N/A'} weeks)",
      );
    }

// Regeneration instructions - if present
    if (regenerationInstructions != null &&
        regenerationInstructions.isNotEmpty) {
      sections.add("\n=== REGENERATION ===");
      for (final instruction in regenerationInstructions) {
        sections.add("• $instruction");
      }
    }

// JSON structure - ultra compact
    _addCompactJsonStructure(sections);

// Minimal example - single day only
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
      sections.add("Equipment: ${onboarding.equipment!.join(', ')} ONLY");
    } else {
      sections.add("Equipment: Bodyweight ONLY");
    }
  }

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
      '  "reps": "8-12",\n'
      '  "description": "Target: Muscles | Split: Theme\n\n1. Step 1\n2. Step 2",\n'
      '  "weightSuggestionKg": "Bodyweight",\n'
      '  "restBetweenSetsSeconds": 60,\n'
      '  "usesWeight": false,\n'
      '  "isTimed": false\n'
      "}",
    );
  }

  static void _addMinimalJsonExample(List<String> sections) {
    sections.add(
      "\n=== EXAMPLE (1 DAY) ===\n"
      '{\n'
      '  "name": "5-Day Push/Pull/Legs Split",\n'
      '  "durationInWeeks": 6,\n'
      '  "dailyWorkouts": {\n'
      '    "monday": [\n'
      '      {\n'
      '        "name": "Push-ups",\n'
      '        "sets": 3,\n'
      '        "reps": "12-15",\n'
      '        "description": "Target: Chest, Triceps | Split: Push\n\n1. Plank position\n2. Lower down\n3. Push up",\n'
      '        "weightSuggestionKg": "Bodyweight",\n'
      '        "restBetweenSetsSeconds": 60,\n'
      '        "usesWeight": false,\n'
      '        "isTimed": false\n'
      '      }\n'
      '    ],\n'
      '    "tuesday": [],\n'
      '    "wednesday": [...],\n'
      '    "thursday": [],\n'
      '    "friday": [...],\n'
      '    "saturday": [],\n'
      '    "sunday": []\n'
      '  }\n'
      '}\n\n'
      "CRITICAL: Output ONLY valid JSON. All 7 days MUST be present. "
      "Workout days = exercises array. Rest days = empty array [].",
    );
  }
}

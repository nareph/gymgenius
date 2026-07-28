// lib/core/services/ai/prompt_builder.dart

import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/domain/enums/exports.dart';
import 'package:gymgenius/domain/value_objects/workout_preferences.dart';
import 'package:gymgenius/engines/workout_engine/models/muscle_split.dart';

class PromptBuilder {
  // ============================================================
  // Full-generation prompt (LEGACY — kept for now in case
  // GeminiProgramGenerator.generate() is still called directly somewhere,
  // but the new pipeline no longer uses this for normal program creation:
  // WorkoutEngine always generates locally first, see GenerationService).
  // ============================================================

  static String buildProgramPrompt({
    required HealthProfile healthProfile,
    required List<MuscleSplit> selectedSplit,
    required int workoutDaysCount,
    required bool useSpecifiedDays,
    Map<String, dynamic>? previousProgram,
    Map<String, dynamic>? regenerationOptions,
  }) {
    final sections = <String>[];

    // Core instruction
    sections.add(
      "Expert fitness AI. Generate ONLY valid JSON. Follow muscle split EXACTLY. "
      "No markdown, no explanations.",
    );

    // User profile (from HealthProfile)
    final training = healthProfile.training;
    final body = healthProfile.body;
    sections.add(
      "\n=== USER ===\n"
      "Goal: ${training.goal.value} | "
      "Level: ${training.experience.value} | "
      "Gender: ${body.gender.value}",
    );

    // Session duration
    _addCompactSessionDuration(sections, training);

    // Muscle split
    _addCompactMuscleSplit(
      sections,
      selectedSplit,
      workoutDaysCount,
      useSpecifiedDays,
      training,
    );

    // Equipment - WITH STRICT CONSTRAINTS
    _addCompactEquipment(sections, training);

    // Focus areas
    if (training.focusAreas.isNotEmpty) {
      sections.add(
        "Focus: ${training.focusAreas.map((e) => e.value).join(', ')}",
      );
    }

    // Physical stats
    sections.add(
      "Stats: Age ${body.age}, "
      "${body.currentWeightKg}kg → "
      "${body.targetWeightKg ?? 'N/A'}kg",
    );

    // Previous Program
    if (previousProgram != null && previousProgram['name'] != null) {
      sections.add(
        "Previous: ${previousProgram['name']} "
        "(${previousProgram['durationInWeeks'] ?? 'N/A'} weeks)",
      );
    }

    // Regeneration instructions
    if (regenerationOptions != null &&
        regenerationOptions['instructions'] is List) {
      final instructions = regenerationOptions['instructions'] as List<String>;
      if (instructions.isNotEmpty) {
        sections.add("\n=== REGENERATION ===");
        for (final instruction in instructions) {
          sections.add("• $instruction");
        }
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
    WorkoutPreferences training,
  ) {
    String exerciseCount = "4-6 exercises";
    switch (training.sessionDuration) {
      case SessionDuration.short30:
        exerciseCount = "3-4 exercises";
        break;
      case SessionDuration.medium45:
        exerciseCount = "4-5 exercises";
        break;
      case SessionDuration.standard60:
        exerciseCount = "5-6 exercises";
        break;
      case SessionDuration.long75:
        exerciseCount = "6-8 exercises";
        break;
      case SessionDuration.veryLong90:
        exerciseCount = "7-9 exercises";
        break;
    }
    sections.add(
      "Duration: ${training.sessionDuration.value} → $exerciseCount",
    );
  }

  static void _addCompactMuscleSplit(
    List<String> sections,
    List<MuscleSplit> selectedSplit,
    int workoutDaysCount,
    bool useSpecifiedDays,
    WorkoutPreferences training,
  ) {
    sections.add("\n=== $workoutDaysCount-DAY SPLIT ===");
    if (useSpecifiedDays && training.preferredDays.isNotEmpty) {
      final workoutDays = training.preferredDays.map((e) => e.value).toList();
      for (int i = 0; i < workoutDays.length && i < selectedSplit.length; i++) {
        final day = workoutDays[i];
        final split = selectedSplit[i];
        sections.add(
          "${day.toUpperCase()}: ${split.theme} (${split.muscles.map((m) => m.value).join(', ')})",
        );
      }
      sections.add("OTHER DAYS: Rest (empty array [])");
    } else {
      for (int i = 0; i < workoutDaysCount && i < selectedSplit.length; i++) {
        final split = selectedSplit[i];
        sections.add(
          "Day ${i + 1}: ${split.theme} (${split.muscles.map((m) => m.value).join(', ')})",
        );
      }
    }
    sections.add(
      "\nRULES: Compound first. Synergistic muscles. 48-72h rest between same muscle.",
    );
  }

  static void _addCompactEquipment(
    List<String> sections,
    WorkoutPreferences training,
  ) {
    final equipment = training.equipment;
    if (equipment.isNotEmpty) {
      final equipmentValues = equipment.map((e) => e.value).join(', ');
      sections.add("Equipment: $equipmentValues ONLY");

      sections.add("\n=== EQUIPMENT RULES (CRITICAL) ===");

      final isBodyweightOnly =
          equipment.length == 1 && equipment.contains(EquipmentType.bodyweight);

      if (isBodyweightOnly) {
        sections.add("⚠️ BODYWEIGHT ONLY - User has NO equipment at all:\n"
            "✓ ALLOWED EXERCISES:\n"
            "  • Push-ups (standard, wide, diamond, decline)\n"
            "  • Squats (bodyweight, jump squats, pistol squats)\n"
            "  • Lunges (forward, reverse, walking, jumping)\n"
            "  • Planks (standard, side, reverse)\n"
            "  • Mountain climbers\n"
            "  • Burpees\n"
            "  • Glute bridges\n"
            "  • Crunches, leg raises, bicycle crunches\n"
            "  • Wall sits\n"
            "  • Jumping jacks, high knees\n"
            "  • Step-ups (using stairs)\n"
            "  • Bear crawls, crab walks\n\n"
            "✗ ABSOLUTELY FORBIDDEN:\n"
            "  • Pull-ups, chin-ups (requires pull-up bar)\n"
            "  • Inverted rows (requires bar or table)\n"
            "  • Dips (requires parallel bars or bench)\n"
            "  • Hanging exercises (no bar available)\n"
            "  • Any exercise requiring elevated equipment\n"
            "  • Any exercise requiring grip on bars/rings\n\n"
            "FOR BACK EXERCISES: Use only superman holds, reverse snow angels, "
            "prone Y-raises - NO pulling exercises since there's nothing to pull on!");
      } else {
        final constraints = <String>[];

        final hasPullUpBar =
            equipment.contains(EquipmentType.pullUpBarAccessible);

        if (!hasPullUpBar) {
          constraints.add("NO PULL-UP BAR:\n"
              "✗ FORBIDDEN: Pull-ups, chin-ups, hanging leg raises, "
              "muscle-ups, inverted rows, any hanging exercises");
        }

        final hasWeights = equipment.any((e) =>
            e == EquipmentType.dumbbells ||
            e == EquipmentType.barbellAndPlates ||
            e == EquipmentType.kettlebell ||
            e == EquipmentType.homemadeWeights);

        if (!hasWeights) {
          constraints.add("NO WEIGHTS:\n"
              "✗ FORBIDDEN: Any dumbbell, barbell, or weighted exercises\n"
              "✓ Use bodyweight progressions instead");
        }

        final hasMachines = equipment.any((e) =>
            e == EquipmentType.gymMachinesSelectorized ||
            e == EquipmentType.cableMachinePulley ||
            e == EquipmentType.smithMachine ||
            e == EquipmentType.legPressMachine ||
            e == EquipmentType.hackSquatMachine ||
            e == EquipmentType.legExtensionMachine ||
            e == EquipmentType.legCurlMachine);

        if (!hasMachines) {
          constraints.add("NO GYM MACHINES:\n"
              "✗ FORBIDDEN: Cable exercises, lat pulldown, leg press, "
              "smith machine, any machine exercises");
        }

        final hasBench = equipment.contains(EquipmentType.adjustableBench);

        if (!hasBench) {
          constraints.add("NO BENCH:\n"
              "✗ FORBIDDEN: Bench press, incline press, bench dips, "
              "step-ups on bench");
        }

        if (constraints.isNotEmpty) {
          sections.addAll(constraints);
        }

        if (equipment.contains(EquipmentType.resistanceBands)) {
          sections.add("\n✓ RESISTANCE BANDS AVAILABLE:\n"
              "Use for: Band rows (if no pull-up bar), chest press, "
              "lateral raises, bicep curls, tricep extensions, face pulls\n"
              "IMPORTANT: Use 'Bodyweight' for weightSuggestionKg with bands");
        }

        if (equipment.contains(EquipmentType.homemadeWeights)) {
          sections.add("\n✓ HOMEMADE WEIGHTS AVAILABLE:\n"
              "Use for: Curls, rows, overhead press, weighted squats, goblet squats\n"
              "Suggest moderate weights: 8-15kg");
        }
      }

      sections.add("\n⚠️⚠️⚠️ CRITICAL RULE ⚠️⚠️⚠️\n"
          "ONLY suggest exercises that can be performed with the EXACT equipment "
          "listed above. If an exercise requires equipment NOT in the user's list, "
          "DO NOT include it under ANY circumstances. When in doubt, use bodyweight "
          "alternatives.");
    } else {
      sections.add("Equipment: Bodyweight ONLY");
      sections.add("\n=== BODYWEIGHT ONLY CONSTRAINTS ===\n"
          "User has NO equipment. ONLY pure bodyweight exercises allowed.\n"
          "✓ ALLOWED: Push-ups, squats, lunges, planks, mountain climbers, burpees, "
          "glute bridges, crunches, leg raises, wall sits, jumping jacks, high knees\n"
          "✗ FORBIDDEN: Pull-ups, chin-ups, inverted rows, dips, hanging exercises, "
          "anything requiring bars, rings, benches, or elevated equipment\n"
          "FOR BACK: Use superman holds, reverse snow angels, prone raises ONLY");
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

  // ============================================================
  // Optimization prompt (CURRENT architecture — Gemini improves an
  // existing LOCAL program, it never generates one from scratch).
  // ============================================================

  /// Builds a prompt asking Gemini to OPTIMIZE an already-valid local
  /// [program] — not create a new one. Gemini may only return exercise
  /// NAMES (for ordering/substitution) plus optional coaching tips; it
  /// never controls sets/reps/rest/equipment directly. Those always come
  /// from the deterministic local pipeline (SetsBuilder/RepsBuilder/
  /// ExerciseBuilder) once a suggested name is validated against the
  /// local exercise pool — see GeminiProgramOptimizer._applyOptimizations.
  static String buildOptimizationPrompt({
    required TrainingProgram program,
    required HealthProfile profile,
    Map<String, dynamic>? options,
  }) {
    final sections = <String>[];

    sections.add(
      "Expert fitness AI. You will receive an ALREADY VALID, ALREADY "
      "COMPLETE training program built by a deterministic local engine. "
      "Your job is to OPTIMIZE it — you are NOT creating a new program.\n\n"
      "STRICT RULES:\n"
      "- Do NOT change which days have workouts vs rest.\n"
      "- Do NOT change the number of exercises in any day.\n"
      "- Do NOT invent equipment the user doesn't have.\n"
      "- Only suggest a substitution when it is a genuinely better choice "
      "for the split, goal, or exercise variety. Otherwise repeat the "
      "original exercise name exactly.\n"
      "- Output ONLY valid JSON. No markdown, no explanations.",
    );

    final training = profile.training;
    sections.add(
      "\n=== USER ===\n"
      "Goal: ${training.goal.value} | Level: ${training.experience.value} | "
      "Equipment: ${training.equipment.map((e) => e.value).join(', ')}",
    );

    final keepStructure = options?['keepStructure'] as bool? ?? true;
    sections.add(
      keepStructure
          ? "\nSTRUCTURE: Keep the exact same order per day (compound "
              "movements first). Only substitute a specific exercise name "
              "where a clearly better alternative exists — do not reorder "
              "or reshuffle exercises that are already well-placed."
          : "\nSTRUCTURE: You may reorder exercises within a day and "
              "substitute exercises for better alternatives, but the "
              "exercise COUNT per day must stay identical.",
    );

    final focusMuscles = options?['focusMuscles'];
    if (focusMuscles is List && focusMuscles.isNotEmpty) {
      sections.add(
          "\nPrioritize these muscles where a substitution makes sense: "
          "${focusMuscles.join(', ')}");
    }

    final avoidMuscles = options?['avoidMuscles'];
    if (avoidMuscles is List && avoidMuscles.isNotEmpty) {
      sections.add(
          "\nDo NOT suggest any exercise primarily targeting: "
          "${avoidMuscles.join(', ')}");
    }

    final intensity = options?['intensity'] as String?;
    if (intensity == 'harder') {
      sections.add(
          "\nWhere you do substitute, prefer slightly more challenging variations.");
    } else if (intensity == 'easier') {
      sections.add(
          "\nWhere you do substitute, prefer slightly easier, more accessible variations.");
    }

    sections.add("\n=== CURRENT PROGRAM ===");
    for (final entry in program.weeklySchedule.entries) {
      if (entry.value.isEmpty) continue;
      final names = entry.value.map((e) => e.name).join(', ');
      sections.add("${entry.key.toUpperCase()}: $names");
    }

    sections.add(
      "\n=== SUBSTITUTIONS ALLOWED ===\n"
      "You are not limited to exercises already in the program above. If "
      "you know a better exercise for this split/goal/equipment that "
      "isn't listed, suggest it — you are the expert here, the local list "
      "is just a starting point, not a hard limit.",
    );

    sections.add(
      "\n=== OUTPUT FORMAT ===\n"
      "Return ONLY this JSON shape: one array of exercise OBJECTS per "
      "workout day listed above (same keys, same array LENGTH as the "
      "current program for that day — do not add or remove exercises, "
      "only decide what each one is). Omit rest days entirely.\n"
      "For an exercise you are KEEPING unchanged, you may repeat just its "
      "name with placeholder sets/reps — those fields are ignored for "
      "exercises whose name matches the current program. For a NEW "
      "substitution, fill in sets/reps/targetMuscles/description "
      "accurately, since those values WILL be used.\n"
      "{\n"
      '  "monday": [\n'
      "    {\n"
      '      "name": "Exercise Name",\n'
      '      "sets": 4,\n'
      '      "reps": "8-10",\n'
      '      "targetMuscles": ["chest", "triceps"],\n'
      '      "usesWeight": true,\n'
      '      "isTimed": false,\n'
      '      "description": "1. Step\\n2. Step"\n'
      "    }\n"
      "  ],\n"
      '  "tips": ["Short tip 1", "Short tip 2"]\n'
      "}\n\n"
      "Valid targetMuscles values: chest, back, shoulders, biceps, triceps, "
      "quadriceps, hamstrings, glutes, calves, abs_core, forearms, traps.",
    );

    return sections.join('\n');
  }
}
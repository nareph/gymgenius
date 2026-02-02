import { AggregatedPerformanceData, MuscleSplit, OnboardingData, PreviousRoutineData } from "../types";

export function buildRoutinePrompt(
    onboarding: OnboardingData,
    selectedSplit: MuscleSplit[],
    workoutDaysCount: number,
    useSpecifiedDays: boolean,
    aggregatedPerformanceSummary: AggregatedPerformanceData[],
    previousRoutine?: PreviousRoutineData
): string {
    const promptSections: string[] = [
        "You are an expert fitness coach AI specialized in muscle split training. Your primary task is to generate a highly personalized weekly workout routine based on structured muscle group splits. Your entire output MUST be a single, valid JSON object conforming to the specified structure. Do not include any explanatory text, markdown formatting, or anything outside of this JSON object. Adherence to muscle split principles and specified workout days is PARAMOUNT.",
        "\n--- User Profile & Preferences (CRITICAL CONSTRAINTS) ---",
        `- Primary Fitness Goal: ${onboarding.goal || "Not specified"}`,
        `- Gender: ${onboarding.gender || "Not specified"}`,
        `- Experience Level: ${onboarding.experience || "Beginner"}`,
    ];

    addSessionDurationSection(promptSections, onboarding);
    addMuscleSplitSection(promptSections, selectedSplit, workoutDaysCount, useSpecifiedDays, onboarding);
    addEquipmentSection(promptSections, onboarding);
    addFocusAreasSection(promptSections, onboarding);
    addPhysicalStatsSection(promptSections, onboarding);
    addPerformanceDataSection(promptSections, aggregatedPerformanceSummary, previousRoutine);
    addExerciseExamplesSection(promptSections);
    addOutputStructureSection(promptSections);
    addJsonExampleSection(promptSections);
    addComplianceReminderSection(promptSections);

    return promptSections.join("\n");
}

function addSessionDurationSection(promptSections: string[], onboarding: OnboardingData) {
    if (onboarding.session_duration_minutes) {
        promptSections.push(`- CRITICAL CONSTRAINT - Available time per session: User selected category '${onboarding.session_duration_minutes}'. You MUST tailor the workout volume to this.`);
        let exerciseCountInstruction = "You MUST select 4-6 exercises.";
        switch (onboarding.session_duration_minutes) {
            case "short_30_max": exerciseCountInstruction = "You MUST select EXACTLY 3-4 exercises. Focus on compound movements or high intensity."; break;
            case "medium_45": exerciseCountInstruction = "You MUST select EXACTLY 4-5 exercises."; break;
            case "standard_60": exerciseCountInstruction = "You MUST select EXACTLY 5-6 exercises."; break;
            case "long_75_90": exerciseCountInstruction = "You MUST select EXACTLY 6-8 exercises. This duration allows for more volume, including accessory work."; break;
            case "very_long_90_plus": exerciseCountInstruction = "You MUST select EXACTLY 7-9 exercises. This can include multiple primary lifts and sufficient accessory/isolation work. Ensure the workout remains productive."; break;
        }
        promptSections.push(`  - EXERCISE COUNT PER WORKOUT DAY: ${exerciseCountInstruction}`);
    } else {
        promptSections.push("- Available time per session: Not specified. Assume a standard duration of about 45-60 minutes per workout. You MUST select 4-6 exercises per workout day.");
    }
}

function addMuscleSplitSection(
    promptSections: string[],
    selectedSplit: MuscleSplit[],
    workoutDaysCount: number,
    useSpecifiedDays: boolean,
    onboarding: OnboardingData
) {
    promptSections.push("\n--- MUSCLE SPLIT TRAINING SYSTEM (CRITICAL) ---");
    promptSections.push("You MUST follow a structured muscle split system. Each workout day focuses on specific muscle groups to ensure balanced development and optimal recovery.");

    if (useSpecifiedDays && onboarding.workout_days?.length) {
        promptSections.push(`- CRITICAL CONSTRAINT - Workout Days with Muscle Split Themes: User has SPECIFIED training on THESE EXACT ${workoutDaysCount} DAYS with assigned muscle groups:`);

        const workoutDays = onboarding.workout_days.map(day => day.toLowerCase());
        workoutDays.forEach((day, index) => {
            if (index < selectedSplit.length) {
                const split = selectedSplit[index];
                promptSections.push(`  - ${day.toUpperCase()}: ${split.theme}`);
                promptSections.push(`    Primary muscles: ${split.muscles.join(", ")}`);
                promptSections.push(`    Exercise focus: Select exercises that primarily target these muscle groups`);
            }
        });

        promptSections.push("- CRITICAL RULE: Each specified workout day MUST contain exercises that align with its assigned muscle group theme. ALL OTHER DAYS MUST BE REST DAYS (empty array in JSON).");
    } else {
        promptSections.push(`- MUSCLE SPLIT ASSIGNMENT: Create a ${workoutDaysCount}-day split with these themes:`);
        selectedSplit.forEach((split, index) => {
            if (index < workoutDaysCount) {
                promptSections.push(`  - Day ${index + 1}: ${split.theme}`);
                promptSections.push(`    Focus muscles: ${split.muscles.join(", ")}`);
            }
        });
        promptSections.push(`- For days not selected as workout days, they MUST BE REST DAYS (empty array in JSON).`);
    }

    promptSections.push("\n--- MUSCLE SPLIT TRAINING RULES ---");
    promptSections.push("1. EXERCISE COHESION: All exercises in a single workout day MUST work synergistic muscle groups as specified in the day's theme.");
    promptSections.push("2. COMPOUND MOVEMENTS FIRST: Start each session with compound exercises (multi-joint movements), then isolation exercises.");
    promptSections.push("3. MUSCLE GROUP PAIRING: Follow classic pairing principles:");
    promptSections.push("   - Push Day: Chest + Shoulders + Triceps (pushing movements)");
    promptSections.push("   - Pull Day: Back + Biceps + Rear Delts (pulling movements)");
    promptSections.push("   - Leg Day: Quadriceps + Hamstrings + Glutes + Calves");
    promptSections.push("   - Upper/Lower: Combine push and pull for upper, all leg muscles for lower");
    promptSections.push("4. RECOVERY CONSIDERATION: Ensure muscle groups have adequate rest between sessions (48-72 hours).");
}

function addEquipmentSection(promptSections: string[], onboarding: OnboardingData) {
    if (onboarding.equipment && onboarding.equipment.length > 0) {
        const equipmentList = onboarding.equipment.join(", ");
        promptSections.push(`\n--- Available Equipment ---`);
        promptSections.push(`- Available Equipment: ${equipmentList}.`);
        promptSections.push("- CRITICAL: You MUST select exercises that strictly use ONLY the equipment listed. If 'bodyweight' is listed, it can always be used. Do not assume access to unlisted items.");
        promptSections.push("- If 'homemade_weights' is listed, you can suggest exercises where improvised weights (like sandbags, water bottles) can be used, and mention this possibility in the exercise description.");
        promptSections.push("- If 'gym_machines_selectorized' is listed, assume access to common selectorized machines (e.g., leg press, chest press, lat pulldown, shoulder press machine, leg curl, leg extension). Specify which type of machine if relevant (e.g., 'Lat Pulldown Machine').");
    } else {
        promptSections.push("\n--- Available Equipment ---");
        promptSections.push("- Available Equipment: Bodyweight Only. ALL exercises MUST be strictly bodyweight while following the muscle split themes.");
    }
}

function addFocusAreasSection(promptSections: string[], onboarding: OnboardingData) {
    if (onboarding.focus_areas?.length) {
        promptSections.push(`\n--- Specific Focus Areas ---`);
        promptSections.push(`- User wants extra focus on: ${onboarding.focus_areas.join(", ")}`);
        promptSections.push("- Incorporate additional exercises or volume for these areas within the appropriate split days.");
    }
}

function addPhysicalStatsSection(promptSections: string[], onboarding: OnboardingData) {
    if (onboarding.physical_stats) {
        promptSections.push("\n--- Physical Statistics ---");
        if (onboarding.physical_stats.age != null) promptSections.push(`- Age: ${onboarding.physical_stats.age} years`);
        if (onboarding.physical_stats.weight_kg != null) promptSections.push(`- Current Weight: ${onboarding.physical_stats.weight_kg} kg`);
        if (onboarding.physical_stats.height_m != null) promptSections.push(`- Height: ${onboarding.physical_stats.height_m} meters`);
        if (onboarding.physical_stats.target_weight_kg != null) promptSections.push(`- Target Weight: ${onboarding.physical_stats.target_weight_kg} kg`);
    }
}

function addPerformanceDataSection(
    promptSections: string[],
    aggregatedPerformanceSummary: AggregatedPerformanceData[],
    previousRoutine?: PreviousRoutineData
) {
    if (aggregatedPerformanceSummary.length > 0) {
        promptSections.push("\n--- User Performance on Previous Routine (Use for Progression) ---");
        promptSections.push("Consider the following performance data to tailor progression in the new muscle split routine:");
        for (const perf of aggregatedPerformanceSummary) {
            let perfString = `- Exercise: "${perf.exerciseName}" (Target: ${perf.targetReps || "N/A"} @ ${perf.targetWeight || "N/A"})`;
            if (perf.averageReps !== undefined) perfString += `, Actual Avg Reps/Set: ${perf.averageReps}`;
            if (perf.maxWeightLiftedKg !== undefined) perfString += `, Actual Max Weight: ${perf.maxWeightLiftedKg}kg`;
            if (perf.completedRate !== undefined) perfString += `, Completion Rate: ${perf.completedRate}%`;
            promptSections.push(perfString);
        }
        promptSections.push("Use this data for progressive overload while maintaining muscle split principles.");
    } else if (previousRoutine?.id) {
        promptSections.push("\n--- Previous Routine Context ---");
        promptSections.push(`- Previous Plan Name: ${previousRoutine.name || "Unnamed"}`);
        if (previousRoutine.durationInWeeks != null) promptSections.push(`- Previous Plan Duration: ${previousRoutine.durationInWeeks} weeks`);
        promptSections.push("Base progression on general principles while implementing the new muscle split structure.");
    }
}

function addExerciseExamplesSection(promptSections: string[]) {
    promptSections.push("\n--- EXERCISE SELECTION EXAMPLES BY MUSCLE SPLIT ---");
    promptSections.push("Push Day (Chest/Shoulders/Triceps): Push-ups, Chest Press, Shoulder Press, Tricep Dips, Lateral Raises, Tricep Extensions");
    promptSections.push("Pull Day (Back/Biceps): Pull-ups, Rows, Lat Pulldowns, Bicep Curls, Face Pulls, Reverse Flyes");
    promptSections.push("Leg Day (Quads/Hamstrings/Glutes): Squats, Deadlifts, Lunges, Leg Press, Calf Raises, Hip Thrusts");
    promptSections.push("Upper Body: Mix of push and pull movements for all upper body muscles");
    promptSections.push("Lower Body: All leg and glute exercises, both knee-dominant and hip-dominant movements");
}

function addOutputStructureSection(promptSections: string[]) {
    promptSections.push("\n--- Output Structure & Instructions ---");
    promptSections.push("1. Generate 'name' (string) that reflects the muscle split approach (e.g., '3-Day Push/Pull/Legs Split', '4-Day Upper/Lower Split').");
    promptSections.push("2. Generate 'durationInWeeks' (number, typically 4, 6, or 8 weeks).");
    promptSections.push("3. Provide a 'dailyWorkouts' object containing keys for ALL 7 days of the week (\"monday\" through \"sunday\"). Keys MUST be lowercase.");
    promptSections.push("   - Workout days: MUST align with the muscle split themes specified above. Each day MUST have exercises that target the assigned muscle groups.");
    promptSections.push("   - Rest days: ALL OTHER DAYS MUST have an empty array [] as their value.");
    promptSections.push("4. Each exercise object MUST have:");
    promptSections.push("   - \"name\": string (clear exercise name that targets the day's muscle groups)");
    promptSections.push("   - \"sets\": number (positive integer, e.g., 3, 4)");
    promptSections.push("   - \"reps\": string (e.g., \"8-12\", \"AMRAP\", \"To Failure\", \"30s\", \"15\")");
    promptSections.push("   - \"description\": string (CRITICAL: Format: '**Target: [Primary muscles] | Split: [Day theme]**\\n\\n[Step-by-step instructions]'. Example: '**Target: Chest, Triceps, Shoulders | Split: Push Day**\\n\\n1. Position yourself in push-up stance...\\n2. Lower your body...\\n3. Push back up powerfully.' Use numbered list format for instructions. Focus on proper form and muscle engagement.)");
    promptSections.push("5. Include these exercise properties:");
    promptSections.push("   - \"weightSuggestionKg\": string (e.g., \"60\" for 60kg, \"Bodyweight\", \"Light\", \"Moderate\", \"Heavy\", \"N/A\" if not applicable)");
    promptSections.push("   - \"restBetweenSetsSeconds\": number (e.g., 45, 60, 90, 120)");
    promptSections.push("   - \"usesWeight\": boolean (true if external weight is typically used; false for bodyweight exercises)");
    promptSections.push("   - \"isTimed\": boolean (true if duration-based; false if rep-based)");
    promptSections.push("   - \"targetDurationSeconds\": number (ONLY include if isTimed is true AND specific duration, omit otherwise)");
}

function addJsonExampleSection(promptSections: string[]) {
    promptSections.push("\n--- JSON Structure Example (MUSCLE SPLIT APPROACH) ---");
    promptSections.push(`
{
  "name": "3-Day Push/Pull/Legs Split",
  "durationInWeeks": 6,
  "dailyWorkouts": {
    "monday": [
      {
        "name": "Push-ups", 
        "sets": 3, 
        "reps": "8-12", 
        "weightSuggestionKg": "Bodyweight", 
        "restBetweenSetsSeconds": 60, 
        "description": "**Target: Chest, Triceps, Shoulders | Split: Push Day**\\n\\n1. Start in high plank position with hands slightly wider than shoulder-width.\\n2. Body forms straight line from head to heels, engage core.\\n3. Lower body by bending elbows, keeping them close to body.\\n4. Lower until chest nearly touches floor.\\n5. Push back up powerfully to starting position.", 
        "usesWeight": false, 
        "isTimed": false
      }
    ],
    "tuesday": [],
    "wednesday": [
      {
        "name": "Pull-ups", 
        "sets": 3, 
        "reps": "AMRAP", 
        "weightSuggestionKg": "Bodyweight", 
        "restBetweenSetsSeconds": 90, 
        "description": "**Target: Back, Lats, Biceps | Split: Pull Day**\\n\\n1. Hang from pull-up bar with overhand grip, hands wider than shoulders.\\n2. Engage lats and pull shoulder blades down and back.\\n3. Pull body up until chin clears bar, leading with chest.\\n4. Lower with control, fully extending arms.", 
        "usesWeight": false, 
        "isTimed": false
      }
    ],
    "thursday": [],
    "friday": [
      {
        "name": "Bodyweight Squats", 
        "sets": 4, 
        "reps": "15-20", 
        "weightSuggestionKg": "Bodyweight", 
        "restBetweenSetsSeconds": 60, 
        "description": "**Target: Quadriceps, Glutes, Hamstrings | Split: Leg Day**\\n\\n1. Stand with feet shoulder-width apart, toes slightly outward.\\n2. Keep chest up and back straight throughout movement.\\n3. Lower hips back and down as if sitting in chair.\\n4. Go until thighs parallel to floor or as low as comfortable.\\n5. Drive through heels to return to starting position.", 
        "usesWeight": false, 
        "isTimed": false
      }
    ],
    "saturday": [], 
    "sunday": []
  }
}`);
}

function addComplianceReminderSection(promptSections: string[]) {
    promptSections.push("\nCRITICAL MUSCLE SPLIT COMPLIANCE:");
    promptSections.push("- Each workout day MUST strictly follow its assigned muscle group theme");
    promptSections.push("- Exercises should work synergistic muscles that complement each other");
    promptSections.push("- Include the specific split theme in each exercise description");
    promptSections.push("- Ensure no major muscle group is trained on consecutive days");
    promptSections.push("- Core/abs can be trained more frequently and included as secondary muscles");
    promptSections.push("- The routine name should reflect the split approach being used");

    promptSections.push("\nIMPORTANT: Your entire response MUST be only the JSON object. No other text, explanations, or formatting. Adhere strictly to the muscle split themes, JSON structure, and ALL CRITICAL CONSTRAINTS mentioned above. Double-check that workout days align with their assigned muscle groups and all other days are empty arrays.");
}
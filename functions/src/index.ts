// functions/src/index.ts

// v2 Imports for Firebase Functions
import { defineString } from "firebase-functions/params";
import { logger } from "firebase-functions/v2";
import { CallableRequest, HttpsError, onCall } from "firebase-functions/v2/https";

// Standard Imports
import {
  GenerateContentRequest,
  GoogleGenerativeAI,
  HarmBlockThreshold,
  HarmCategory,
} from "@google/generative-ai";
import * as admin from "firebase-admin";

admin.initializeApp();
const geminiApiKey = defineString("GEMINI_API_KEY");

let apiKeyForInitialization: string | undefined;
const isEmulator = process.env.FUNCTIONS_EMULATOR === "true";

if (isEmulator) {
  logger.log("Running in Firebase Emulator. Attempting to read GEMINI_API_KEY from process.env (functions/.env file).");
  apiKeyForInitialization = process.env.GEMINI_API_KEY;
  if (!apiKeyForInitialization) {
    logger.warn("EMULATOR WARNING: GEMINI_API_KEY not found in process.env for the emulator.");
  }
} else {
  logger.log("Running in a deployed environment. Gemini API Key will be accessed from the defined secret parameter.");
}

let genAI: GoogleGenerativeAI | null = null;
//const GEMINI_MODEL_NAME = "gemini-1.5-flash-latest";
//const GEMINI_MODEL_NAME = "gemini-2.0-flash-exp";
const GEMINI_MODEL_NAME = "gemini-2.5-flash";
let geminiModel: ReturnType<GoogleGenerativeAI["getGenerativeModel"]> | null = null;

function ensureGeminiClientInitialized(): ReturnType<GoogleGenerativeAI["getGenerativeModel"]> {
  if (geminiModel) {
    return geminiModel;
  }
  let effectiveApiKey: string | undefined;
  if (isEmulator) {
    effectiveApiKey = apiKeyForInitialization;
    if (!effectiveApiKey) {
      logger.error("EMULATOR CRITICAL: GEMINI_API_KEY not available for initialization.");
      throw new HttpsError("internal", "AI Service (emulator) API Key is missing.");
    }
  } else {
    effectiveApiKey = geminiApiKey.value();
    if (!effectiveApiKey) {
      logger.error("DEPLOYED CRITICAL: GEMINI_API_KEY secret is not available.");
      throw new HttpsError("internal", "AI Service API Key configuration error (secret missing).");
    }
  }
  genAI = new GoogleGenerativeAI(effectiveApiKey);
  geminiModel = genAI.getGenerativeModel({ model: GEMINI_MODEL_NAME });
  logger.info(`Gemini client initialized with model ${GEMINI_MODEL_NAME} (Emulator: ${isEmulator}).`);
  if (!geminiModel) {
    logger.error(`Failed to get Gemini model "${GEMINI_MODEL_NAME}" after explicit initialization attempt.`);
    throw new HttpsError("internal", "AI Service model could not be loaded.");
  }
  return geminiModel;
}

interface OnboardingData {
  goal?: string;
  gender?: string;
  experience?: string;
  frequency?: string;
  session_duration_minutes?: string;
  workout_days?: string[];
  equipment?: string[];
  focus_areas?: string[];
  physical_stats?: {
    age?: number;
    weight_kg?: number;
    height_m?: number;
    target_weight_kg?: number;
  };
}

interface PreviousRoutineData {
  id?: string;
  name?: string;
  durationInWeeks?: number;
  dailyWorkouts?: { [day: string]: Array<{ [key: string]: any }>; };
  generatedAt?: string | number | admin.firestore.Timestamp;
  expiresAt?: string | number | admin.firestore.Timestamp;
}

interface AiRoutineRequestPayload {
  onboardingData: OnboardingData;
  previousRoutineData?: PreviousRoutineData;
}

interface AiExercise {
  id?: string;
  name: string;
  sets: number;
  reps: string;
  weightSuggestionKg?: string | null;
  restBetweenSetsSeconds?: number | null;
  description: string;
  usesWeight?: boolean | null;
  isTimed?: boolean | null;
  targetDurationSeconds?: number | null;
}

interface AiGeneratedRoutineParts {
  name: string;
  durationInWeeks: number;
  dailyWorkouts: { [day: string]: AiExercise[]; };
}

interface MuscleSplit {
  name: string;
  muscles: string[];
  theme: string;
}

const DAYS_OF_WEEK = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"];

interface AggregatedPerformanceData {
  exerciseName: string;
  averageReps?: number;
  maxWeightLiftedKg?: number;
  completedRate?: number;
  targetReps?: string;
  targetWeight?: string;
}

// 🏋️‍♂️ FONCTION POUR DÉTERMINER LE SPLIT MUSCULAIRE
function determineMuscleSpirit(workoutDaysCount: number, experience: string): MuscleSplit[] {
  const MUSCLE_SPLITS = {
    "2_day": [
      {
        name: "Upper Body",
        muscles: ["Chest", "Back", "Shoulders", "Biceps", "Triceps", "Core"],
        theme: "Full Upper Body"
      },
      {
        name: "Lower Body",
        muscles: ["Quadriceps", "Hamstrings", "Glutes", "Calves", "Core"],
        theme: "Full Lower Body"
      }
    ],
    "3_day": [
      {
        name: "Push",
        muscles: ["Chest", "Shoulders", "Triceps", "Core"],
        theme: "Push Day - Chest, Shoulders, Triceps"
      },
      {
        name: "Pull",
        muscles: ["Back", "Lats", "Biceps", "Rear Delts"],
        theme: "Pull Day - Back, Biceps"
      },
      {
        name: "Legs",
        muscles: ["Quadriceps", "Hamstrings", "Glutes", "Calves", "Core"],
        theme: "Leg Day - Legs, Glutes"
      }
    ],
    "4_day": [
      {
        name: "Chest & Triceps",
        muscles: ["Chest", "Triceps", "Front Delts"],
        theme: "Chest & Triceps"
      },
      {
        name: "Back & Biceps",
        muscles: ["Back", "Lats", "Biceps", "Rear Delts"],
        theme: "Back & Biceps"
      },
      {
        name: "Legs",
        muscles: ["Quadriceps", "Hamstrings", "Glutes", "Calves"],
        theme: "Full Legs"
      },
      {
        name: "Shoulders & Core",
        muscles: ["Shoulders", "Core", "Traps"],
        theme: "Shoulders & Core"
      }
    ],
    "5_day": [
      {
        name: "Chest",
        muscles: ["Chest", "Front Delts"],
        theme: "Chest Focus"
      },
      {
        name: "Back",
        muscles: ["Back", "Lats", "Rear Delts"],
        theme: "Back Focus"
      },
      {
        name: "Legs",
        muscles: ["Quadriceps", "Hamstrings", "Glutes"],
        theme: "Legs Focus"
      },
      {
        name: "Arms",
        muscles: ["Biceps", "Triceps", "Forearms"],
        theme: "Arms Focus"
      },
      {
        name: "Shoulders & Core",
        muscles: ["Shoulders", "Core", "Traps", "Calves"],
        theme: "Shoulders & Core Finisher"
      }
    ]
  };

  if (workoutDaysCount <= 2) {
    return MUSCLE_SPLITS["2_day"];
  } else if (workoutDaysCount === 3) {
    return MUSCLE_SPLITS["3_day"];
  } else if (workoutDaysCount === 4) {
    return MUSCLE_SPLITS["4_day"];
  } else if (workoutDaysCount >= 5) {
    if (experience === "intermediate" || experience === "advanced" || experience === "expert") {
      return MUSCLE_SPLITS["5_day"];
    } else {
      return MUSCLE_SPLITS["4_day"];
    }
  }
  return MUSCLE_SPLITS["3_day"]; // Default
}

export const generateAiRoutine = onCall<AiRoutineRequestPayload, Promise<AiGeneratedRoutineParts>>(
  {
    secrets: [geminiApiKey],
    memory: "1GiB",
    timeoutSeconds: 150,
  },
  async (request: CallableRequest<AiRoutineRequestPayload>): Promise<AiGeneratedRoutineParts> => {
    const localGeminiModel = ensureGeminiClientInitialized();
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "The function must be called by an authenticated user.");
    }
    const userId = request.auth.uid;
    logger.info(`User ${userId} authenticated. Requesting AI routine.`);
    const payload = request.data;
    const onboarding = payload.onboardingData;
    const previousRoutine = payload.previousRoutineData;

    if (!onboarding || typeof onboarding !== "object" || Object.keys(onboarding).length === 0) {
      throw new HttpsError("invalid-argument", "Valid 'onboardingData' object is required.");
    }

    let aggregatedPerformanceSummary: AggregatedPerformanceData[] = [];
    if (previousRoutine?.id) {
      logger.info(`Previous routine ID found: ${previousRoutine.id}. Fetching workout logs for user ${userId}.`);
      try {
        let queryBase = admin.firestore()
          .collection("workout_logs")
          .where("userId", "==", userId)
          .where("routineId", "==", previousRoutine.id);

        if (previousRoutine.expiresAt) {
          let expiryDate: Date;
          if (previousRoutine.expiresAt instanceof admin.firestore.Timestamp) {
            expiryDate = previousRoutine.expiresAt.toDate();
          } else if (typeof previousRoutine.expiresAt === "string") {
            expiryDate = new Date(previousRoutine.expiresAt);
          } else if (typeof previousRoutine.expiresAt === "number") {
            expiryDate = new Date(previousRoutine.expiresAt);
          } else {
            logger.warn(`Unparseable previousRoutine.expiresAt format: ${typeof previousRoutine.expiresAt}. Proceeding without strict date filtering for logs.`);
            expiryDate = new Date();
          }

          if (!isNaN(expiryDate.getTime())) {
            const twoWeeksBeforeExpiry = new Date(expiryDate.getTime() - (14 * 24 * 60 * 60 * 1000));
            queryBase = queryBase.where("startTime", ">=", twoWeeksBeforeExpiry.toISOString());
            logger.info(`Log query will filter logs starting from or after: ${twoWeeksBeforeExpiry.toISOString()}`);
          }
        }

        const logsSnapshot = await queryBase.orderBy("startTime", "desc").limit(30).get();

        if (!logsSnapshot.empty) {
          logger.info(`Found ${logsSnapshot.docs.length} workout logs for the relevant period of routine ${previousRoutine.id}.`);
          const performanceByExercise: {
            [exerciseIdOrName: string]: {
              name: string,
              reps: number[],
              weights: number[],
              completionCount: number,
              sessionCount: number,
              targetReps?: string,
              targetWeight?: string,
            }
          } = {};

          for (const logDoc of logsSnapshot.docs) {
            const logData = logDoc.data();
            if (logData.exercises && Array.isArray(logData.exercises)) {
              for (const loggedExercise of logData.exercises) {
                const key = (loggedExercise.exerciseId as string || loggedExercise.exerciseName as string);
                if (!key) continue;
                if (!performanceByExercise[key]) {
                  performanceByExercise[key] = {
                    name: loggedExercise.exerciseName as string,
                    reps: [], weights: [], completionCount: 0, sessionCount: 0,
                    targetReps: loggedExercise.targetReps as string | undefined,
                    targetWeight: loggedExercise.targetWeight as string | undefined,
                  };
                }
                performanceByExercise[key].sessionCount++;
                if (loggedExercise.isCompleted === true) {
                  performanceByExercise[key].completionCount++;
                }
                if (loggedExercise.loggedSets && Array.isArray(loggedExercise.loggedSets)) {
                  for (const set of loggedExercise.loggedSets) {
                    const repsPerformed = parseInt(set.performedReps as string, 10);
                    if (!isNaN(repsPerformed)) performanceByExercise[key].reps.push(repsPerformed);
                    const weightString = set.performedWeightKg as string;
                    if (weightString && weightString.toLowerCase() !== "n/a" && weightString.toLowerCase() !== "bodyweight") {
                      const weightKg = parseFloat(weightString);
                      if (!isNaN(weightKg) && weightKg > 0) performanceByExercise[key].weights.push(weightKg);
                    }
                  }
                }
              }
            }
          }
          for (const key in performanceByExercise) {
            const data = performanceByExercise[key];
            let avgReps: number | undefined = data.reps.length > 0 ? data.reps.reduce((a, b) => a + b, 0) / data.reps.length : undefined;
            let maxWeight: number | undefined = data.weights.length > 0 ? Math.max(...data.weights) : undefined;
            const completionRate = data.sessionCount > 0 ? (data.completionCount / data.sessionCount) * 100 : undefined;
            aggregatedPerformanceSummary.push({
              exerciseName: data.name,
              averageReps: avgReps ? parseFloat(avgReps.toFixed(1)) : undefined,
              maxWeightLiftedKg: maxWeight,
              completedRate: completionRate ? parseFloat(completionRate.toFixed(0)) : undefined,
              targetReps: data.targetReps,
              targetWeight: data.targetWeight,
            });
          }
          logger.info("Aggregated performance summary:", aggregatedPerformanceSummary);
        } else {
          logger.info(`No workout logs found for the relevant period of routine ${previousRoutine.id}.`);
        }
      } catch (error) {
        logger.error("Error fetching or processing workout logs:", error);
      }
    }

    let actualWorkoutDaysCount = 0;
    let useSpecifiedDays = false;
    const preferredDaysSelected = onboarding.workout_days && onboarding.workout_days.length > 0;

    if (onboarding.frequency) {
      const freqParts = onboarding.frequency.split("-").map(Number);
      const minFreq = freqParts[0] || 1;
      const maxFreq = freqParts.length > 1 ? (freqParts[1] || minFreq) : minFreq;
      if (preferredDaysSelected && onboarding.workout_days) {
        const numSelectedDays = onboarding.workout_days.length;
        if (numSelectedDays >= minFreq && numSelectedDays <= maxFreq) {
          actualWorkoutDaysCount = numSelectedDays;
          useSpecifiedDays = true;
        } else {
          actualWorkoutDaysCount = Math.min(maxFreq, DAYS_OF_WEEK.length);
        }
      } else {
        actualWorkoutDaysCount = Math.min(maxFreq, DAYS_OF_WEEK.length);
      }
    } else {
      actualWorkoutDaysCount = (preferredDaysSelected && onboarding.workout_days) ? onboarding.workout_days.length : 3;
      actualWorkoutDaysCount = Math.min(actualWorkoutDaysCount, DAYS_OF_WEEK.length);
      if (preferredDaysSelected) useSpecifiedDays = true;
    }
    actualWorkoutDaysCount = Math.max(1, actualWorkoutDaysCount);

    // 🎯 DÉTERMINER LE SPLIT MUSCULAIRE
    const selectedSplit = determineMuscleSpirit(actualWorkoutDaysCount, onboarding.experience || "beginner");
    logger.info(`Selected muscle split for ${actualWorkoutDaysCount} days:`, selectedSplit);

    const promptSections: string[] = [
      "You are an expert fitness coach AI specialized in muscle split training. Your primary task is to generate a highly personalized weekly workout routine based on structured muscle group splits. Your entire output MUST be a single, valid JSON object conforming to the specified structure. Do not include any explanatory text, markdown formatting, or anything outside of this JSON object. Adherence to muscle split principles and specified workout days is PARAMOUNT.",
      "\n--- User Profile & Preferences (CRITICAL CONSTRAINTS) ---",
      `- Primary Fitness Goal: ${onboarding.goal || "Not specified"}`,
      `- Gender: ${onboarding.gender || "Not specified"}`,
      `- Experience Level: ${onboarding.experience || "Beginner"}`,
    ];

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

    // 🏋️‍♂️ MUSCLE SPLIT SYSTEM INSTRUCTIONS
    promptSections.push("\n--- MUSCLE SPLIT TRAINING SYSTEM (CRITICAL) ---");
    promptSections.push("You MUST follow a structured muscle split system. Each workout day focuses on specific muscle groups to ensure balanced development and optimal recovery.");

    if (useSpecifiedDays && onboarding.workout_days?.length) {
      promptSections.push(`- CRITICAL CONSTRAINT - Workout Days with Muscle Split Themes: User has SPECIFIED training on THESE EXACT ${actualWorkoutDaysCount} DAYS with assigned muscle groups:`);

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
      promptSections.push(`- MUSCLE SPLIT ASSIGNMENT: Create a ${actualWorkoutDaysCount}-day split with these themes:`);
      selectedSplit.forEach((split, index) => {
        if (index < actualWorkoutDaysCount) {
          promptSections.push(`  - Day ${index + 1}: ${split.theme}`);
          promptSections.push(`    Focus muscles: ${split.muscles.join(", ")}`);
        }
      });
      promptSections.push(`- For days not selected as workout days, they MUST BE REST DAYS (empty array in JSON).`);
    }

    // MUSCLE SPLIT RULES
    promptSections.push("\n--- MUSCLE SPLIT TRAINING RULES ---");
    promptSections.push("1. EXERCISE COHESION: All exercises in a single workout day MUST work synergistic muscle groups as specified in the day's theme.");
    promptSections.push("2. COMPOUND MOVEMENTS FIRST: Start each session with compound exercises (multi-joint movements), then isolation exercises.");
    promptSections.push("3. MUSCLE GROUP PAIRING: Follow classic pairing principles:");
    promptSections.push("   - Push Day: Chest + Shoulders + Triceps (pushing movements)");
    promptSections.push("   - Pull Day: Back + Biceps + Rear Delts (pulling movements)");
    promptSections.push("   - Leg Day: Quadriceps + Hamstrings + Glutes + Calves");
    promptSections.push("   - Upper/Lower: Combine push and pull for upper, all leg muscles for lower");
    promptSections.push("4. RECOVERY CONSIDERATION: Ensure muscle groups have adequate rest between sessions (48-72 hours).");

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

    if (onboarding.focus_areas?.length) {
      promptSections.push(`\n--- Specific Focus Areas ---`);
      promptSections.push(`- User wants extra focus on: ${onboarding.focus_areas.join(", ")}`);
      promptSections.push("- Incorporate additional exercises or volume for these areas within the appropriate split days.");
    }

    if (onboarding.physical_stats) {
      promptSections.push("\n--- Physical Statistics ---");
      if (onboarding.physical_stats.age != null) promptSections.push(`- Age: ${onboarding.physical_stats.age} years`);
      if (onboarding.physical_stats.weight_kg != null) promptSections.push(`- Current Weight: ${onboarding.physical_stats.weight_kg} kg`);
      if (onboarding.physical_stats.height_m != null) promptSections.push(`- Height: ${onboarding.physical_stats.height_m} meters`);
      if (onboarding.physical_stats.target_weight_kg != null) promptSections.push(`- Target Weight: ${onboarding.physical_stats.target_weight_kg} kg`);
    }

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

    // EXERCISE SELECTION EXAMPLES
    promptSections.push("\n--- EXERCISE SELECTION EXAMPLES BY MUSCLE SPLIT ---");
    promptSections.push("Push Day (Chest/Shoulders/Triceps): Push-ups, Chest Press, Shoulder Press, Tricep Dips, Lateral Raises, Tricep Extensions");
    promptSections.push("Pull Day (Back/Biceps): Pull-ups, Rows, Lat Pulldowns, Bicep Curls, Face Pulls, Reverse Flyes");
    promptSections.push("Leg Day (Quads/Hamstrings/Glutes): Squats, Deadlifts, Lunges, Leg Press, Calf Raises, Hip Thrusts");
    promptSections.push("Upper Body: Mix of push and pull movements for all upper body muscles");
    promptSections.push("Lower Body: All leg and glute exercises, both knee-dominant and hip-dominant movements");

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
      },
      {
        "name": "Pike Push-ups", 
        "sets": 3, 
        "reps": "6-10", 
        "weightSuggestionKg": "Bodyweight", 
        "restBetweenSetsSeconds": 75, 
        "description": "**Target: Shoulders, Triceps | Split: Push Day**\\n\\n1. Start in downward dog position, hands shoulder-width apart.\\n2. Walk feet closer to hands to increase shoulder angle.\\n3. Lower head toward ground by bending elbows.\\n4. Press back to starting position, focusing on shoulder strength.", 
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
      },
      {
        "name": "Inverted Rows", 
        "sets": 3, 
        "reps": "8-12", 
        "weightSuggestionKg": "Bodyweight", 
        "restBetweenSetsSeconds": 60, 
        "description": "**Target: Back, Biceps, Rear Delts | Split: Pull Day**\\n\\n1. Position under horizontal bar or table edge.\\n2. Grip bar with overhand grip, body straight.\\n3. Pull chest toward bar, squeezing shoulder blades together.\\n4. Lower with control, maintaining body alignment.", 
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
      },
      {
        "name": "Walking Lunges", 
        "sets": 3, 
        "reps": "10 each leg", 
        "weightSuggestionKg": "Bodyweight", 
        "restBetweenSetsSeconds": 60, 
        "description": "**Target: Quadriceps, Glutes, Hamstrings | Split: Leg Day**\\n\\n1. Stand tall with feet hip-width apart.\\n2. Step forward with right leg, lowering hips until both knees bent 90 degrees.\\n3. Front thigh parallel to floor, back knee nearly touching ground.\\n4. Push through front heel to step forward with back leg.\\n5. Alternate legs with each step forward.", 
        "usesWeight": false, 
        "isTimed": false
      }
    ],
    "saturday": [], 
    "sunday": []
  }
}`);

    promptSections.push("\nCRITICAL MUSCLE SPLIT COMPLIANCE:");
    promptSections.push("- Each workout day MUST strictly follow its assigned muscle group theme");
    promptSections.push("- Exercises should work synergistic muscles that complement each other");
    promptSections.push("- Include the specific split theme in each exercise description");
    promptSections.push("- Ensure no major muscle group is trained on consecutive days");
    promptSections.push("- Core/abs can be trained more frequently and included as secondary muscles");
    promptSections.push("- The routine name should reflect the split approach being used");

    promptSections.push("\nIMPORTANT: Your entire response MUST be only the JSON object. No other text, explanations, or formatting. Adhere strictly to the muscle split themes, JSON structure, and ALL CRITICAL CONSTRAINTS mentioned above. Double-check that workout days align with their assigned muscle groups and all other days are empty arrays.");

    const finalPromptFullRoutine = promptSections.join("\n");
    logger.info(`Final prompt for Gemini with Muscle Split (User: ${userId}, Model: ${GEMINI_MODEL_NAME}, Prompt Length: ${finalPromptFullRoutine.length})`);

    const apiRequestFullRoutine: GenerateContentRequest = {
      contents: [{ role: "user", parts: [{ text: finalPromptFullRoutine }] }],
      generationConfig: {
        temperature: 0.4,
        responseMimeType: "application/json",
      },
      safetySettings: [
        { category: HarmCategory.HARM_CATEGORY_HARASSMENT, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
        { category: HarmCategory.HARM_CATEGORY_HATE_SPEECH, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
        { category: HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
        { category: HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
      ],
    };

    let responseTextFullRoutine = "";
    try {
      const result = await localGeminiModel.generateContent(apiRequestFullRoutine);
      const response = result.response;
      if (response.promptFeedback?.blockReason) {
        logger.warn(`AI request blocked (generateAiRoutine). Reason: ${response.promptFeedback.blockReason}`, { userId, feedback: response.promptFeedback });
        throw new HttpsError("aborted", `AI content generation was blocked: ${response.promptFeedback.blockReason}.`);
      }
      if (!response.candidates?.length || !response.candidates[0].content?.parts?.length) {
        logger.error("AI returned no candidates or empty content parts (generateAiRoutine).", { userId, response });
        throw new HttpsError("internal", "AI service returned an unexpected or empty response.");
      }
      responseTextFullRoutine = response.text();
    } catch (error: any) {
      logger.error(`Error calling Gemini API (generateAiRoutine, User: ${userId}):`, { message: error.message, details: error.details });
      if (error instanceof HttpsError) throw error;
      throw new HttpsError("internal", "Failed to communicate with the AI service.", error.message);
    }

    let parsedRoutine: AiGeneratedRoutineParts;
    try {
      parsedRoutine = JSON.parse(responseTextFullRoutine.trim());
      if (
        typeof parsedRoutine.name !== "string" || !parsedRoutine.name.trim() ||
        typeof parsedRoutine.durationInWeeks !== "number" || parsedRoutine.durationInWeeks <= 0 ||
        typeof parsedRoutine.dailyWorkouts !== "object" || parsedRoutine.dailyWorkouts === null
      ) {
        logger.error("Parsed routine has invalid top-level structure:", { userId, parsedRoutine });
        throw new Error("AI generated invalid structure (name, duration, or dailyWorkouts).");
      }

      const normalizedDailyWorkouts: { [day: string]: AiExercise[] } = {};
      for (const day of DAYS_OF_WEEK) {
        const lowerCaseDay = day.toLowerCase();
        if (Object.prototype.hasOwnProperty.call(parsedRoutine.dailyWorkouts, lowerCaseDay)) {
          if (Array.isArray(parsedRoutine.dailyWorkouts[lowerCaseDay])) {
            normalizedDailyWorkouts[lowerCaseDay] = parsedRoutine.dailyWorkouts[lowerCaseDay];
          } else {
            logger.warn(`Exercises for day '${lowerCaseDay}' is not an array in AI response, defaulting to empty.`, { userId, dayData: parsedRoutine.dailyWorkouts[lowerCaseDay] });
            normalizedDailyWorkouts[lowerCaseDay] = [];
          }
        } else if (Object.prototype.hasOwnProperty.call(parsedRoutine.dailyWorkouts, day)) {
          if (Array.isArray(parsedRoutine.dailyWorkouts[day])) {
            normalizedDailyWorkouts[lowerCaseDay] = parsedRoutine.dailyWorkouts[day];
          } else {
            logger.warn(`Exercises for day '${day}' (original case) is not an array, defaulting to empty for '${lowerCaseDay}'.`, { userId, dayData: parsedRoutine.dailyWorkouts[day] });
            normalizedDailyWorkouts[lowerCaseDay] = [];
          }
        }
        else {
          normalizedDailyWorkouts[lowerCaseDay] = [];
        }
      }
      parsedRoutine.dailyWorkouts = normalizedDailyWorkouts;

      for (const day of DAYS_OF_WEEK) {
        if (!Array.isArray(parsedRoutine.dailyWorkouts[day])) {
          logger.error(`Normalized exercises for day '${day}' is still not an array. This is unexpected.`, { userId, dayData: parsedRoutine.dailyWorkouts[day] });
          parsedRoutine.dailyWorkouts[day] = [];
        }

        for (const exercise of parsedRoutine.dailyWorkouts[day]) {
          if (typeof exercise.name !== "string" || !exercise.name.trim() ||
            typeof exercise.sets !== "number" || exercise.sets <= 0 ||
            typeof exercise.reps !== "string" || !exercise.reps.trim() ||
            typeof exercise.description !== "string") {
            logger.error(`Invalid exercise structure for '${exercise.name || "Unnamed Exercise"}' on day '${day}' (generateAiRoutine):`, { userId, exerciseDetails: exercise });
            if (typeof exercise.description !== "string" || !exercise.description.trim()) {
              exercise.description = "**Target: Multiple muscle groups | Split: Training Day**\n\nInstructions for this exercise are currently unavailable.";
            }
          } else {
            exercise.description = exercise.description.trim();
            if (!exercise.description) {
              exercise.description = "**Target: Multiple muscle groups | Split: Training Day**\n\nHow to perform: Detailed instructions will be available soon.";
            }
            // Validation du format de description avec muscle split
            if (!exercise.description.includes("**Target:") || !exercise.description.includes("Split:")) {
              logger.warn(`Exercise '${exercise.name}' on day '${day}' missing proper muscle split format in description.`);
              if (!exercise.description.includes("**Target:")) {
                exercise.description = "**Target: Multiple muscle groups | Split: Training Day**\n\n" + exercise.description;
              }
            }
          }
          exercise.weightSuggestionKg = (typeof exercise.weightSuggestionKg === "string" && exercise.weightSuggestionKg.trim()) ? exercise.weightSuggestionKg.trim() : "N/A";
          exercise.restBetweenSetsSeconds = (typeof exercise.restBetweenSetsSeconds === "number" && exercise.restBetweenSetsSeconds >= 0) ? exercise.restBetweenSetsSeconds : 60;
          exercise.usesWeight = typeof exercise.usesWeight === "boolean" ? exercise.usesWeight : true;
          exercise.isTimed = typeof exercise.isTimed === "boolean" ? exercise.isTimed : false;
          if (!exercise.isTimed) {
            exercise.targetDurationSeconds = undefined;
          } else {
            exercise.targetDurationSeconds = typeof exercise.targetDurationSeconds === "number" && exercise.targetDurationSeconds > 0 ? exercise.targetDurationSeconds : undefined;
          }
        }
      }
    } catch (parseError: any) {
      logger.error(`Failed to parse Gemini JSON (generateAiRoutine, User: ${userId}):`, { errorMessage: parseError.message, originalResponseText: responseTextFullRoutine.substring(0, 500) });
      throw new HttpsError("internal", "The AI's response was not in the expected JSON format.");
    }

    logger.info(`Successfully generated and validated AI muscle split routine for User: ${userId}. Routine Name: "${parsedRoutine.name}"`);
    return parsedRoutine;
  }
);
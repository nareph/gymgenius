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
const GEMINI_MODEL_NAME = "gemini-1.5-flash-latest";
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
  generatedAt?: string | number | admin.firestore.Timestamp; // Updated to include Timestamp
  expiresAt?: string | number | admin.firestore.Timestamp;   // Updated to include Timestamp
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

const DAYS_OF_WEEK = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"];

interface AggregatedPerformanceData {
  exerciseName: string;
  averageReps?: number;
  maxWeightLiftedKg?: number;
  completedRate?: number;
  targetReps?: string;
  targetWeight?: string;
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

        // Tentative de filtrage par date pour les 2 dernières semaines de la routine précédente
        if (previousRoutine.expiresAt) {
          let expiryDate: Date;
          if (previousRoutine.expiresAt instanceof admin.firestore.Timestamp) {
            expiryDate = previousRoutine.expiresAt.toDate();
          } else if (typeof previousRoutine.expiresAt === "string") {
            expiryDate = new Date(previousRoutine.expiresAt);
          } else if (typeof previousRoutine.expiresAt === "number") {
            expiryDate = new Date(previousRoutine.expiresAt);
          } else {
            // Fallback si expiresAt n'est pas un format attendu, on ne filtre pas par date pour cette routine
            logger.warn(`Unparseable previousRoutine.expiresAt format: ${typeof previousRoutine.expiresAt}. Proceeding without strict date filtering for logs.`);
            expiryDate = new Date(); // Ne sera pas utilisé si le type n'est pas bon
          }

          // Vérifier si expiryDate est une date valide avant de l'utiliser
          if (!isNaN(expiryDate.getTime())) {
            const twoWeeksBeforeExpiry = new Date(expiryDate.getTime() - (14 * 24 * 60 * 60 * 1000));
            // Les champs startTime/endTime dans les logs sont des strings ISO.
            // Firestore peut comparer des strings ISO pour les dates.
            queryBase = queryBase.where("startTime", ">=", twoWeeksBeforeExpiry.toISOString());
            logger.info(`Log query will filter logs starting from or after: ${twoWeeksBeforeExpiry.toISOString()}`);
          }
        }

        const logsSnapshot = await queryBase.orderBy("startTime", "desc").limit(30).get(); // Limite généreuse

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

    const promptSections: string[] = [
      "You are an expert fitness coach AI. Your primary task is to generate a highly personalized weekly workout routine based on the user's profile and preferences. Your entire output MUST be a single, valid JSON object conforming to the specified structure. Do not include any explanatory text, markdown formatting, or anything outside of this JSON object. Adherence to the specified number of workout days and session duration is PARAMOUNT.",
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
      promptSections.push("  - This exercise count is a strict requirement for each scheduled workout day. You must also consider exercise execution time and rest_between_sets_seconds to ensure the total workout fits the user's available time. Prioritize effective exercises.");
    } else {
      promptSections.push("- Available time per session: Not specified. Assume a standard duration of about 45-60 minutes per workout. You MUST select 4-6 exercises per workout day.");
    }

    if (useSpecifiedDays && onboarding.workout_days?.length) {
      promptSections.push(`- CRITICAL CONSTRAINT - Workout Days: User has SPECIFIED training on THESE EXACT ${actualWorkoutDaysCount} DAYS: ${onboarding.workout_days.map(day => day.toLowerCase()).join(", ")}. You MUST schedule workouts (with the exercise count specified above) for ALL these days. ALL OTHER DAYS OF THE WEEK MUST BE REST DAYS (empty array in JSON). NO EXCEPTIONS.`);
    } else {
      promptSections.push(`- Training Days Per Week: ${actualWorkoutDaysCount} days.`);
      if (preferredDaysSelected && onboarding.workout_days?.length) {
        promptSections.push(`- Preferred Workout Days (select ${actualWorkoutDaysCount} from this list if possible, otherwise choose suitable days, respecting the total count): ${onboarding.workout_days.map(day => day.toLowerCase()).join(", ")}`);
      }
      promptSections.push(`  - For days not selected as workout days, they MUST BE REST DAYS (empty array in JSON).`);
    }

    if (onboarding.equipment && onboarding.equipment.length > 0) {
      const equipmentList = onboarding.equipment.join(", ");
      promptSections.push(`- Available Equipment: ${equipmentList}.`);
      promptSections.push("  - CRITICAL: You MUST select exercises that strictly use ONLY the equipment listed. If 'bodyweight' is listed, it can always be used. Do not assume access to unlisted items.");
      promptSections.push("  - If 'homemade_weights' is listed, you can suggest exercises where improvised weights (like sandbags, water bottles) can be used, and mention this possibility in the exercise description.");
      promptSections.push("  - If 'gym_machines_selectorized' is listed, assume access to common selectorized machines (e.g., leg press, chest press, lat pulldown, shoulder press machine, leg curl, leg extension). Specify which type of machine if relevant (e.g., 'Lat Pulldown Machine').");
    } else {
      promptSections.push("- Available Equipment: Bodyweight Only. ALL exercises MUST be strictly bodyweight.");
    }

    if (onboarding.focus_areas?.length) promptSections.push(`- Specific Body Part Focus: ${onboarding.focus_areas.join(", ")}`);

    if (onboarding.physical_stats) {
      promptSections.push("- Physical Statistics:");
      if (onboarding.physical_stats.age != null) promptSections.push(`  - Age: ${onboarding.physical_stats.age} years`);
      if (onboarding.physical_stats.weight_kg != null) promptSections.push(`  - Current Weight: ${onboarding.physical_stats.weight_kg} kg`);
      if (onboarding.physical_stats.height_m != null) promptSections.push(`  - Height: ${onboarding.physical_stats.height_m} meters`);
      if (onboarding.physical_stats.target_weight_kg != null) promptSections.push(`  - Target Weight: ${onboarding.physical_stats.target_weight_kg} kg`);
    }

    if (aggregatedPerformanceSummary.length > 0) {
      promptSections.push("\n--- User Performance on Previous Routine (Use this for progression) ---");
      promptSections.push("Consider the following summary of the user's performance on key exercises from their previous routine (last ~2 weeks) to tailor the new plan. Adapt weights, reps, or exercise variations based on this feedback:");
      for (const perf of aggregatedPerformanceSummary) {
        let perfString = `- Exercise: "${perf.exerciseName}" (Target: ${perf.targetReps || "N/A"} @ ${perf.targetWeight || "N/A"})`;
        if (perf.averageReps !== undefined) perfString += `, Actual Avg Reps/Set: ${perf.averageReps}`;
        if (perf.maxWeightLiftedKg !== undefined) perfString += `, Actual Max Weight: ${perf.maxWeightLiftedKg}kg`;
        if (perf.completedRate !== undefined) perfString += `, Completion Rate for this exercise in past sessions: ${perf.completedRate}%`;
        promptSections.push(perfString);
      }
      promptSections.push("Based on this performance data:");
      promptSections.push("  - If user consistently met or exceeded rep targets with good form (indicated by high completion rate), consider increasing the suggested weight or target reps for similar exercises.");
      promptSections.push("  - If user struggled with an exercise (low avg reps, low completion rate), consider reducing weight/reps, suggesting an easier variation, or replacing it if it seems too difficult for their current level with available equipment.");
      promptSections.push("  - If max weight lifted is significantly higher than target, suggest a higher starting weight for the new routine.");
      promptSections.push("  - Aim for progressive overload. The new routine should be challenging but achievable.");
    } else if (previousRoutine?.id) {
      promptSections.push("\n--- Previous Routine Context (General) ---");
      promptSections.push(`- Previous Plan Name: ${previousRoutine.name || "Unnamed"}`);
      if (previousRoutine.durationInWeeks != null) promptSections.push(`- Previous Plan Duration: ${previousRoutine.durationInWeeks} weeks`);
      promptSections.push("User had a previous routine, but no detailed performance logs were found or processed for the recent period. Base progression on general principles and the nature of the previous plan if provided. Aim for a slight increase in challenge if user experience is not 'beginner'.");
    }


    promptSections.push("\n--- Output Structure & Instructions (REVIEW CRITICAL CONSTRAINTS ABOVE) ---");
    promptSections.push("1. Generate 'name' (string) for the routine (e.g., 'Strength Builder Phase 1', 'Fat Loss & Tone').");
    promptSections.push("2. Generate 'durationInWeeks' (number, typically 4, 6, or 8 weeks).");
    promptSections.push("3. Provide a 'dailyWorkouts' object containing keys for ALL 7 days of the week (\"monday\" through \"sunday\"). Keys MUST be lowercase.");
    promptSections.push("   - Workout days: MUST align with the 'CRITICAL CONSTRAINT - Workout Days' specified above. Each of these days MUST have an array of exercise objects, and the number of exercises MUST match the 'EXERCISE COUNT PER WORKOUT DAY' derived from 'session_duration_minutes'.");
    promptSections.push("   - Rest days: ALL OTHER DAYS (not specified as workout days) MUST have an empty array [] as their value in the 'dailyWorkouts' object.");
    promptSections.push("4. Each exercise object MUST have:");
    promptSections.push("   - \"name\": string (clear and concise exercise name)");
    promptSections.push("   - \"sets\": number (positive integer, e.g., 3, 4)");
    promptSections.push("   - \"reps\": string (e.g., \"8-12\", \"AMRAP\", \"To Failure\", \"30s\", \"5km\", \"15\")");
    promptSections.push("   - \"description\": string (CRITICAL: Provide clear, step-by-step instructions on HOW TO PERFORM the exercise correctly. Use a numbered list format (e.g., '1. Step one.\\n2. Step two.\\n3. Step three.') or bullet points prefixed with '*' or '-' (e.g., '- Point one.\\n- Point two.'). Each step should be concise and start on a new line (use '\\n' for new lines within the JSON string). Focus on key form points, common mistakes to avoid, and muscle engagement. This will be shown to the user as their guide.)");
    promptSections.push("5. Include these exercise properties where applicable (use sensible defaults if not explicitly derived from user data):");
    promptSections.push("   - \"weightSuggestionKg\": string (e.g., \"60\" for 60kg, \"Bodyweight\", \"Light\", \"Moderate\", \"Heavy\", \"N/A\" if not applicable)");
    promptSections.push("   - \"restBetweenSetsSeconds\": number (e.g., 45, 60, 90, 120)");
    promptSections.push("6. Include these boolean/numeric exercise properties:");
    promptSections.push("   - \"usesWeight\": boolean (true if external weight is typically used or can be added; false for pure bodyweight, most cardio, or timed holds like planks).");
    promptSections.push("   - \"isTimed\": boolean (true if the primary goal of the set is a duration, e.g., plank for 60s, sprints for 30s, cardio interval. False if rep-based).");
    promptSections.push("   - \"targetDurationSeconds\": number (ONLY include if isTimed is true AND there's a specific target duration in seconds, e.g., 60 for a 60-second plank. Omit this field otherwise or if 'reps' field already specifies duration like \"30s\").");

    promptSections.push("\n--- JSON Structure Example (Your output MUST follow this format PRECISELY) ---");
    promptSections.push(`
{
  "name": "Functional Fitness Foundation",
  "durationInWeeks": 4,
  "dailyWorkouts": {
    "monday": [
      {"name": "Goblet Squats", "sets": 3, "reps": "10-12", "weightSuggestionKg": "Moderate", "restBetweenSetsSeconds": 75, "description": "1. Hold dumbbell vertically against chest, elbows tucked in.\\n2. Stand with feet shoulder-width apart, toes pointing slightly outwards.\\n3. Keeping your chest up and back straight, lower your hips back and down as if sitting in a chair.\\n4. Go as low as you can comfortably, ideally until thighs are parallel to the floor or deeper if form allows.\\n5. Push through your heels to return to the starting position, squeezing glutes at the top.", "usesWeight": true, "isTimed": false},
      {"name": "Push-ups", "sets": 3, "reps": "AMRAP", "weightSuggestionKg": "Bodyweight", "restBetweenSetsSeconds": 60, "description": "- Start in a high plank position with hands slightly wider than shoulder-width, directly under shoulders.\\n- Body should form a straight line from head to heels; engage core and glutes.\\n- Lower your body by bending elbows, keeping them relatively close to your body (about 45 degrees).\\n- Lower until your chest nearly touches the floor.\\n- Push back up powerfully to the starting position.", "usesWeight": false, "isTimed": false}
    ],
    "tuesday": [],
    "wednesday": [
      {"name": "Plank", "sets": 3, "reps": "Hold", "weightSuggestionKg": "N/A", "restBetweenSetsSeconds": 45, "description": "1. Lie face down and prop yourself up on your forearms, with elbows directly under your shoulders.\\n2. Lift your hips off the floor so your body forms a straight line from head to heels.\\n3. Engage your core and glutes tightly. Avoid letting your hips sag or rise too high.\\n4. Hold this position for the target duration, breathing steadily.", "usesWeight": false, "isTimed": true, "targetDurationSeconds": 45}
    ],
    "thursday": [], "friday": [], "saturday": [], "sunday": []
  }
}`);
    promptSections.push("\nIMPORTANT: Your entire response MUST be only the JSON object. No other text, apologies, or explanations. Adhere strictly to the JSON structure, field requirements, and ALL CRITICAL CONSTRAINTS mentioned above (especially workout days and exercise counts per session duration). Double-check that all specified workout days have exercises and all other days are empty arrays.");

    const finalPromptFullRoutine = promptSections.join("\n");
    logger.info(`Final prompt for Gemini (Full Routine, User: ${userId}, Model: ${GEMINI_MODEL_NAME}, Prompt Length: ${finalPromptFullRoutine.length})`);

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
              exercise.description = "Instructions for this exercise are currently unavailable.";
            }
          } else {
            exercise.description = exercise.description.trim();
            if (!exercise.description) {
              exercise.description = "How to perform: Detailed instructions will be available soon.";
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
    logger.info(`Successfully generated and validated AI routine for User: ${userId}. Routine Name: "${parsedRoutine.name}"`);
    return parsedRoutine;
  }
);
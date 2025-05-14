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

// --- Firebase Admin SDK Initialization ---
admin.initializeApp();

// --- Define Secret Parameter (v2 style) ---
const geminiApiKey = defineString("GEMINI_API_KEY");

// --- Gemini API Client Initialization (Global, conditional for emulator) ---
let apiKeyForInitialization: string | undefined;
const isEmulator = process.env.FUNCTIONS_EMULATOR === "true";

if (isEmulator) {
  logger.log("Running in Firebase Emulator. Attempting to read GEMINI_API_KEY from process.env (functions/.env file).");
  apiKeyForInitialization = process.env.GEMINI_API_KEY;
  if (!apiKeyForInitialization) {
    logger.warn("----------------------------------------------------------------------");
    logger.warn("EMULATOR WARNING: GEMINI_API_KEY not found in process.env for the emulator.");
    logger.warn("                  Please ensure it's set in your 'functions/.env' file.");
    logger.warn("                  AI routine generation will FAIL in the emulator without it.");
    logger.warn("----------------------------------------------------------------------");
  }
} else {
  logger.log("Running in a deployed environment. Gemini API Key will be accessed from the defined secret parameter.");
}

let genAI: GoogleGenerativeAI | null = isEmulator && apiKeyForInitialization
  ? new GoogleGenerativeAI(apiKeyForInitialization)
  : null;

const GEMINI_MODEL_NAME = "gemini-1.5-flash-latest";

let geminiModel: ReturnType<GoogleGenerativeAI["getGenerativeModel"]> | null = genAI
  ? genAI.getGenerativeModel({ model: GEMINI_MODEL_NAME })
  : null;

if (isEmulator && apiKeyForInitialization && !geminiModel) {
  logger.error(`EMULATOR: Failed to get Gemini model "${GEMINI_MODEL_NAME}" during global initialization.`);
}


// --- Interface Definitions ---
interface OnboardingData {
  goal?: string;
  gender?: string;
  experience?: string;
  frequency?: string;
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
  dailyWorkouts?: {
    [day: string]: Array<{ [key: string]: any }>;
  };
  generatedAt?: string | number;
  expiresAt?: string | number;
}

interface AiRoutineRequestPayload {
  onboardingData: OnboardingData;
  previousRoutineData?: PreviousRoutineData;
}

interface AiExercise {
  name: string;
  sets: number;
  reps: string;
  weightSuggestionKg?: string | null;
  restBetweenSetsSeconds?: number | null;
  description: string; // Description is now expected to be a string
  usesWeight?: boolean | null;
  isTimed?: boolean | null;
  targetDurationSeconds?: number | null;
}

interface AiGeneratedRoutineParts {
  name: string;
  durationInWeeks: number;
  dailyWorkouts: {
    [day: string]: AiExercise[];
  };
}

const DAYS_OF_WEEK = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"];


// --- Cloud Function (v2 Syntax) ---
export const generateAiRoutine = onCall<AiRoutineRequestPayload, Promise<AiGeneratedRoutineParts>>(
  {
    secrets: [geminiApiKey],
    memory: "512MiB",
    timeoutSeconds: 120,
  },
  async (request: CallableRequest<AiRoutineRequestPayload>): Promise<AiGeneratedRoutineParts> => {

    if (!isEmulator) {
      const apiKeyFromSecret = geminiApiKey.value();
      if (!apiKeyFromSecret) {
        logger.error("Gemini API Key from Secret Manager (defineString) is not available in deployed function.");
        throw new HttpsError("internal", "AI Service API Key configuration error (secret missing).");
      }
      if (!genAI || !geminiModel) {
        genAI = new GoogleGenerativeAI(apiKeyFromSecret);
        geminiModel = genAI.getGenerativeModel({ model: GEMINI_MODEL_NAME });
        logger.info(`Gemini client initialized/re-initialized within deployed function call with model ${GEMINI_MODEL_NAME}.`);
      }
    } else {
      if (!geminiModel) {
        logger.error("EMULATOR: Gemini model not initialized. Ensure GEMINI_API_KEY is in functions/.env and model name is correct.");
        throw new HttpsError("internal", "AI Service (emulator) is not configured correctly. Model could not be loaded.");
      }
    }

    if (!geminiModel) {
      logger.error("Critical: Gemini model instance is null before API call. This indicates a setup issue.");
      throw new HttpsError("internal", "AI Service is currently unavailable due to a configuration problem.");
    }

    if (!request.auth) {
      throw new HttpsError("unauthenticated", "The function must be called by an authenticated user.");
    }
    const userId = request.auth.uid;
    logger.info(`User ${userId} authenticated. Requesting AI routine (v2) using Gemini model: ${GEMINI_MODEL_NAME}.`);

    const payload = request.data;
    logger.debug("Received payload (v2):", { userId, payload });

    if (!payload.onboardingData || typeof payload.onboardingData !== "object" || Object.keys(payload.onboardingData).length === 0) {
      throw new HttpsError("invalid-argument", "Valid 'onboardingData' object is required to generate a routine.");
    }
    const onboarding = payload.onboardingData;
    const previousRoutine = payload.previousRoutineData;

    let actualWorkoutDaysCount = 0;
    let useSpecifiedDays = false;
    const preferredDaysSelected = onboarding.workout_days && onboarding.workout_days.length > 0;

    if (onboarding.frequency) {
      const freqRange = onboarding.frequency.split("-").map(Number);
      const minFreq = freqRange[0];
      const maxFreq = freqRange.length > 1 ? freqRange[1] : minFreq;

      if (preferredDaysSelected) {
        const numSelectedDays = onboarding.workout_days!.length;
        if (numSelectedDays >= minFreq && numSelectedDays <= maxFreq) {
          actualWorkoutDaysCount = numSelectedDays;
          useSpecifiedDays = true;
          logger.info(`User selected ${numSelectedDays} specific days, which fits frequency ${onboarding.frequency}. Will instruct AI for exactly ${numSelectedDays} workout days on: ${onboarding.workout_days!.join(", ")}.`);
        } else {
          actualWorkoutDaysCount = maxFreq;
          logger.info(`User selected ${numSelectedDays} specific days, but frequency is ${onboarding.frequency}. Instructing AI for ${actualWorkoutDaysCount} days, considering preferences: ${onboarding.workout_days!.join(", ")}.`);
        }
      } else {
        actualWorkoutDaysCount = maxFreq;
        logger.info(`No specific days selected. Using max of frequency ${onboarding.frequency}: ${actualWorkoutDaysCount} days.`);
      }
    } else {
      actualWorkoutDaysCount = preferredDaysSelected ? onboarding.workout_days!.length : 3;
      if (preferredDaysSelected) useSpecifiedDays = true;
      logger.warn(`Frequency not specified. Defaulting to ${actualWorkoutDaysCount} workout days.`);
    }

    const promptSections: string[] = [];
    promptSections.push("You are an expert fitness coach AI. Your primary task is to generate a highly personalized weekly workout routine based on the user's profile and preferences. Your entire output MUST be a single, valid JSON object conforming to the specified structure. Do not include any explanatory text, markdown formatting, or anything outside of this JSON object.");

    promptSections.push("\n--- User Profile & Preferences ---");
    promptSections.push(`- Primary Fitness Goal: ${onboarding.goal || "Not specified"}`);
    promptSections.push(`- Gender: ${onboarding.gender || "Not specified"}`);
    promptSections.push(`- Experience Level: ${onboarding.experience || "Beginner"}`);

    if (useSpecifiedDays && onboarding.workout_days?.length) {
      promptSections.push(`- CRITICAL: User wants to train on THESE EXACT ${actualWorkoutDaysCount} DAYS: ${onboarding.workout_days.join(", ")}. You MUST schedule workouts for all these specified days. Other days must be rest days.`);
    } else {
      promptSections.push(`- Desired Training Days Per Week: ${actualWorkoutDaysCount} days.`);
      if (preferredDaysSelected) {
        promptSections.push(`- Preferred Workout Days (select ${actualWorkoutDaysCount} from this list if possible, otherwise choose suitable days): ${onboarding.workout_days!.join(", ")}`);
      }
    }

    if (onboarding.equipment?.length) promptSections.push(`- Available Equipment: ${onboarding.equipment.join(", ")}`);
    else promptSections.push("- Available Equipment: Bodyweight only");
    if (onboarding.focus_areas?.length) promptSections.push(`- Specific Body Part Focus: ${onboarding.focus_areas.join(", ")}`);

    if (onboarding.physical_stats) {
      promptSections.push("- Physical Statistics:");
      if (onboarding.physical_stats.age != null) promptSections.push(`  - Age: ${onboarding.physical_stats.age} years`);
      if (onboarding.physical_stats.weight_kg != null) promptSections.push(`  - Current Weight: ${onboarding.physical_stats.weight_kg} kg`);
      if (onboarding.physical_stats.height_m != null) promptSections.push(`  - Height: ${onboarding.physical_stats.height_m} meters`);
      if (onboarding.physical_stats.target_weight_kg != null) promptSections.push(`  - Target Weight: ${onboarding.physical_stats.target_weight_kg} kg`);
    }

    if (previousRoutine?.name) {
      promptSections.push("\n--- Previous Routine Context ---");
      promptSections.push(`- Previous Plan Name: ${previousRoutine.name}`);
      if (previousRoutine.durationInWeeks != null) promptSections.push(`- Previous Plan Duration: ${previousRoutine.durationInWeeks} weeks`);
      promptSections.push("Ensure the new routine offers appropriate progression or variation.");
    }

    promptSections.push("\n--- Output Structure & Instructions ---");
    promptSections.push("1. Generate 'name' (string) for the routine.");
    promptSections.push("2. Generate 'durationInWeeks' (number, typically 4-8 weeks).");
    promptSections.push("3. Provide a 'dailyWorkouts' object containing keys for ALL 7 days of the week (\"monday\" through \"sunday\").");
    promptSections.push("   - Workout days (as specified by the CRITICAL instruction or desired count) MUST have an array of exercise objects.");
    promptSections.push("   - ALL other days (rest days) MUST have an empty array [].");
    promptSections.push("4. Each exercise object MUST have:");
    promptSections.push("   - \"name\": string (clear and concise exercise name)");
    promptSections.push("   - \"sets\": number (positive integer)");
    promptSections.push("   - \"reps\": string (e.g., \"8-12\", \"AMRAP\", \"To Failure\", \"30s\", \"5km\")");
    // <<--- INSTRUCTION MISE À JOUR POUR LA DESCRIPTION --- >>
    promptSections.push("   - \"description\": string (CRITICAL: Provide clear, step-by-step instructions on HOW TO PERFORM the exercise correctly. Use a numbered list format (e.g., '1. Step one.\\n2. Step two.\\n3. Step three.') or bullet points prefixed with '*' or '-' (e.g., '- Point one.\\n- Point two.'). Each step should be concise and start on a new line (use '\\n' for new lines within the JSON string). Focus on key form points, common mistakes to avoid, and muscle engagement. This will be shown to the user as their guide.)");
    promptSections.push("5. Include these exercise properties where applicable (use sensible defaults if not explicitly derived from user data):");
    promptSections.push("   - \"weightSuggestionKg\": string (e.g., \"60\", \"Bodyweight\", \"Light\", \"Moderate\", \"Heavy\", \"N/A\")");
    promptSections.push("   - \"restBetweenSetsSeconds\": number (e.g., 45, 60, 90, 120)");
    promptSections.push("6. Include these boolean/numeric exercise properties:");
    promptSections.push("   - \"usesWeight\": boolean (true if external weight is typically used or can be added; false for pure bodyweight, most cardio, or timed holds like planks).");
    promptSections.push("   - \"isTimed\": boolean (true if the primary goal of the set is a duration, e.g., plank, sprints, cardio interval. False if rep-based).");
    promptSections.push("   - \"targetDurationSeconds\": number (ONLY include if isTimed is true AND there's a specific target duration in seconds, e.g., 60 for a 60-second plank. Omit this field otherwise or if 'reps' field already specifies duration like \"30s\").");

    promptSections.push("\n--- JSON Structure Example (Your output MUST follow this format PRECISELY) ---");
    // <<--- EXEMPLE MIS À JOUR POUR LA DESCRIPTION --- >>
    promptSections.push(`
{
  "name": "Functional Fitness Foundation",
  "durationInWeeks": 4,
  "dailyWorkouts": {
    "monday": [
      {"name": "Goblet Squats", "sets": 3, "reps": "10-12", "weightSuggestionKg": "Moderate", "restBetweenSetsSeconds": 75, "description": "1. Hold dumbbell vertically against chest.\\n2. Feet shoulder-width, toes slightly out.\\n3. Lower hips back & down, chest up, back straight.\\n4. Thighs parallel to floor or deeper if form allows.\\n5. Push through heels to stand.", "usesWeight": true, "isTimed": false},
      {"name": "Push-ups", "sets": 3, "reps": "AMRAP", "weightSuggestionKg": "Bodyweight", "restBetweenSetsSeconds": 60, "description": "- Hands shoulder-width.\\n- Body in a straight line from head to heels.\\n- Lower chest towards floor, elbows at 45 deg.\\n- Push back up powerfully.", "usesWeight": false, "isTimed": false},
      {"name": "Dumbbell Rows", "sets": 3, "reps": "10-12 per arm", "weightSuggestionKg": "Moderate", "restBetweenSetsSeconds": 60, "description": "1. Hinge at hips, back straight, one hand on bench for support.\\n2. Pull dumbbell towards hip, squeezing back muscles.\\n3. Lower slowly. Complete reps on one side before switching.", "usesWeight": true, "isTimed": false}
    ],
    "tuesday": [],
    "wednesday": [
      {"name": "Overhead Press (Dumbbell)", "sets": 3, "reps": "8-10", "weightSuggestionKg": "Light-Moderate", "restBetweenSetsSeconds": 75, "description": "1. Sit or stand, core engaged.\\n2. Dumbbells at shoulder height, palms forward.\\n3. Press overhead until arms are extended.\\n4. Lower with control.", "usesWeight": true, "isTimed": false},
      {"name": "Plank", "sets": 3, "reps": "Hold", "weightSuggestionKg": "N/A", "restBetweenSetsSeconds": 45, "description": "1. Forearms on ground, elbows under shoulders.\\n2. Body in a straight line from head to heels.\\n3. Engage core and glutes. Hold for target time.", "usesWeight": false, "isTimed": true, "targetDurationSeconds": 45}
    ],
    "thursday": [],
    "friday": [
      {"name": "Kettlebell Swings", "sets": 4, "reps": "15-20", "weightSuggestionKg": "Moderate", "restBetweenSetsSeconds": 90, "description": "1. Feet shoulder-width.\\n2. Hinge at hips, slight knee bend, swing KB back through legs.\\n3. Thrust hips forward powerfully to swing KB to chest height. Let momentum do the work, not your arms.", "usesWeight": true, "isTimed": false}
    ],
    "saturday": [],
    "sunday": []
  }
}`);
    promptSections.push("\nIMPORTANT: Your entire response MUST be only the JSON object. No other text, apologies, or explanations. Adhere strictly to the JSON structure and field requirements, especially for the exercise 'description' using '\\n' for new lines between steps.");

    const finalPrompt = promptSections.join("\n");
    logger.info(`Final prompt for Gemini (User: ${userId}, Model: ${GEMINI_MODEL_NAME}, Prompt Length: ${finalPrompt.length})`);

    const apiRequest: GenerateContentRequest = {
      contents: [{ role: "user", parts: [{ text: finalPrompt }] }],
      generationConfig: {
        temperature: 0.7,
        responseMimeType: "application/json",
      },
      safetySettings: [
        { category: HarmCategory.HARM_CATEGORY_HARASSMENT, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
        { category: HarmCategory.HARM_CATEGORY_HATE_SPEECH, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
        { category: HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
        { category: HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
      ],
    };

    let responseText = "";
    try {
      logger.info("Attempting to call Gemini API...", { userId });
      const result = await geminiModel!.generateContent(apiRequest);
      const response = result.response;
      logger.info("Successfully received response from Gemini API.", { userId });

      if (response.promptFeedback?.blockReason) {
        logger.warn(`AI request blocked. Reason: ${response.promptFeedback.blockReason}`, { userId, feedback: response.promptFeedback });
        throw new HttpsError("aborted", `AI content generation was blocked: ${response.promptFeedback.blockReason}. Please try rephrasing your request or check content policies.`);
      }
      if (!response.candidates?.length || !response.candidates[0].content?.parts?.length) {
        logger.error("AI returned no candidates or empty content parts.", { userId, response });
        throw new HttpsError("internal", "AI service returned an unexpected or empty response. Please try again later.");
      }

      responseText = response.text();
      logger.info(`Raw JSON response received from Gemini (User: ${userId}, Length: ${responseText.length})`);

    } catch (error: any) {
      logger.error(`Error calling Gemini API (User: ${userId}):`, { message: error.message, details: error.details, stack: error.stack, errorObject: JSON.stringify(error) });
      if (error instanceof HttpsError) throw error;
      if (error.message && error.message.includes("API key not valid")) {
        throw new HttpsError("unauthenticated", "AI service authentication failed. Please check API key configuration.");
      }
      throw new HttpsError("internal", "Failed to communicate with the AI service. Please try again later.", error.message);
    }

    let parsedRoutine: AiGeneratedRoutineParts;
    try {
      const jsonStringToParse = responseText.trim();
      if (!jsonStringToParse) {
        logger.error("Received empty or whitespace-only JSON string from AI.", { userId });
        throw new Error("Received empty JSON string.");
      }
      parsedRoutine = JSON.parse(jsonStringToParse);
    } catch (parseError: any) {
      logger.error(`Failed to parse Gemini JSON (User: ${userId}):`, { errorMessage: parseError.message, originalResponseText: responseText.substring(0, 1000) });
      throw new HttpsError("internal", "The AI's response was not in the expected JSON format. Please try again.");
    }

    if (
      typeof parsedRoutine.name !== "string" || !parsedRoutine.name.trim() ||
      typeof parsedRoutine.durationInWeeks !== "number" || parsedRoutine.durationInWeeks <= 0 ||
      typeof parsedRoutine.dailyWorkouts !== "object" || parsedRoutine.dailyWorkouts === null
    ) {
      logger.error("Parsed routine has invalid top-level structure:", { userId, parsedRoutineName: parsedRoutine.name, parsedDuration: parsedRoutine.durationInWeeks, dailyWorkoutsType: typeof parsedRoutine.dailyWorkouts });
      throw new HttpsError("internal", "AI generated invalid structure (name, duration, or dailyWorkouts).");
    }

    const generatedWorkoutDays = Object.keys(parsedRoutine.dailyWorkouts).filter(day => parsedRoutine.dailyWorkouts[day]?.length > 0);
    const numGeneratedWorkoutDays = generatedWorkoutDays.length;

    if (useSpecifiedDays && onboarding.workout_days?.length) {
      if (numGeneratedWorkoutDays !== actualWorkoutDaysCount) {
        logger.warn(`AI Discrepancy: Expected ${actualWorkoutDaysCount} specific workout days, but got ${numGeneratedWorkoutDays}. User specified: ${onboarding.workout_days.join(", ")}, AI generated workouts for: ${generatedWorkoutDays.join(", ")}. User ID: ${userId}`);
      } else {
        const specifiedDaySet = new Set(onboarding.workout_days.map(d => d.toLowerCase()));
        const generatedDaySet = new Set(generatedWorkoutDays.map(d => d.toLowerCase()));
        let daysMatch = true;
        if (specifiedDaySet.size !== generatedDaySet.size) daysMatch = false;
        else {
          for (const day of specifiedDaySet) if (!generatedDaySet.has(day)) { daysMatch = false; break; }
        }
        if (!daysMatch) {
          logger.warn(`AI Discrepancy: Generated ${numGeneratedWorkoutDays} workout days, but not the *exact* days specified. User: ${onboarding.workout_days.join(", ")}, AI: ${generatedWorkoutDays.join(", ")}. User ID: ${userId}`);
        } else {
          logger.info(`AI Adherence: Correctly generated ${actualWorkoutDaysCount} workouts on the specified days: ${generatedWorkoutDays.join(", ")}. User ID: ${userId}`);
        }
      }
    } else {
      if (numGeneratedWorkoutDays < 1 && actualWorkoutDaysCount > 0) {
        logger.warn(`AI generated a routine with no workout days, even though ${actualWorkoutDaysCount} were requested. User ID: ${userId}`);
      } else {
        logger.info(`AI generated ${numGeneratedWorkoutDays} workout days (requested around ${actualWorkoutDaysCount}). User ID: ${userId}`);
      }
    }

    for (const day of DAYS_OF_WEEK) {
      if (!Object.prototype.hasOwnProperty.call(parsedRoutine.dailyWorkouts, day)) {
        logger.warn(`Day '${day}' was missing from AI response, adding as rest day.`, { userId });
        parsedRoutine.dailyWorkouts[day] = [];
      } else if (!Array.isArray(parsedRoutine.dailyWorkouts[day])) {
        logger.error(`Exercises for day '${day}' is not an array in AI response. Received:`, { userId, dayData: parsedRoutine.dailyWorkouts[day] });
        parsedRoutine.dailyWorkouts[day] = [];
      }

      for (const exercise of parsedRoutine.dailyWorkouts[day]) {
        if (
          typeof exercise.name !== "string" || !exercise.name.trim() ||
          typeof exercise.sets !== "number" || exercise.sets <= 0 ||
          typeof exercise.reps !== "string" || !exercise.reps.trim() ||
          typeof exercise.description !== "string" // S'assurer que la description est une chaîne
        ) {
          logger.error(`Invalid exercise structure or missing/invalid description on day '${day}':`, { userId, exerciseDetails: exercise });
          if (typeof exercise.description !== "string") {
            exercise.description = "Instructions for this exercise are currently unavailable."; // Message par défaut
          }
          // Si le nom est manquant, on pourrait vouloir sauter l'exercice ou lui donner un nom par défaut
          // Pour l'instant, si la structure de base est mauvaise, la validation plus haut devrait l'attraper.
          // Ici, on s'assure que la description est au moins une chaîne initialisée.
        }

        // S'assurer que la description est trimée et a un fallback si elle est vide après trim
        exercise.description = exercise.description.trim();
        if (!exercise.description) {
          exercise.description = "How to perform: Detailed instructions will be available soon.";
        }


        exercise.weightSuggestionKg = (typeof exercise.weightSuggestionKg === "string" && exercise.weightSuggestionKg.trim())
          ? exercise.weightSuggestionKg.trim()
          : "N/A";
        exercise.restBetweenSetsSeconds = (typeof exercise.restBetweenSetsSeconds === "number" && exercise.restBetweenSetsSeconds >= 0)
          ? exercise.restBetweenSetsSeconds
          : 60;

        exercise.usesWeight = typeof exercise.usesWeight === "boolean" ? exercise.usesWeight : true;
        exercise.isTimed = typeof exercise.isTimed === "boolean" ? exercise.isTimed : false;

        if (!exercise.isTimed) {
          exercise.targetDurationSeconds = undefined;
        } else {
          exercise.targetDurationSeconds = typeof exercise.targetDurationSeconds === "number" && exercise.targetDurationSeconds > 0
            ? exercise.targetDurationSeconds
            : undefined;
        }
      }
    }

    logger.info(`Successfully generated and validated AI routine for User: ${userId}. Routine Name: "${parsedRoutine.name}"`);
    return parsedRoutine;
  }
);
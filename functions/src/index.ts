// functions/src/index.ts

// v2 Imports for Firebase Functions
import { defineString } from "firebase-functions/params"; // defineString for string secrets/params
import { logger } from "firebase-functions/v2"; // v2 logger
import { CallableRequest, HttpsError, onCall } from "firebase-functions/v2/https"; // Use CallableRequest for typed request

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
// This defines a secret that will be sourced from Google Secret Manager in deployed environments.
// Ensure the secret named 'GEMINI_API_KEY' (or your chosen name) exists in Secret Manager.
const geminiApiKey = defineString("GEMINI_API_KEY"); // Renamed for clarity (parameter vs secret object)

// --- Gemini API Client Initialization (Global, conditional for emulator) ---
let apiKeyForInitialization: string | undefined;
const isEmulator = process.env.FUNCTIONS_EMULATOR === "true";

if (isEmulator) {
  logger.log("Running in Firebase Emulator. Attempting to read GEMINI_API_KEY from process.env (functions/.env file).");
  // In emulator, v2 params like defineString are not automatically populated from .env in the same way as v1 defineSecret.
  // We still rely on process.env for the emulator in this setup.
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

// Initialize Gemini client globally if running in emulator and API key is available.
let genAI: GoogleGenerativeAI | null = isEmulator && apiKeyForInitialization
  ? new GoogleGenerativeAI(apiKeyForInitialization)
  : null;

// >>>>> CHOOSE YOUR GEMINI MODEL HERE <<<<<
const GEMINI_MODEL_NAME = "gemini-1.5-flash-latest"; // Or "gemini-1.5-pro-latest", etc.

let geminiModel: ReturnType<GoogleGenerativeAI["getGenerativeModel"]> | null = genAI
  ? genAI.getGenerativeModel({ model: GEMINI_MODEL_NAME })
  : null;

if (isEmulator && apiKeyForInitialization && !geminiModel) {
  logger.error(`EMULATOR: Failed to get Gemini model "${GEMINI_MODEL_NAME}" during global initialization.`);
}


// --- Interface Definitions (TypeScript Types) ---
// (These remain the same as your v1 version)
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
    height_cm?: number;
  };
}
interface PreviousRoutineData {
  id?: string;
  name?: string;
  durationInWeeks?: number;
  dailyWorkouts?: {
    [day: string]: Array<{ [key: string]: any }>;
  };
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
  description?: string | null;
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
  // v2 Options for secrets, region, memory, timeout, etc.
  {
    secrets: [geminiApiKey], // Use the definedString parameter here
    // region: "europe-west1",   // Example: Specify region if not default
    memory: "512MiB",        // Memory allocation (e.g., "256MiB", "512MiB", "1GiB")
    timeoutSeconds: 120,     // Timeout for the function execution
    // invoker: "public",    // 'public' allows unauthenticated calls. Default is private (requires auth).
    // For callable functions, auth is usually checked inside the handler.
    // enforceAppCheck: true, // Enable App Check if configured for your project (recommended)
    // concurrency: 10,       // Control max concurrent instances
  },
  // The handler function receives a 'request' object of type CallableRequest<T>
  // where T is the type of request.data (AiRoutineRequestPayload in this case).
  async (request: CallableRequest<AiRoutineRequestPayload>): Promise<AiGeneratedRoutineParts> => {

    // --- Initialize/Verify Gemini Client WITHIN the function ---
    // This is crucial for deployed functions to access secrets correctly and for cold starts.
    if (!isEmulator) { // DEPLOYED environment
      const apiKeyFromSecret = geminiApiKey.value(); // Access the secret value
      if (!apiKeyFromSecret) {
        logger.error("Gemini API Key from Secret Manager (defineString) is not available in deployed function.");
        throw new HttpsError("internal", "AI Service API Key configuration error (secret missing).");
      }
      // Initialize or re-initialize if it's a cold start or if global init (which wouldn't happen for deployed) failed.
      if (!genAI || !geminiModel) {
        genAI = new GoogleGenerativeAI(apiKeyFromSecret);
        geminiModel = genAI.getGenerativeModel({ model: GEMINI_MODEL_NAME });
        logger.info(`Gemini client initialized/re-initialized within deployed function call with model ${GEMINI_MODEL_NAME}.`);
      }
    } else { // EMULATOR environment
      if (!geminiModel) { // Check if global initialization (based on .env) was successful
        logger.error("EMULATOR: Gemini model not initialized. Ensure GEMINI_API_KEY is in functions/.env and model name is correct.");
        throw new HttpsError("internal", "AI Service (emulator) is not configured correctly. Model could not be loaded.");
      }
    }

    // Defensive check: Ensure geminiModel is available
    if (!geminiModel) {
      logger.error("Critical: Gemini model instance is null before API call. This indicates a setup issue.");
      throw new HttpsError("internal", "AI Service is currently unavailable due to a configuration problem.");
    }

    // 1. Authentication Check (from request.auth)
    if (!request.auth) {
      // This check is standard for callable functions that require authentication.
      // If you set `invoker: "public"`, this check would still be good practice internally.
      throw new HttpsError("unauthenticated", "The function must be called by an authenticated user.");
    }
    const userId = request.auth.uid;
    logger.info(`User ${userId} authenticated. Requesting AI routine (v2) using Gemini model: ${GEMINI_MODEL_NAME}.`);

    // 2. Input Data Retrieval and Validation (from request.data)
    // request.data is already typed as AiRoutineRequestPayload due to onCall<AiRoutineRequestPayload, ...>
    const payload = request.data;
    logger.debug("Received payload (v2):", { userId, payload }); // Log with context

    if (!payload.onboardingData || typeof payload.onboardingData !== "object" || Object.keys(payload.onboardingData).length === 0) {
      throw new HttpsError("invalid-argument", "Valid 'onboardingData' object is required to generate a routine.");
    }
    const onboarding = payload.onboardingData;
    const previousRoutine = payload.previousRoutineData; // Optional


    // 3. Prompt Construction for Gemini
    // (The prompt construction logic remains identical to your v1 version)
    const promptSections: string[] = [];
    promptSections.push("You are an expert fitness coach AI. Your primary task is to generate a highly personalized weekly workout routine. The routine should be based on the user's profile, preferences, and optionally, their previous routine for progression or variation. Your entire output MUST be a single, valid JSON object conforming to the specified structure. Do not include any explanatory text, markdown formatting, or anything outside of this JSON object.");

    promptSections.push("\n--- User Profile & Preferences ---");
    promptSections.push(`- Primary Fitness Goal: ${onboarding.goal || "Not specified"}`);
    promptSections.push(`- Gender: ${onboarding.gender || "Not specified"}`);
    promptSections.push(`- Experience Level: ${onboarding.experience || "Beginner"}`);
    promptSections.push(`- Training Frequency (days/week): ${onboarding.frequency || "3-4"}`);
    if (onboarding.workout_days?.length) promptSections.push(`- Preferred Workout Days: ${onboarding.workout_days.join(", ")}`);
    if (onboarding.equipment?.length) promptSections.push(`- Available Equipment: ${onboarding.equipment.join(", ")}`);
    else promptSections.push("- Available Equipment: Bodyweight only");
    if (onboarding.focus_areas?.length) promptSections.push(`- Specific Body Part Focus: ${onboarding.focus_areas.join(", ")} (Incorporate exercises for these areas)`);

    if (onboarding.physical_stats) {
      promptSections.push("- Physical Statistics:");
      if (onboarding.physical_stats.age != null) promptSections.push(`  - Age: ${onboarding.physical_stats.age} years`);
      if (onboarding.physical_stats.weight_kg != null) promptSections.push(`  - Current Weight: ${onboarding.physical_stats.weight_kg} kg`);
      if (onboarding.physical_stats.height_cm != null) promptSections.push(`  - Height: ${onboarding.physical_stats.height_cm} cm`);
    }

    if (previousRoutine?.name) {
      promptSections.push("\n--- Previous Routine Context (for variation and progression) ---");
      promptSections.push(`- Previous Plan Name: ${previousRoutine.name}`);
      if (previousRoutine.durationInWeeks != null) promptSections.push(`- Previous Plan Duration: ${previousRoutine.durationInWeeks} weeks`);
      promptSections.push("Please ensure the new routine offers appropriate progression (e.g., increased intensity, volume, or different exercises) or variation compared to this previous plan.");
    }

    promptSections.push("\n--- Output Structure & Instructions ---");
    promptSections.push("1. Generate a creative and descriptive 'name' (string) for the routine.");
    promptSections.push("2. Determine an appropriate 'durationInWeeks' (number, typically between 4 and 8 weeks).");
    promptSections.push("3. Provide a 'dailyWorkouts' object. This object MUST contain keys for all 7 days of the week: \"monday\", \"tuesday\", \"wednesday\", \"thursday\", \"friday\", \"saturday\", \"sunday\".");
    promptSections.push("   - For workout days, the value should be an array of exercise objects.");
    promptSections.push("   - For rest days, the value should be an empty array [].");
    promptSections.push("4. Each exercise object within the array MUST have the following properties:");
    promptSections.push("   - \"name\": string (e.g., \"Barbell Squats\")");
    promptSections.push("   - \"sets\": number (e.g., 3)");
    promptSections.push("   - \"reps\": string (e.g., \"8-12\", \"5x5\", \"AMRAP\", \"30 seconds\")");
    promptSections.push("5. Optional exercise object properties (provide sensible defaults or values based on context):");
    promptSections.push("   - \"weightSuggestionKg\": string (e.g., \"60\", \"Bodyweight\", or \"N/A\" if not applicable. Can also be descriptive like \"Light\" or \"Moderate\" if numerical is hard to guess.)");
    promptSections.push("   - \"restBetweenSetsSeconds\": number (e.g., 60, 90, 120. Default to 60-90 if not specified).");
    promptSections.push("   - \"description\": string (e.g., \"Focus on form.\", or empty string \"\" if no specific notes).");

    promptSections.push("\n--- JSON Structure Example (Your output MUST follow this format PRECISELY) ---");
    promptSections.push(`
{
  "name": "Intermediate Strength Builder - Phase 1",
  "durationInWeeks": 6,
  "dailyWorkouts": {
    "monday": [
      {"name": "Barbell Back Squats", "sets": 4, "reps": "6-8", "weightSuggestionKg": "70% of 1RM", "restBetweenSetsSeconds": 120, "description": "Focus on depth and controlled movement."},
      {"name": "Romanian Deadlifts", "sets": 3, "reps": "8-10", "weightSuggestionKg": "Moderate", "restBetweenSetsSeconds": 90, "description": "Keep back straight, slight knee bend."},
      {"name": "Leg Press", "sets": 3, "reps": "10-15", "weightSuggestionKg": "Moderate-Heavy", "restBetweenSetsSeconds": 75, "description": ""}
    ],
    "tuesday": [], 
    "wednesday": [
      {"name": "Bench Press", "sets": 4, "reps": "6-8", "weightSuggestionKg": "70% of 1RM", "restBetweenSetsSeconds": 120, "description": "Touch chest lightly."},
      {"name": "Overhead Press (Barbell)", "sets": 3, "reps": "8-10", "weightSuggestionKg": "Moderate", "restBetweenSetsSeconds": 90, "description": "Full range of motion."},
      {"name": "Dumbbell Rows", "sets": 3, "reps": "10-12 per side", "weightSuggestionKg": "Moderate", "restBetweenSetsSeconds": 75, "description": "Squeeze at the top."}
    ],
    "thursday": [],
    "friday": [
      {"name": "Deadlifts (Conventional)", "sets": 1, "reps": "5", "weightSuggestionKg": "80% of 1RM", "restBetweenSetsSeconds": 180, "description": "Heavy set. Focus on form."},
      {"name": "Pull-ups (or Lat Pulldowns)", "sets": 3, "reps": "AMRAP", "weightSuggestionKg": "Bodyweight", "restBetweenSetsSeconds": 90, "description": "If Lat Pulldowns, aim for 8-12 reps."},
      {"name": "Plank", "sets": 3, "reps": "60 seconds", "weightSuggestionKg": "N/A", "restBetweenSetsSeconds": 60, "description": "Maintain a straight line."}
    ],
    "saturday": [],
    "sunday": []
  }
}`);
    promptSections.push("\nRemember: Only the JSON object as output. No introductory or concluding remarks.");

    const finalPrompt = promptSections.join("\n");
    logger.info(`Final prompt for Gemini (User: ${userId}, Model: ${GEMINI_MODEL_NAME}, Prompt Length: ${finalPrompt.length})`);


    // 4. Call Gemini API
    // (The API request logic remains identical to your v1 version)
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
      const result = await geminiModel!.generateContent(apiRequest); // geminiModel! is asserted non-null
      const response = result.response;

      if (response.promptFeedback?.blockReason) {
        logger.warn(`AI request blocked by Gemini. Reason: ${response.promptFeedback.blockReason}`, { userId, feedback: response.promptFeedback });
        throw new HttpsError("aborted", `AI content generation was blocked: ${response.promptFeedback.blockReason}. Please try rephrasing or check content policies.`);
      }
      if (!response.candidates?.length || !response.candidates[0].content?.parts?.length) {
        logger.error("AI returned no candidates or empty content parts.", { userId, response });
        throw new HttpsError("internal", "AI service returned an unexpected or empty response.");
      }

      responseText = response.text();
      logger.info(`Raw JSON response text received from Gemini (User: ${userId}, Length: ${responseText.length})`);

    } catch (error: any) {
      logger.error(`Error calling Gemini API (User: ${userId}):`, { message: error.message, details: error.details, stack: error.stack });
      if (error instanceof HttpsError) throw error;
      throw new HttpsError("internal", "Failed to communicate with the AI service. Please try again later.", error.message);
    }


    // 5. Parse and Validate JSON Response
    // (The parsing and validation logic remains identical to your v1 version)
    let parsedRoutine: AiGeneratedRoutineParts;
    try {
      const jsonStringToParse = responseText.trim();
      if (!jsonStringToParse) {
        throw new Error("Received empty or whitespace-only JSON string from AI response.");
      }
      parsedRoutine = JSON.parse(jsonStringToParse);
    } catch (parseError: any) {
      logger.error(`Failed to parse Gemini JSON response (User: ${userId}):`, { errorMessage: parseError.message, originalResponseText: responseText });
      throw new HttpsError("internal", "The AI's response was not in the expected JSON format. Please try again.");
    }

    if (
      typeof parsedRoutine.name !== "string" || !parsedRoutine.name.trim() ||
      typeof parsedRoutine.durationInWeeks !== "number" || parsedRoutine.durationInWeeks <= 0 ||
      typeof parsedRoutine.dailyWorkouts !== "object" || parsedRoutine.dailyWorkouts === null
    ) {
      logger.error("Parsed routine from AI has invalid top-level structure:", { userId, parsedRoutine });
      throw new HttpsError("internal", "AI generated a routine with an invalid structure (name, duration, or dailyWorkouts).");
    }

    for (const day of DAYS_OF_WEEK) {
      if (!Object.prototype.hasOwnProperty.call(parsedRoutine.dailyWorkouts, day)) {
        logger.warn(`Day '${day}' was missing in AI response, adding as a rest day.`, { userId });
        parsedRoutine.dailyWorkouts[day] = [];
      } else if (!Array.isArray(parsedRoutine.dailyWorkouts[day])) {
        logger.error(`Exercises for day '${day}' is not an array as expected. Received:`, { userId, dayData: parsedRoutine.dailyWorkouts[day] });
        throw new HttpsError("internal", `AI generated routine has an invalid structure for day '${day}' (expected an array).`);
      }

      for (const exercise of parsedRoutine.dailyWorkouts[day]) {
        if (
          typeof exercise.name !== "string" || !exercise.name.trim() ||
          typeof exercise.sets !== "number" || exercise.sets <= 0 ||
          typeof exercise.reps !== "string" || !exercise.reps.trim()
        ) {
          logger.error(`Invalid exercise structure found for day '${day}':`, { userId, exerciseDetails: exercise });
          throw new HttpsError("internal", `AI generated an exercise with invalid structure (name, sets, or reps) on day '${day}'.`);
        }
        exercise.weightSuggestionKg = (typeof exercise.weightSuggestionKg === "string" && exercise.weightSuggestionKg.trim())
          ? exercise.weightSuggestionKg.trim()
          : "N/A";
        exercise.restBetweenSetsSeconds = (typeof exercise.restBetweenSetsSeconds === "number" && exercise.restBetweenSetsSeconds >= 0)
          ? exercise.restBetweenSetsSeconds
          : 60;
        exercise.description = (typeof exercise.description === "string" && exercise.description.trim())
          ? exercise.description.trim()
          : "";
      }
    }

    logger.info(`Successfully generated and validated AI routine for User: ${userId}. Routine Name: "${parsedRoutine.name}", Duration: ${parsedRoutine.durationInWeeks} weeks.`);
    return parsedRoutine;
  }
); // End of generateAiRoutineV2 Cloud Function
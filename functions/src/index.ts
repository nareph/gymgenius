// functions/src/index.ts
import {
  GenerateContentRequest,
  GoogleGenerativeAI,
  HarmBlockThreshold,
  HarmCategory,
} from "@google/generative-ai";
import * as admin from "firebase-admin";
import { defineSecret } from 'firebase-functions/params'; // Pour les secrets en déploiement
import * as functions from 'firebase-functions/v1'; // Utiliser v1 pour onCall

// --- Initialisation Firebase Admin ---
admin.initializeApp();

// --- Configuration du Secret pour la Clé API Gemini ---
// Remplacez 'gemini-api-key' par le nom exact de votre secret dans Secret Manager
const geminiApiKeySecret = defineSecret('gemini-api-key');

// --- Initialisation de l'API Gemini (Globale mais conditionnelle pour l'émulateur) ---
let apiKeyForInitialization: string | undefined;
let isEmulator = process.env.FUNCTIONS_EMULATOR === 'true';

if (isEmulator) {
  console.log("Running in emulator, reading GEMINI_API_KEY from process.env");
  apiKeyForInitialization = process.env.GEMINI_API_KEY; // Lire depuis .env
  if (!apiKeyForInitialization) {
    console.warn("------------------------------------------------------------");
    console.warn("WARNING: GEMINI_API_KEY not found in process.env (.env file in functions directory).");
    console.warn("         AI routine generation will likely fail in the emulator.");
    console.warn("------------------------------------------------------------");

  }
} else {
  console.log("Running in deployed environment. API Key will be accessed from secret within function.");
  // En déploiement, la clé sera chargée via geminiApiKeySecret.value() dans la fonction.
}

// Initialiser globalement pour l'émulateur si la clé est dispo, sinon sera fait dans la fonction
let genAI: GoogleGenerativeAI | null = isEmulator && apiKeyForInitialization
  ? new GoogleGenerativeAI(apiKeyForInitialization)
  : null;

// >>>>> CHOISISSEZ VOTRE MODÈLE ICI <<<<<
const GEMINI_MODEL_NAME = "gemini-1.5-flash-latest"; // << ASSUREZ-VOUS QUE CE NOM EST CORRECT
let geminiModel: ReturnType<GoogleGenerativeAI['getGenerativeModel']> | null = genAI
  ? genAI.getGenerativeModel({ model: GEMINI_MODEL_NAME })
  : null;

// --- Définition des Interfaces (Types) ---
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


// --- Cloud Function ---
export const generateAiRoutine = functions
  // Spécifier la région si nécessaire, ex: .region("europe-west1")
  .runWith({ secrets: [geminiApiKeySecret] }) // Indiquer le secret requis pour le déploiement
  .https.onCall(
    async (data: any, context: functions.https.CallableContext): Promise<AiGeneratedRoutineParts> => {

      // --- Initialisation/Vérification de Gemini DANS la fonction ---
      if (!isEmulator) { // En DÉPLOIEMENT
        const apiKeyFromSecret = geminiApiKeySecret.value();
        if (!apiKeyFromSecret) {
          functions.logger.error("Gemini API Key secret value is not available in deployed function.");
          throw new functions.https.HttpsError("internal", "AI Service API Key configuration error.");
        }
        // Initialiser si l'instance est froide ou si l'init globale n'a pas été faite
        if (!genAI || !geminiModel) {
          genAI = new GoogleGenerativeAI(apiKeyFromSecret);
          geminiModel = genAI.getGenerativeModel({ model: GEMINI_MODEL_NAME });
          functions.logger.info(`Gemini client initialized within deployed function call with model ${GEMINI_MODEL_NAME}.`);
        }
      } else { // En ÉMULATION
        if (!geminiModel) { // Vérifier si l'init globale (basée sur .env) a réussi
          functions.logger.error("Gemini model not initialized for emulator. Check .env file and GEMINI_API_KEY variable.");
          throw new functions.https.HttpsError("internal", "AI Service (emulator) is not configured correctly.");
        }
      }
      // À partir d'ici, geminiModel devrait être non-null si tout va bien

      // 1. Vérification de l'Authentification
      if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "The function must be called by an authenticated user.");
      }

      const userId = context.auth.uid;
      functions.logger.info(`User ${userId} requested AI routine using ${GEMINI_MODEL_NAME}.`);

      const payload = data as AiRoutineRequestPayload;
      functions.logger.debug("Received payload (casted):", payload);

      // 2. Validation des Données d'Entrée
      if (!payload.onboardingData || typeof payload.onboardingData !== "object" || Object.keys(payload.onboardingData).length === 0) {
        throw new functions.https.HttpsError("invalid-argument", "Valid Onboarding data object is required to generate a routine.");
      }
      const onboarding = payload.onboardingData;
      const previousRoutine = payload.previousRoutineData;

      // 3. Construction du Prompt pour Gemini
      const promptSections: string[] = [];
      promptSections.push("You are an expert fitness coach AI. Your task is to generate a highly personalized weekly workout routine based on the user's profile and preferences. Provide the output *only* as a valid JSON object that conforms to the specified structure.");
      promptSections.push("\nUser Profile & Preferences:");
      promptSections.push(`- Primary Goal: ${onboarding.goal || "Not specified"}`);
      promptSections.push(`- Gender: ${onboarding.gender || "Not specified"}`);
      promptSections.push(`- Experience Level: ${onboarding.experience || "Not specified"}`);
      promptSections.push(`- Training Frequency (days/week): ${onboarding.frequency || "Not specified"}`);
      if (onboarding.workout_days?.length) promptSections.push(`- Preferred Workout Days: ${onboarding.workout_days.join(", ")}`);
      if (onboarding.equipment?.length) promptSections.push(`- Available Equipment: ${onboarding.equipment.join(", ")}`);
      if (onboarding.focus_areas?.length) promptSections.push(`- Focus Body Parts: ${onboarding.focus_areas.join(", ")}`);
      if (onboarding.physical_stats) {
        promptSections.push("- Physical Stats:");
        if (onboarding.physical_stats.age != null) promptSections.push(`  - Age: ${onboarding.physical_stats.age} years`);
        if (onboarding.physical_stats.weight_kg != null) promptSections.push(`  - Weight: ${onboarding.physical_stats.weight_kg} kg`);
        if (onboarding.physical_stats.height_cm != null) promptSections.push(`  - Height: ${onboarding.physical_stats.height_cm} cm`);
      }
      if (previousRoutine?.name) {
        promptSections.push("\nPrevious Routine Context (for variation and progression):");
        promptSections.push(`- Previous Plan Name: ${previousRoutine.name}`);
        if (previousRoutine.durationInWeeks != null) promptSections.push(`- Previous Duration: ${previousRoutine.durationInWeeks} weeks`);
        promptSections.push("Please ensure the new routine offers progression or variation.");
      }
      promptSections.push("\nOutput Instructions:");
      promptSections.push("1. Generate a 'name' (string).");
      promptSections.push("2. Determine 'durationInWeeks' (number).");
      promptSections.push("3. Provide 'dailyWorkouts' object with keys for all 7 days (lowercase). Rest days are empty arrays [].");
      promptSections.push("4. Each exercise object must have: \"name\" (string), \"sets\" (number), \"reps\" (string).");
      promptSections.push("   Optional exercise fields (provide sensible defaults or given values if applicable): \"weightSuggestionKg\" (string), \"restBetweenSetsSeconds\" (number), \"description\" (string). Assign defaults like \"N/A\", 60, \"\" if no specific value.");
      promptSections.push("\nIMPORTANT: The entire output MUST be a single, valid JSON object. No other text or formatting.");
      promptSections.push("JSON Structure Example:");
      promptSections.push(`
{
  "name": "Example Fitness Plan",
  "durationInWeeks": 4,
  "dailyWorkouts": {
    "monday": [{"name": "Squats", "sets": 3, "reps": "8-12", "weightSuggestionKg": "60", "restBetweenSetsSeconds": 90, "description": "Keep back straight."}],
    "tuesday": [],
    "wednesday": [{"name": "Deadlifts", "sets": 1, "reps": "5", "weightSuggestionKg": "100", "restBetweenSetsSeconds": 180, "description": ""}],
    "thursday": [],
    "friday": [{"name": "Overhead Press", "sets": 3, "reps": "8-10", "weightSuggestionKg": "40", "restBetweenSetsSeconds": 75, "description": "Keep core tight."}],
    "saturday": [],
    "sunday": []
  }
}`);

      const finalPrompt = promptSections.join("\n");
      functions.logger.info("Final prompt for Gemini:", { userId, model: GEMINI_MODEL_NAME, promptLength: finalPrompt.length });

      // 4. Appel à l'API Gemini
      const request: GenerateContentRequest = {
        contents: [{ role: "user", parts: [{ text: finalPrompt }] }],
        generationConfig: {
          temperature: 0.6,
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
        // Utiliser geminiModel! car on l'a initialisé/vérifié au début de la fonction
        const result = await geminiModel!.generateContent(request);
        const response = result.response;
        if (response.promptFeedback?.blockReason) { throw new functions.https.HttpsError("aborted", `AI request blocked: ${response.promptFeedback.blockReason}.`); }
        if (!response.candidates?.length || !response.candidates[0].content?.parts?.length) { throw new functions.https.HttpsError("internal", "AI returned an empty response."); }
        responseText = response.text();
        functions.logger.info("Raw JSON response text from Gemini:", { userId, responseTextLength: responseText.length });

      } catch (error: any) {
        functions.logger.error("Error calling Gemini API:", { userId, error: error.message, details: error.stack });
        if (error instanceof functions.https.HttpsError) throw error;
        throw new functions.https.HttpsError("internal", "Failed to communicate with AI service.", error.message);
      }

      // 5. Parser et Valider la Réponse JSON
      let parsedRoutine: AiGeneratedRoutineParts;
      try {
        const jsonStringToParse = responseText.trim();
        if (!jsonStringToParse) throw new Error("Received empty JSON string from AI response.");
        parsedRoutine = JSON.parse(jsonStringToParse);
      } catch (parseError: any) {
        functions.logger.error("Failed to parse Gemini JSON response:", { userId, error: parseError.message, originalResponseText: responseText });
        throw new functions.https.HttpsError("internal", "AI response was not in the expected JSON format.");
      }

      // Validation approfondie de la structure
      if (
        typeof parsedRoutine.name !== "string" || !parsedRoutine.name.trim() ||
        typeof parsedRoutine.durationInWeeks !== "number" || parsedRoutine.durationInWeeks <= 0 ||
        typeof parsedRoutine.dailyWorkouts !== "object" || parsedRoutine.dailyWorkouts === null
      ) {
        functions.logger.error("Parsed routine has invalid top-level structure:", { userId, parsedRoutine });
        throw new functions.https.HttpsError("internal", "AI generated routine has an invalid structure (name, duration, or dailyWorkouts).");
      }

      for (const day of DAYS_OF_WEEK) {
        if (!Object.prototype.hasOwnProperty.call(parsedRoutine.dailyWorkouts, day)) {
          functions.logger.warn(`Day '${day}' missing in AI response, adding as rest day.`, { userId });
          parsedRoutine.dailyWorkouts[day] = [];
        } else if (!Array.isArray(parsedRoutine.dailyWorkouts[day])) {
          functions.logger.error(`Exercises for day '${day}' is not an array.`, { userId, dayData: parsedRoutine.dailyWorkouts[day] });
          throw new functions.https.HttpsError("internal", `AI generated routine has an invalid structure for day '${day}'.`);
        }

        for (const exercise of parsedRoutine.dailyWorkouts[day]) {
          if (
            typeof exercise.name !== "string" || !exercise.name.trim() ||
            typeof exercise.sets !== "number" || exercise.sets <= 0 ||
            typeof exercise.reps !== "string" || !exercise.reps.trim()
          ) {
            functions.logger.error(`Invalid exercise structure for day '${day}':`, { userId, exercise });
            throw new functions.https.HttpsError("internal", `AI generated an exercise with invalid structure on '${day}'.`);
          }
          exercise.weightSuggestionKg = (typeof exercise.weightSuggestionKg === "string" && exercise.weightSuggestionKg.trim()) ? exercise.weightSuggestionKg.trim() : "N/A";
          exercise.restBetweenSetsSeconds = (typeof exercise.restBetweenSetsSeconds === "number" && exercise.restBetweenSetsSeconds >= 0) ? exercise.restBetweenSetsSeconds : 60;
          exercise.description = (typeof exercise.description === "string" && exercise.description.trim()) ? exercise.description.trim() : "";
        }
      }

      functions.logger.info("Successfully generated and validated routine:", { userId, model: GEMINI_MODEL_NAME, routineName: parsedRoutine.name, duration: parsedRoutine.durationInWeeks });
      return parsedRoutine;
    }
  ); // Fin de generateAiRoutine
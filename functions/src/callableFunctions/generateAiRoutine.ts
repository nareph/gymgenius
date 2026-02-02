import { defineString } from "firebase-functions/params";
import { logger } from "firebase-functions/v2";
import { CallableRequest, HttpsError, onCall } from "firebase-functions/v2/https";

import { ensureGeminiClientInitialized, generateRoutineWithRetry } from "../services/geminiService";
import { cleanupPreviousRoutineData, getAggregatedPerformanceData } from "../services/workoutLogService";
import {
    AiGeneratedRoutineParts,
    AiRoutineRequestPayload
} from "../types";
import { calculateWorkoutDays, determineMuscleSplit } from "../utils/muscleSplitCalculator";
import { buildRoutinePrompt } from "../utils/promptBuilder";
import { validateAndNormalizeRoutine, validateOnboardingData } from "../utils/validationUtils";

const geminiApiKey = defineString("GEMINI_API_KEY");

export const generateAiRoutine = onCall<AiRoutineRequestPayload, Promise<AiGeneratedRoutineParts>>(
    {
        secrets: [geminiApiKey],
        memory: "1GiB",
        timeoutSeconds: 150,
    },
    async (request: CallableRequest<AiRoutineRequestPayload>): Promise<AiGeneratedRoutineParts> => {
        // Initialize Gemini client
        ensureGeminiClientInitialized();

        // Authentication check
        if (!request.auth) {
            throw new HttpsError("unauthenticated", "The function must be called by an authenticated user.");
        }

        const userId = request.auth.uid;
        logger.info(`User ${userId} authenticated. Requesting AI routine.`);

        const payload = request.data;
        const onboarding = payload.onboardingData;
        const previousRoutine = payload.previousRoutineData;

        try {
            // Validate input
            validateOnboardingData(onboarding);

            // Get performance data from previous routine
            const aggregatedPerformanceSummary = await getAggregatedPerformanceData(userId, previousRoutine || {});

            // Calculate workout days and muscle split
            const { actualWorkoutDaysCount, useSpecifiedDays } = calculateWorkoutDays(
                onboarding.frequency,
                onboarding.workout_days
            );

            const selectedSplit = determineMuscleSplit(actualWorkoutDaysCount, onboarding.experience || "beginner");
            logger.info(`Selected muscle split for ${actualWorkoutDaysCount} days:`, selectedSplit);

            // Build prompt and generate routine
            const finalPrompt = buildRoutinePrompt(
                onboarding,
                selectedSplit,
                actualWorkoutDaysCount,
                useSpecifiedDays,
                aggregatedPerformanceSummary,
                previousRoutine
            );

            logger.info(`Final prompt for Gemini with Muscle Split (User: ${userId}, Prompt Length: ${finalPrompt.length})`);

            const responseText = await generateRoutineWithRetry(finalPrompt, userId);

            // Parse and validate the response
            let parsedRoutine: AiGeneratedRoutineParts;
            try {
                parsedRoutine = JSON.parse(responseText.trim());
                parsedRoutine = validateAndNormalizeRoutine(parsedRoutine, userId);
            } catch (parseError: any) {
                logger.error(`Failed to parse Gemini JSON:`, {
                    userId,
                    errorMessage: parseError.message,
                    responseText: responseText.substring(0, 500)
                });
                throw new HttpsError("internal", "The AI's response was not in the expected JSON format.");
            }

            // Cleanup previous routine data after successful generation
            if (previousRoutine?.id) {
                await cleanupPreviousRoutineData(userId, previousRoutine.id);
            }

            logger.info(`Successfully generated and validated AI muscle split routine for User: ${userId}. Routine Name: "${parsedRoutine.name}"`);
            return parsedRoutine;
        } catch (error: any) {
            logger.error(`Error in generateAiRoutine for user ${userId}:`, {
                errorMessage: error.message,
                errorStack: error.stack
            });

            if (error instanceof HttpsError) {
                throw error;
            }

            // Convert generic errors to user-friendly HttpsError
            if (error.message?.includes("overloaded") || error.message?.includes("503")) {
                throw new HttpsError("unavailable", "Our workout generation service is currently busy. Please try again in a few moments.");
            }

            throw new HttpsError("internal", "An unexpected error occurred while generating your workout routine. Please try again.");
        }
    }
);
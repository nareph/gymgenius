import { GenerateContentRequest, GoogleGenerativeAI, HarmBlockThreshold, HarmCategory } from "@google/generative-ai";
import { defineString } from "firebase-functions/params";
import { logger } from "firebase-functions/v2";
import { HttpsError } from "firebase-functions/v2/https";

const geminiApiKey = defineString("GEMINI_API_KEY");

const GEMINI_MODELS = {
    primary: "gemini-2.5-flash",
    fallback: "gemini-2.0-flash-exp"
};

let genAI: GoogleGenerativeAI | null = null;
let currentModel = GEMINI_MODELS.primary;
let geminiModel: ReturnType<GoogleGenerativeAI["getGenerativeModel"]> | null = null;
let quotaExceededModels = new Set<string>();

export function ensureGeminiClientInitialized(): ReturnType<GoogleGenerativeAI["getGenerativeModel"]> {
    if (geminiModel) {
        return geminiModel;
    }

    const isEmulator = process.env.FUNCTIONS_EMULATOR === "true";
    let effectiveApiKey: string | undefined;

    if (isEmulator) {
        effectiveApiKey = process.env.GEMINI_API_KEY;
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

    // Start with primary model, but if it's in quota exceeded set, use fallback
    if (quotaExceededModels.has(GEMINI_MODELS.primary)) {
        currentModel = GEMINI_MODELS.fallback;
        logger.info(`Primary model is quota limited, starting with fallback: ${currentModel}`);
    }

    geminiModel = genAI.getGenerativeModel({ model: currentModel });
    logger.info(`Gemini client initialized with model ${currentModel} (Emulator: ${isEmulator}).`);

    return geminiModel;
}

function switchToFallbackModel(): boolean {
    if (currentModel === GEMINI_MODELS.primary && genAI && !quotaExceededModels.has(GEMINI_MODELS.fallback)) {
        currentModel = GEMINI_MODELS.fallback;
        geminiModel = genAI.getGenerativeModel({ model: currentModel });
        logger.info(`Switched to fallback model: ${currentModel}`);
        return true;
    }
    return false;
}

function markModelAsQuotaExceeded(model: string): void {
    quotaExceededModels.add(model);
    logger.warn(`Model marked as quota exceeded: ${model}`);
}

export async function generateRoutineWithRetry(
    prompt: string,
    userId: string
): Promise<string> {
    let localGeminiModel = ensureGeminiClientInitialized();
    let retryCount = 0;
    const maxRetries = 2;
    const baseDelay = 2000;
    let hasSwitchedModel = false;

    while (retryCount <= maxRetries) {
        try {
            logger.info(`Calling Gemini API with model: ${currentModel} (Attempt ${retryCount + 1}/${maxRetries + 1})`, {
                userId,
                promptLength: prompt.length,
                currentModel
            });

            const apiRequest: GenerateContentRequest = {
                contents: [{ role: "user", parts: [{ text: prompt }] }],
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

            const result = await localGeminiModel.generateContent(apiRequest);
            const response = result.response;

            if (response.promptFeedback?.blockReason) {
                logger.error(`AI request blocked. Reason: ${response.promptFeedback.blockReason}`, { userId });
                throw new HttpsError("aborted", `AI content generation was blocked: ${response.promptFeedback.blockReason}.`);
            }

            if (!response.candidates?.length || !response.candidates[0].content?.parts?.length) {
                throw new HttpsError("internal", "AI service returned an unexpected or empty response.");
            }

            const responseText = response.text();
            logger.info(`Gemini API call successful. Response length: ${responseText.length}`, { userId });
            return responseText;

        } catch (error: any) {
            retryCount++;

            const isOverloadError = error.message?.includes('503') || error.message?.includes('overloaded');
            const isQuotaError = error.message?.includes('429') || error.message?.includes('quota') || error.message?.includes('Quota exceeded');
            const isModelNotFound = error.message?.includes('404') || error.message?.includes('not found');

            // Mark model as quota exceeded if we hit quota limits
            if (isQuotaError) {
                markModelAsQuotaExceeded(currentModel);
                logger.warn(`Quota exceeded for model: ${currentModel}`, { userId });
            }

            // Handle model not found error
            if (isModelNotFound) {
                logger.error(`Model not found: ${currentModel}`, { userId, errorMessage: error.message });
                markModelAsQuotaExceeded(currentModel); // Treat as unavailable
            }

            // Try switching model if primary has issues and we haven't switched yet
            if ((isOverloadError || isQuotaError || isModelNotFound) && currentModel === GEMINI_MODELS.primary && !hasSwitchedModel) {
                const switched = switchToFallbackModel();
                if (switched) {
                    localGeminiModel = geminiModel!;
                    hasSwitchedModel = true;
                    retryCount = 0; // Reset retry count for fallback model
                    logger.info(`Retrying with fallback model after ${isQuotaError ? 'quota limit' : isModelNotFound ? 'model not found' : 'overload'}`, { userId });
                    continue;
                }
            }

            // Retry on overload errors (but not quota or model not found errors)
            if (isOverloadError && retryCount <= maxRetries) {
                const delay = baseDelay * Math.pow(2, retryCount - 1);
                logger.warn(`Gemini API overloaded, retrying in ${delay}ms`, {
                    userId,
                    nextRetryInMs: delay,
                    currentModel
                });
                await new Promise(resolve => setTimeout(resolve, delay));
                continue;
            }

            logger.error(`Gemini API error after ${retryCount} attempts:`, {
                userId,
                errorMessage: error.message,
                currentModel,
                finalAttempt: retryCount > maxRetries,
                hasSwitchedModel,
                isQuotaError,
                isModelNotFound
            });

            // Convert specific errors to user-friendly messages
            if (isQuotaError) {
                throw new HttpsError("resource-exhausted", "Our AI service has reached its daily limit. Please try again tomorrow.");
            } else if (isModelNotFound) {
                throw new HttpsError("internal", "AI service configuration error. Please contact support.");
            } else if (isOverloadError) {
                throw new HttpsError("unavailable", "Our AI service is currently experiencing high demand. Please try again in a few minutes.");
            } else if (error.message?.includes('API_KEY_INVALID')) {
                throw new HttpsError("internal", "AI service configuration error. Please contact support.");
            }

            throw error;
        }
    }

    throw new HttpsError("internal", "Unable to generate workout routine at this time. Please try again later.");
}

export function getCurrentModel(): string {
    return currentModel;
}

export function getQuotaExceededModels(): string[] {
    return Array.from(quotaExceededModels);
}
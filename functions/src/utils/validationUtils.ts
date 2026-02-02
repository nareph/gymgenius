import { logger } from "firebase-functions/v2";
import { AiExercise, AiGeneratedRoutineParts } from "../types";

const DAYS_OF_WEEK = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"];

export function validateAndNormalizeRoutine(
    parsedRoutine: any,
    userId: string
): AiGeneratedRoutineParts {
    if (
        typeof parsedRoutine.name !== "string" || !parsedRoutine.name.trim() ||
        typeof parsedRoutine.durationInWeeks !== "number" || parsedRoutine.durationInWeeks <= 0 ||
        typeof parsedRoutine.dailyWorkouts !== "object" || parsedRoutine.dailyWorkouts === null
    ) {
        logger.error("Parsed routine has invalid top-level structure:", { userId, parsedRoutine });
        throw new Error("AI generated invalid structure (name, duration, or dailyWorkouts).");
    }

    const normalizedDailyWorkouts: { [day: string]: AiExercise[] } = {};

    // Normalize all days
    for (const day of DAYS_OF_WEEK) {
        const lowerCaseDay = day.toLowerCase();
        normalizedDailyWorkouts[lowerCaseDay] = normalizeDayExercises(
            parsedRoutine.dailyWorkouts,
            lowerCaseDay,
            day,
            userId
        );
    }

    parsedRoutine.dailyWorkouts = normalizedDailyWorkouts;

    // Validate and normalize each exercise
    for (const day of DAYS_OF_WEEK) {
        if (!Array.isArray(parsedRoutine.dailyWorkouts[day])) {
            logger.error(`Normalized exercises for day '${day}' is still not an array.`, { userId });
            parsedRoutine.dailyWorkouts[day] = [];
        }

        parsedRoutine.dailyWorkouts[day] = parsedRoutine.dailyWorkouts[day].map((exercise: AiExercise) =>
            validateAndNormalizeExercise(exercise, day, userId)
        );
    }

    return parsedRoutine as AiGeneratedRoutineParts;
}

function normalizeDayExercises(
    dailyWorkouts: any,
    lowerCaseDay: string,
    originalCaseDay: string,
    userId: string
): AiExercise[] {
    if (Object.prototype.hasOwnProperty.call(dailyWorkouts, lowerCaseDay)) {
        if (Array.isArray(dailyWorkouts[lowerCaseDay])) {
            return dailyWorkouts[lowerCaseDay];
        } else {
            logger.warn(`Exercises for day '${lowerCaseDay}' is not an array, defaulting to empty.`, {
                userId,
                dayData: dailyWorkouts[lowerCaseDay]
            });
            return [];
        }
    } else if (Object.prototype.hasOwnProperty.call(dailyWorkouts, originalCaseDay)) {
        if (Array.isArray(dailyWorkouts[originalCaseDay])) {
            return dailyWorkouts[originalCaseDay];
        } else {
            logger.warn(`Exercises for day '${originalCaseDay}' is not an array, defaulting to empty for '${lowerCaseDay}'.`, {
                userId,
                dayData: dailyWorkouts[originalCaseDay]
            });
            return [];
        }
    }
    return [];
}

function validateAndNormalizeExercise(
    exercise: AiExercise,
    day: string,
    userId: string
): AiExercise {
    if (
        typeof exercise.name !== "string" || !exercise.name.trim() ||
        typeof exercise.sets !== "number" || exercise.sets <= 0 ||
        typeof exercise.reps !== "string" || !exercise.reps.trim() ||
        typeof exercise.description !== "string"
    ) {
        logger.error(`Invalid exercise structure for '${exercise.name || "Unnamed Exercise"}' on day '${day}':`, {
            userId,
            exerciseDetails: exercise
        });

        // Apply defaults for invalid exercises
        return applyExerciseDefaults(exercise);
    }

    // Normalize valid exercise
    exercise.description = exercise.description.trim();
    if (!exercise.description) {
        exercise.description = "**Target: Multiple muscle groups | Split: Training Day**\n\nHow to perform: Detailed instructions will be available soon.";
    }

    // Validate muscle split format in description
    if (!exercise.description.includes("**Target:") || !exercise.description.includes("Split:")) {
        logger.warn(`Exercise '${exercise.name}' on day '${day}' missing proper muscle split format in description.`);
        if (!exercise.description.includes("**Target:")) {
            exercise.description = "**Target: Multiple muscle groups | Split: Training Day**\n\n" + exercise.description;
        }
    }

    // Normalize other properties
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

    return exercise;
}

function applyExerciseDefaults(exercise: AiExercise): AiExercise {
    return {
        name: exercise.name || "Unnamed Exercise",
        sets: exercise.sets > 0 ? exercise.sets : 3,
        reps: exercise.reps || "8-12",
        weightSuggestionKg: "N/A",
        restBetweenSetsSeconds: 60,
        description: "**Target: Multiple muscle groups | Split: Training Day**\n\nInstructions for this exercise are currently unavailable.",
        usesWeight: false,
        isTimed: false
    };
}

export function validateOnboardingData(onboarding: any): void {
    if (!onboarding || typeof onboarding !== "object" || Object.keys(onboarding).length === 0) {
        throw new Error("Valid 'onboardingData' object is required.");
    }
}
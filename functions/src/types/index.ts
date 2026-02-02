// Re-export all types from workoutTypes for backward compatibility
export * from './workoutTypes';

// Keep the original types that were in the main file
import * as admin from "firebase-admin";

export interface OnboardingData {
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

export interface PreviousRoutineData {
    id?: string;
    name?: string;
    durationInWeeks?: number;
    dailyWorkouts?: { [day: string]: Array<{ [key: string]: any }>; };
    generatedAt?: string | number | admin.firestore.Timestamp;
    expiresAt?: string | number | admin.firestore.Timestamp;
}

export interface AiRoutineRequestPayload {
    onboardingData: OnboardingData;
    previousRoutineData?: PreviousRoutineData;
}

export interface AiExercise {
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

export interface AiGeneratedRoutineParts {
    name: string;
    durationInWeeks: number;
    dailyWorkouts: { [day: string]: AiExercise[]; };
}

export interface MuscleSplit {
    name: string;
    muscles: string[];
    theme: string;
}

export interface AggregatedPerformanceData {
    exerciseName: string;
    averageReps?: number;
    maxWeightLiftedKg?: number;
    completedRate?: number;
    targetReps?: string;
    targetWeight?: string;
}
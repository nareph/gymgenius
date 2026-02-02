import * as admin from "firebase-admin";

// Exercise-related types
export interface ExerciseSet {
    setNumber: number;
    targetReps: string;
    targetWeight?: string;
    performedReps?: string;
    performedWeightKg?: string;
    isCompleted?: boolean;
}

export interface LoggedExercise {
    exerciseId?: string;
    exerciseName: string;
    targetReps: string;
    targetWeight?: string;
    sets: number;
    loggedSets: ExerciseSet[];
    isCompleted: boolean;
    restBetweenSetsSeconds?: number;
    usesWeight?: boolean;
    isTimed?: boolean;
    targetDurationSeconds?: number;
}

export interface WorkoutLog {
    id?: string;
    userId: string;
    routineId: string;
    workoutDay: string;
    startTime: string | admin.firestore.Timestamp;
    endTime?: string | admin.firestore.Timestamp;
    exercises: LoggedExercise[];
    totalDurationMinutes?: number;
    notes?: string;
    completed: boolean;
    createdAt?: string | admin.firestore.Timestamp;
    updatedAt?: string | admin.firestore.Timestamp;
}

// Routine-related types
export interface RoutineExercise {
    id?: string;
    name: string;
    sets: number;
    reps: string;
    weightSuggestionKg?: string;
    restBetweenSetsSeconds?: number;
    description: string;
    usesWeight?: boolean;
    isTimed?: boolean;
    targetDurationSeconds?: number;
    order?: number;
}

export interface DailyWorkout {
    day: string;
    exercises: RoutineExercise[];
    theme?: string;
    focusMuscles?: string[];
}

export interface WorkoutRoutine {
    id?: string;
    userId: string;
    name: string;
    description?: string;
    durationInWeeks: number;
    dailyWorkouts: { [day: string]: RoutineExercise[] };
    experienceLevel: 'beginner' | 'intermediate' | 'advanced' | 'expert';
    goal: string;
    equipment: string[];
    focusAreas?: string[];
    isActive: boolean;
    generatedAt: string | admin.firestore.Timestamp;
    expiresAt: string | admin.firestore.Timestamp;
    previousRoutineId?: string;
    version: number;
    createdAt?: string | admin.firestore.Timestamp;
    updatedAt?: string | admin.firestore.Timestamp;
}

// Progress tracking types
export interface UserProgress {
    userId: string;
    currentRoutineId?: string;
    currentWeek: number;
    currentDay: string;
    totalWorkoutsCompleted: number;
    streak: number;
    lastWorkoutDate?: string | admin.firestore.Timestamp;
    weightHistory?: WeightEntry[];
    measurements?: BodyMeasurements;
    goals?: FitnessGoal[];
    createdAt?: string | admin.firestore.Timestamp;
    updatedAt?: string | admin.firestore.Timestamp;
}

export interface WeightEntry {
    date: string | admin.firestore.Timestamp;
    weightKg: number;
    notes?: string;
}

export interface BodyMeasurements {
    date: string | admin.firestore.Timestamp;
    chestCm?: number;
    waistCm?: number;
    hipsCm?: number;
    armsCm?: number;
    thighsCm?: number;
    calvesCm?: number;
}

export interface FitnessGoal {
    id: string;
    type: 'weight' | 'strength' | 'endurance' | 'measurements' | 'performance';
    target: string;
    current: string;
    deadline?: string | admin.firestore.Timestamp;
    isAchieved: boolean;
    createdAt: string | admin.firestore.Timestamp;
}

// Analytics types
export interface ExercisePerformance {
    exerciseName: string;
    routineId: string;
    bestSet: {
        reps: number;
        weightKg?: number;
        date: string | admin.firestore.Timestamp;
    };
    averageReps: number;
    averageWeightKg?: number;
    completionRate: number;
    totalSessions: number;
    progression: PerformanceProgression[];
}

export interface PerformanceProgression {
    date: string | admin.firestore.Timestamp;
    reps: number;
    weightKg?: number;
    notes?: string;
}

export interface WorkoutAnalytics {
    userId: string;
    period: 'week' | 'month' | 'quarter' | 'year';
    totalWorkouts: number;
    totalDurationMinutes: number;
    averageDurationMinutes: number;
    completionRate: number;
    mostFrequentExercises: string[];
    strengthProgress: StrengthProgress[];
    consistencyScore: number;
    generatedAt: string | admin.firestore.Timestamp;
}

export interface StrengthProgress {
    exerciseName: string;
    improvement: number; // percentage
    period: string;
}

// Template types for future use
export interface ExerciseTemplate {
    id: string;
    name: string;
    primaryMuscles: string[];
    secondaryMuscles: string[];
    equipment: string[];
    difficulty: 'beginner' | 'intermediate' | 'advanced';
    type: 'compound' | 'isolation' | 'cardio' | 'flexibility';
    instructions: string[];
    videoUrl?: string;
    imageUrl?: string;
    commonVariations?: string[];
    isBodyweight: boolean;
    createdAt: string | admin.firestore.Timestamp;
    updatedAt?: string | admin.firestore.Timestamp;
}

export interface WorkoutTemplate {
    id: string;
    name: string;
    description: string;
    durationWeeks: number;
    experienceLevel: 'beginner' | 'intermediate' | 'advanced';
    goal: string;
    dailyWorkouts: DailyWorkout[];
    equipment: string[];
    tags: string[];
    isPublic: boolean;
    createdBy: string;
    popularity: number;
    rating: number;
    createdAt: string | admin.firestore.Timestamp;
    updatedAt?: string | admin.firestore.Timestamp;
}
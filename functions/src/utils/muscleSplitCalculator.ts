import { MuscleSplit } from "../types";

export function determineMuscleSplit(workoutDaysCount: number, experience: string): MuscleSplit[] {
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
    return MUSCLE_SPLITS["3_day"];
}

export function calculateWorkoutDays(
    frequency: string | undefined,
    preferredDays: string[] | undefined
): { actualWorkoutDaysCount: number; useSpecifiedDays: boolean } {
    let actualWorkoutDaysCount = 0;
    let useSpecifiedDays = false;
    const DAYS_OF_WEEK = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"];
    const preferredDaysSelected = preferredDays && preferredDays.length > 0;

    if (frequency) {
        const freqParts = frequency.split("-").map(Number);
        const minFreq = freqParts[0] || 1;
        const maxFreq = freqParts.length > 1 ? (freqParts[1] || minFreq) : minFreq;

        if (preferredDaysSelected && preferredDays) {
            const numSelectedDays = preferredDays.length;
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
        actualWorkoutDaysCount = preferredDaysSelected && preferredDays ? preferredDays.length : 3;
        actualWorkoutDaysCount = Math.min(actualWorkoutDaysCount, DAYS_OF_WEEK.length);
        if (preferredDaysSelected) useSpecifiedDays = true;
    }

    actualWorkoutDaysCount = Math.max(1, actualWorkoutDaysCount);
    return { actualWorkoutDaysCount, useSpecifiedDays };
}
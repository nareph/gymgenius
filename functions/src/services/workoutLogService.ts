import { logger } from "firebase-functions/v2";
import { AggregatedPerformanceData, PreviousRoutineData } from "../types";
import { firestoreService } from "./firestoreService";

import * as admin from "firebase-admin";

export async function getAggregatedPerformanceData(
    userId: string,
    previousRoutine: PreviousRoutineData
): Promise<AggregatedPerformanceData[]> {
    if (!previousRoutine?.id) return [];

    logger.info(`Previous routine ID found: ${previousRoutine.id}. Fetching workout logs for user ${userId}.`);

    try {
        const filters: { field: string; operator: admin.firestore.WhereFilterOp; value: any }[] = [
            { field: "userId", operator: "==", value: userId },
            { field: "routineId", operator: "==", value: previousRoutine.id }
        ];

        // Apply date filtering if expiresAt exists
        if (previousRoutine.expiresAt) {
            const expiryDate = safeConvertToDate(previousRoutine.expiresAt);
            if (expiryDate && !isNaN(expiryDate.getTime())) {
                const twoWeeksBeforeExpiry = new Date(expiryDate.getTime() - (14 * 24 * 60 * 60 * 1000));
                filters.push({
                    field: "startTime",
                    operator: ">=",
                    value: twoWeeksBeforeExpiry.toISOString()
                });
                logger.info(`Log query will filter logs starting from or after: ${twoWeeksBeforeExpiry.toISOString()}`);
            }
        }

        const logsSnapshot = await firestoreService.getDocuments(
            "workout_logs",
            filters,
            { field: "startTime", direction: "desc" },
            30
        );

        return processWorkoutLogs(logsSnapshot);

    } catch (error) {
        logger.error("Error fetching or processing workout logs:", error);
        return [];
    }
}

function safeConvertToDate(timestamp: any): Date | null {
    try {
        if (timestamp && typeof timestamp === 'object' && 'toDate' in timestamp) {
            return (timestamp as any).toDate();
        } else if (typeof timestamp === 'string') {
            return new Date(timestamp);
        } else if (typeof timestamp === 'number') {
            return new Date(timestamp);
        }
        return new Date(String(timestamp));
    } catch {
        return null;
    }
}

function processWorkoutLogs(logsSnapshot: admin.firestore.QuerySnapshot): AggregatedPerformanceData[] {
    if (logsSnapshot.empty) {
        logger.info("No workout logs found for the relevant period.");
        return [];
    }

    logger.info(`Found ${logsSnapshot.docs.length} workout logs for processing.`);
    const performanceByExercise: {
        [key: string]: {
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

                processExerciseSets(loggedExercise, performanceByExercise[key]);
            }
        }
    }

    return aggregatePerformanceData(performanceByExercise);
}

function processExerciseSets(loggedExercise: any, performanceData: any) {
    if (loggedExercise.loggedSets && Array.isArray(loggedExercise.loggedSets)) {
        for (const set of loggedExercise.loggedSets) {
            const repsPerformed = parseInt(set.performedReps as string, 10);
            if (!isNaN(repsPerformed)) performanceData.reps.push(repsPerformed);

            const weightString = set.performedWeightKg as string;
            if (weightString && weightString.toLowerCase() !== "n/a" && weightString.toLowerCase() !== "bodyweight") {
                const weightKg = parseFloat(weightString);
                if (!isNaN(weightKg) && weightKg > 0) performanceData.weights.push(weightKg);
            }
        }
    }
}

function aggregatePerformanceData(performanceByExercise: any): AggregatedPerformanceData[] {
    const aggregatedData: AggregatedPerformanceData[] = [];

    for (const key in performanceByExercise) {
        const data = performanceByExercise[key];
        const avgReps = data.reps.length > 0 ? data.reps.reduce((a: number, b: number) => a + b, 0) / data.reps.length : undefined;
        const maxWeight = data.weights.length > 0 ? Math.max(...data.weights) : undefined;
        const completionRate = data.sessionCount > 0 ? (data.completionCount / data.sessionCount) * 100 : undefined;

        aggregatedData.push({
            exerciseName: data.name,
            averageReps: avgReps ? parseFloat(avgReps.toFixed(1)) : undefined,
            maxWeightLiftedKg: maxWeight,
            completedRate: completionRate ? parseFloat(completionRate.toFixed(0)) : undefined,
            targetReps: data.targetReps,
            targetWeight: data.targetWeight,
        });
    }

    logger.info("Aggregated performance summary:", aggregatedData);
    return aggregatedData;
}

export async function cleanupPreviousRoutineData(userId: string, previousRoutineId: string): Promise<void> {
    try {
        logger.info(`Starting cleanup of previous routine data for: ${previousRoutineId}`, { userId });

        const logsSnapshot = await firestoreService.getDocuments(
            "workout_logs",
            [
                { field: "userId", operator: "==", value: userId },
                { field: "routineId", operator: "==", value: previousRoutineId }
            ]
        );

        if (!logsSnapshot.empty) {
            const docIds = logsSnapshot.docs.map(doc => doc.id);
            await firestoreService.batchDeleteDocuments("workout_logs", docIds);
            logger.info(`Successfully deleted ${docIds.length} workout logs for previous routine`, { userId });
        } else {
            logger.info("No workout logs found to delete", { userId });
        }

    } catch (cleanupError: any) {
        logger.error("Cleanup of previous routine data failed, but continuing:", {
            userId,
            previousRoutineId,
            error: cleanupError.message
        });
    }
}
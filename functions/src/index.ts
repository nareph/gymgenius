// Main exports file
import * as admin from "firebase-admin";

admin.initializeApp();

// Export all callable functions
export { generateAiRoutine } from "./callableFunctions/generateAiRoutine";



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymgenius/services/logger_service.dart';
import 'package:gymgenius/services/offline_workout_service.dart';

enum SaveResult { successOnline, successOffline, failure }

class WorkoutRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final OfflineWorkoutService _offlineService;

  WorkoutRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    OfflineWorkoutService? offlineService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _offlineService = offlineService ?? OfflineWorkoutService();

  /// Saves a completed workout log.
  ///
  /// It first checks for an internet connection. If online, it attempts to save
  /// to Firestore. If that fails, or if initially offline, it saves the log
  /// locally for later synchronization.
  /// Returns a [SaveResult] to indicate how the data was saved.
  Future<SaveResult> saveWorkoutLog(Map<String, dynamic> workoutLog) async {
    final user = _auth.currentUser;
    if (user == null) {
      Log.error(
          "WorkoutRepository: Cannot save log, user is not authenticated.");
      return SaveResult.failure;
    }

    // Add user-specific data to the payload.
    final payload = Map<String, dynamic>.from(workoutLog);
    payload['userId'] = user.uid;

    final isOnline = await _offlineService.isOnline();

    if (isOnline) {
      try {
        payload['savedAt'] = FieldValue.serverTimestamp();
        await _firestore.collection('workout_logs').add(payload);
        Log.debug("WorkoutRepository: Log successfully saved to Firestore.");

        // As a bonus, try to sync any pending workouts now that we're online.
        await _offlineService.syncPendingWorkouts();

        return SaveResult.successOnline;
      } catch (e, s) {
        Log.error(
            "WorkoutRepository: Firestore save failed, falling back to local.",
            error: e,
            stackTrace: s);
        // Fallback to local storage on Firestore error.
        await _offlineService.saveWorkoutLocally(payload);
        return SaveResult.successOffline;
      }
    } else {
      // If offline, save directly to local storage.
      Log.debug("WorkoutRepository: Device is offline, saving log locally.");
      await _offlineService.saveWorkoutLocally(payload);
      return SaveResult.successOffline;
    }
  }
}

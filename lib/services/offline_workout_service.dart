// services/offline_workout_service.dart
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymgenius/providers/workout_session_manager.dart';
import 'package:gymgenius/screens/active_workout_session_screen.dart';
import 'package:gymgenius/services/logger_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineWorkoutService {
  static const String _pendingWorkoutsKey = 'pending_workout_logs';
  static bool _isSyncing = false;
  static const Duration _syncingTimeout = Duration(minutes: 5);

  Future<bool> isOnline() async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      return connectivityResults
          .any((result) => result != ConnectivityResult.none);
    } catch (e) {
      Log.error('Error checking connectivity: $e');
      return false;
    }
  }

  Future<void> recoverStuckWorkouts() async {
    Log.debug("Checking for stuck workouts in 'syncing' state");

    final pendingWorkouts = await getPendingWorkouts();
    bool hasChanges = false;
    final now = DateTime.now();

    for (final workout in pendingWorkouts) {
      if (workout['syncStatus'] == 'syncing') {
        final syncingStartedAt = workout['syncingStartedAt'] as String?;

        if (syncingStartedAt != null) {
          try {
            final startedTime = DateTime.parse(syncingStartedAt);
            final timeDiff = now.difference(startedTime);

            if (timeDiff > _syncingTimeout) {
              Log.debug(
                  'Recovering stuck workout ${workout['localId']} (stuck for ${timeDiff.inMinutes} minutes)');
              workout['syncStatus'] = 'pending';
              workout.remove('syncingStartedAt');
              hasChanges = true;
            }
          } catch (e) {
            Log.error(
                'Error parsing syncingStartedAt for workout ${workout['localId']}: $e');
            workout['syncStatus'] = 'pending';
            workout.remove('syncingStartedAt');
            hasChanges = true;
          }
        } else {
          Log.debug(
              'No syncingStartedAt timestamp for workout ${workout['localId']}, marking as pending');
          workout['syncStatus'] = 'pending';
          hasChanges = true;
        }
      }
    }

    if (hasChanges) {
      await _updatePendingWorkouts(pendingWorkouts);
      Log.debug('Recovered stuck workouts, sync should be triggered soon.');
    }
  }

  // Helper method to sanitize data for JSON storage (convert Timestamps to strings)
  Map<String, dynamic> _sanitizeForLocal(Map<String, dynamic> data) {
    Map<String, dynamic> sanitized = {};

    data.forEach((key, value) {
      if (value is Timestamp) {
        sanitized[key] = value.toDate().toIso8601String();
      } else if (value is FieldValue) {
        return;
      } else if (value is List) {
        sanitized[key] = value.map((item) {
          if (item is Map<String, dynamic>) {
            return _sanitizeForLocal(item);
          } else if (item is Timestamp) {
            return item.toDate().toIso8601String();
          }
          return item;
        }).toList();
      } else if (value is Map<String, dynamic>) {
        sanitized[key] = _sanitizeForLocal(value);
      } else {
        sanitized[key] = value;
      }
    });

    return sanitized;
  }

  // Helper method to prepare data for Firestore
  Map<String, dynamic> _prepareForFirestore(Map<String, dynamic> data) {
    Map<String, dynamic> prepared = {};

    data.forEach((key, value) {
      if (value is String && _isIso8601String(value)) {
        try {
          prepared[key] = DateTime.parse(value);
        } catch (e) {
          prepared[key] = value;
        }
      } else if (value is List) {
        prepared[key] = value.map((item) {
          if (item is Map<String, dynamic>) {
            return _prepareForFirestore(item);
          } else if (item is String && _isIso8601String(item)) {
            try {
              return DateTime.parse(item);
            } catch (e) {
              return item;
            }
          }
          return item;
        }).toList();
      } else if (value is Map<String, dynamic>) {
        prepared[key] = _prepareForFirestore(value);
      } else {
        prepared[key] = value;
      }
    });

    return prepared;
  }

  bool _isIso8601String(String value) {
    try {
      DateTime.parse(value);
      return RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}').hasMatch(value);
    } catch (e) {
      return false;
    }
  }

  Future<void> saveWorkoutLocally(Map<String, dynamic> workoutData) async {
    final prefs = await SharedPreferences.getInstance();
    final existingLogs = await getPendingWorkouts();

    final sanitizedData = _sanitizeForLocal(workoutData);

    sanitizedData['localId'] = DateTime.now().millisecondsSinceEpoch.toString();
    sanitizedData['createdAt'] = DateTime.now().toIso8601String();
    sanitizedData['syncStatus'] = 'pending';

    existingLogs.add(sanitizedData);

    try {
      await prefs.setString(_pendingWorkoutsKey, jsonEncode(existingLogs));
      Log.debug('Workout saved locally with ID: ${sanitizedData['localId']}');
    } catch (e) {
      Log.error('Error saving workout locally: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPendingWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final logsJson = prefs.getString(_pendingWorkoutsKey);

    if (logsJson == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(logsJson);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      Log.error('Error decoding pending workouts: $e');
      return [];
    }
  }

  Future<void> syncPendingWorkouts() async {
    if (_isSyncing) {
      Log.debug("Sync already in progress, skipping");
      return;
    }

    _isSyncing = true;

    try {
      await recoverStuckWorkouts();

      await _performSync();
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _performSync() async {
    Log.debug("Starting syncPendingWorkouts");

    final isConnected = await isOnline();
    if (!isConnected) {
      Log.debug("Aborting sync - no internet connection");
      return;
    }

    final pendingWorkouts = await getPendingWorkouts();
    final User? currentUser = FirebaseAuth.instance.currentUser;

    Log.debug("Found ${pendingWorkouts.length} total workouts");
    final pendingCount =
        pendingWorkouts.where((w) => w['syncStatus'] == 'pending').length;
    Log.debug("Found $pendingCount pending workouts");

    if (currentUser == null || pendingCount == 0) {
      Log.debug("No user or no pending workouts");
      return;
    }

    List<Map<String, dynamic>> successfullySynced = [];
    List<Map<String, dynamic>> workoutsCopy =
        List<Map<String, dynamic>>.from(pendingWorkouts);

    for (final workout in workoutsCopy) {
      if (workout['syncStatus'] != 'pending') continue;

      try {
        Log.debug('Attempting to sync workout ${workout['localId']}');

        workout['syncStatus'] = 'syncing';
        workout['syncingStartedAt'] = DateTime.now().toIso8601String();
        await _updatePendingWorkouts(workoutsCopy);

        if (!await isOnline()) {
          workout['syncStatus'] = 'pending';
          workout.remove('syncingStartedAt');
          Log.debug('Lost connection during sync, marking as pending');
          break;
        }

        final firestoreData =
            _prepareForFirestore(Map<String, dynamic>.from(workout));

        // Remove local-only fields
        firestoreData.remove('localId');
        firestoreData.remove('createdAt');
        firestoreData.remove('syncStatus');
        firestoreData.remove('syncingStartedAt');

        // Add Firestore-specific fields
        firestoreData['userId'] = currentUser.uid;
        firestoreData['savedAt'] = FieldValue.serverTimestamp();

        await FirebaseFirestore.instance
            .collection('workout_logs')
            .add(firestoreData)
            .timeout(const Duration(seconds: 15));

        workout['syncStatus'] = 'synced';
        successfullySynced.add(workout);

        Log.debug('Successfully synced workout ${workout['localId']}');
      } catch (e) {
        workout['syncStatus'] = 'failed';
        workout.remove('syncingStartedAt');
        Log.error('Erreur sync workout ${workout['localId']}: $e');
      }
    }

    final remainingWorkouts =
        workoutsCopy.where((w) => w['syncStatus'] != 'synced').toList();
    await _updatePendingWorkouts(remainingWorkouts);

    if (successfullySynced.isNotEmpty) {
      Log.debug('Synced ${successfullySynced.length} workout(s) successfully');
    }
  }

  Future<void> _updatePendingWorkouts(
      List<Map<String, dynamic>> workouts) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setString(_pendingWorkoutsKey, jsonEncode(workouts));
    } catch (e) {
      Log.error('Error updating pending workouts: $e');
      rethrow;
    }
  }

  Future<int> getPendingWorkoutsCount() async {
    final pending = await getPendingWorkouts();
    return pending.where((w) => w['syncStatus'] == 'pending').length;
  }

  Future<int> getSyncingWorkoutsCount() async {
    final pending = await getPendingWorkouts();
    return pending.where((w) => w['syncStatus'] == 'syncing').length;
  }

  Future<int> getFailedWorkoutsCount() async {
    final pending = await getPendingWorkouts();
    return pending.where((w) => w['syncStatus'] == 'failed').length;
  }

  Future<void> forceRecoverStuckWorkouts() async {
    Log.debug("Force recovering all stuck workouts");

    final pendingWorkouts = await getPendingWorkouts();
    bool hasChanges = false;

    for (final workout in pendingWorkouts) {
      if (workout['syncStatus'] == 'syncing') {
        Log.debug('Force recovering workout ${workout['localId']}');
        workout['syncStatus'] = 'pending';
        workout.remove('syncingStartedAt');
        hasChanges = true;
      }
    }

    if (hasChanges) {
      await _updatePendingWorkouts(pendingWorkouts);
      Log.debug('Force recovered stuck workouts');

      await syncPendingWorkouts();
    }
  }

  Future<void> retryFailedWorkouts() async {
    final pendingWorkouts = await getPendingWorkouts();
    bool hasChanges = false;

    for (final workout in pendingWorkouts) {
      if (workout['syncStatus'] == 'failed') {
        workout['syncStatus'] = 'pending';
        hasChanges = true;
      }
    }

    if (hasChanges) {
      await _updatePendingWorkouts(pendingWorkouts);
      await syncPendingWorkouts();
    }
  }

  Future<void> clearPendingWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingWorkoutsKey);
    Log.debug('Cleared all pending workouts');
  }

  Future<Map<String, int>> getSyncStatusBreakdown() async {
    final pending = await getPendingWorkouts();
    return {
      'pending': pending.where((w) => w['syncStatus'] == 'pending').length,
      'syncing': pending.where((w) => w['syncStatus'] == 'syncing').length,
      'failed': pending.where((w) => w['syncStatus'] == 'failed').length,
      'total': pending.length,
    };
  }
}

extension ActiveWorkoutSessionScreenOffline on ActiveWorkoutSessionScreen {
  Future<void> handleEndWorkoutWithOfflineSupport(
      BuildContext context, WorkoutSessionManager manager) async {
    final offlineService = OfflineWorkoutService();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    Map<String, dynamic>? workoutLogPayload = manager.endWorkout();
    if (workoutLogPayload == null) return;

    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showErrorSnackBar(
          scaffoldMessenger, "Error: Not logged in. Workout not saved.");
      return;
    }

    final isOnline = await offlineService.isOnline();

    if (isOnline) {
      try {
        workoutLogPayload['userId'] = currentUser.uid;
        workoutLogPayload['savedAt'] = FieldValue.serverTimestamp();

        await FirebaseFirestore.instance
            .collection('workout_logs')
            .add(workoutLogPayload);

        _showSuccessSnackBar(scaffoldMessenger, "Workout saved successfully!");
        await offlineService.syncPendingWorkouts();
      } catch (e) {
        Log.debug('Error saving to Firestore: $e');
        await offlineService.saveWorkoutLocally(workoutLogPayload);
        _showOfflineSnackBar(scaffoldMessenger,
            "Connection issue. Workout saved locally and will sync when online.");
      }
    } else {
      await offlineService.saveWorkoutLocally(workoutLogPayload);
      _showOfflineSnackBar(scaffoldMessenger,
          "You're offline. Workout saved locally and will sync when online.");
    }
  }

  void _showSuccessSnackBar(ScaffoldMessengerState messenger, String message) {
    if (messenger.context.mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showErrorSnackBar(ScaffoldMessengerState messenger, String message) {
    if (messenger.context.mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(messenger.context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showOfflineSnackBar(ScaffoldMessengerState messenger, String message) {
    if (messenger.context.mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.cloud_off, color: Colors.orange.shade200),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}

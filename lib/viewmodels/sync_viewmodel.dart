// lib/viewmodels/sync_viewmodel.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:gymgenius/services/logger_service.dart';
import 'package:gymgenius/services/offline_workout_service.dart';

/// ViewModel to manage the state and logic for workout synchronization.
class SyncViewModel extends ChangeNotifier {
  final OfflineWorkoutService _offlineService;
  StreamSubscription? _connectivitySubscription;

  bool _isOnline = true;
  int _pendingCount = 0;
  int _syncingCount = 0;
  int _failedCount = 0;
  bool _isSyncing = false;

  // Public getters for the UI
  bool get isOnline => _isOnline;
  int get pendingCount => _pendingCount;
  int get syncingCount => _syncingCount;
  int get failedCount => _failedCount;
  bool get isSyncing => _isSyncing;
  int get totalWorkouts => _pendingCount + _syncingCount + _failedCount;

  SyncViewModel(this._offlineService) {
    Log.debug("SyncViewModel initialized.");
    _initialize();
  }

  Future<void> _initialize() async {
    _checkConnectivity();
    _checkStatus();
    _setupConnectivityListener();
    await _recoverStuckWorkoutsOnStart();
  }
  
  Future<void> _checkConnectivity() async {
     final connectivityResult = await Connectivity().checkConnectivity();
     _isOnline = connectivityResult.any((r) => r != ConnectivityResult.none);
     notifyListeners();
  }

  Future<void> _recoverStuckWorkoutsOnStart() async {
    await Future.delayed(const Duration(seconds: 2));
    await _offlineService.recoverStuckWorkouts();
    await _checkStatus();

    if (_isOnline && (pendingCount > 0 || failedCount > 0)) {
      Log.debug("SyncViewModel: Found pending/failed workouts on start, triggering sync.");
      syncPendingWorkouts();
    }
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) async {
      final newOnlineStatus = results.any((r) => r != ConnectivityResult.none);
      if (newOnlineStatus && !_isOnline) {
        Log.debug("SyncViewModel: Connectivity restored. Checking for workouts to sync.");
        _isOnline = newOnlineStatus;
        await _offlineService.recoverStuckWorkouts();
        await _checkStatus();
        if (totalWorkouts > 0) {
          syncPendingWorkouts();
        }
      }
      _isOnline = newOnlineStatus;
      notifyListeners();
    });
  }

  Future<void> _checkStatus() async {
    _pendingCount = await _offlineService.getPendingWorkoutsCount();
    _syncingCount = await _offlineService.getSyncingWorkoutsCount();
    _failedCount = await _offlineService.getFailedWorkoutsCount();
    notifyListeners();
  }

  Future<String?> syncPendingWorkouts() async {
    if (_isSyncing || !_isOnline) return null;
    Log.debug("SyncViewModel: Starting sync for $totalWorkouts workouts.");
    _isSyncing = true;
    notifyListeners();
    String? resultMessage;
    try {
      await _offlineService.syncPendingWorkouts();
      await _checkStatus();
      if (pendingCount == 0 && syncingCount == 0) {
        resultMessage = "All workouts synced successfully!";
      }
    } catch (e) {
      Log.error("SyncViewModel: Error during sync", error: e);
      resultMessage = "Sync failed: ${e.toString()}";
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
    return resultMessage;
  }
  
  Future<String?> forceRecoverStuckWorkouts() async {
    if (_isSyncing) return null;
    _isSyncing = true;
    notifyListeners();
     String? resultMessage;
    try {
      await _offlineService.forceRecoverStuckWorkouts();
      await _checkStatus();
      resultMessage = "Stuck workouts recovered and sync initiated.";
    } catch(e) {
       resultMessage = "Recovery failed: ${e.toString()}";
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
    return resultMessage;
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
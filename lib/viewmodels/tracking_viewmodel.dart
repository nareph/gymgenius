// lib/viewmodels/tracking_viewmodel.dart - UPDATED
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:gymgenius/models/routine.dart';
import 'package:gymgenius/repositories/tracking_repository.dart';
import 'package:gymgenius/services/database_service.dart';
import 'package:gymgenius/services/logger_service.dart';
import 'package:gymgenius/utils/type_converter.dart';
import 'package:table_calendar/table_calendar.dart';

enum TrackingState { initial, loading, loaded, error }

class TrackingViewModel extends ChangeNotifier {
  final TrackingRepository _repository;
  StreamSubscription? _routineSubscription;
  StreamSubscription? _logsSubscription;

  // Add a flag to track if data has been loaded at least once
  bool _hasLoadedInitialData = false;

  TrackingViewModel(this._repository) {
    Log.info("TrackingViewModel: Created");
    _focusedDay = DateTime.now();
    _selectedDay =
        DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day);
    _loadInitialData();
  }

  // UI State
  TrackingState _state = TrackingState.initial;
  TrackingState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoadingDayDetails = false;
  bool get isLoadingDayDetails => _isLoadingDayDetails;

  // Calendar Data and State
  late DateTime _focusedDay;
  DateTime get focusedDay => _focusedDay;

  late DateTime _selectedDay;
  DateTime get selectedDay => _selectedDay;

  Map<DateTime, List<String>> _plannedEvents = {};
  Map<DateTime, List<String>> get plannedEvents => _plannedEvents;

  Set<DateTime> _completedWorkoutDates = {};
  Set<DateTime> get completedWorkoutDates => _completedWorkoutDates;

  List<Map<String, dynamic>> _selectedDayLogs = [];
  List<Map<String, dynamic>> get selectedDayLogs => _selectedDayLogs;

  Future<void> _loadInitialData() async {
    Log.info("TrackingViewModel: Loading initial data...");
    _setState(TrackingState.loading);

    final userId = DatabaseService.instance.getCurrentUserId();
    Log.info("TrackingViewModel: User ID: $userId");

    if (userId == null) {
      _handleError(Exception('User not authenticated'), StackTrace.current);
      return;
    }

    try {
      // Load data immediately (not just listen for changes)
      await _loadRoutineData(userId);
      await _loadCompletedWorkouts(userId);
      await _loadLogsForDay(_selectedDay);

      // Then set up listeners for future changes
      _setupDataListeners(userId);

      _hasLoadedInitialData = true;
      _setState(TrackingState.loaded);
      Log.info("TrackingViewModel: Initial data loaded successfully");
    } catch (error, stackTrace) {
      _handleError(error, stackTrace);
    }
  }

  Future<void> _loadRoutineData(String userId) async {
    Log.info("TrackingViewModel: Loading routine data...");
    try {
      final routine = DatabaseService.instance.getCurrentRoutine(userId);
      Log.info("TrackingViewModel: Routine found: ${routine != null}");

      if (routine != null && !routine.isExpired()) {
        try {
          // Use TypeConverter for type safety
          final routineMap = routine.toMap();
          final safeRoutineMap = TypeConverter.toSafeMap(routineMap);
          final weeklyRoutine = WeeklyRoutine.fromMap(safeRoutineMap);
          _generatePlannedEventsForRoutine(weeklyRoutine);
          Log.info(
              "TrackingViewModel: Planned events generated: ${_plannedEvents.length}");
        } catch (e, s) {
          Log.error("TrackingViewModel: Failed to parse routine",
              error: e, stackTrace: s);
          _plannedEvents = {};
        }
      } else {
        _plannedEvents = {};
        Log.info("TrackingViewModel: No valid routine found");
      }
      notifyListeners();
    } catch (error, stackTrace) {
      Log.error("TrackingViewModel: Error loading routine data",
          error: error, stackTrace: stackTrace);
      _plannedEvents = {};
      notifyListeners();
    }
  }

  Future<void> _loadCompletedWorkouts(String userId) async {
    Log.info("TrackingViewModel: Loading completed workouts...");
    try {
      final logs = DatabaseService.instance.getUserWorkoutLogs(userId);
      Log.info("TrackingViewModel: Found ${logs.length} workout logs");

      final newCompletedDates = logs.map((log) {
        final date = log.savedAt;
        return DateTime(date.year, date.month, date.day);
      }).toSet();

      _completedWorkoutDates = newCompletedDates;
      Log.info(
          "TrackingViewModel: Completed dates: ${_completedWorkoutDates.length}");
      notifyListeners();
    } catch (error, stackTrace) {
      Log.error("TrackingViewModel: Error loading completed workouts",
          error: error, stackTrace: stackTrace);
      _completedWorkoutDates = {};
      notifyListeners();
    }
  }

  void _setupDataListeners(String userId) {
    Log.info("TrackingViewModel: Setting up data listeners...");

    // Cancel existing subscriptions
    _routineSubscription?.cancel();
    _logsSubscription?.cancel();

    // Listen to routine changes
    _routineSubscription = DatabaseService.instance.watchRoutines().listen((_) {
      Log.info("TrackingViewModel: Routine changed, reloading...");
      _loadRoutineData(userId);
    }, onError: (error) {
      Log.error("TrackingViewModel: Error in routine stream", error: error);
    });

    // Listen to workout logs changes
    _logsSubscription = DatabaseService.instance.watchWorkoutLogs().listen((_) {
      Log.info("TrackingViewModel: Workout logs changed, reloading...");
      _loadCompletedWorkouts(userId);

      // If the selected day's completion status changed, refresh its logs
      if (_completedWorkoutDates.contains(_selectedDay) &&
          _selectedDayLogs.isEmpty) {
        _loadLogsForDay(_selectedDay);
      }
    }, onError: (error) {
      Log.error("TrackingViewModel: Error in logs stream", error: error);
    });
  }

  void _generatePlannedEventsForRoutine(WeeklyRoutine routine) {
    final newEvents = <DateTime, List<String>>{};

    if (routine.durationInWeeks <= 0 || routine.dailyWorkouts.isEmpty) {
      _plannedEvents = newEvents;
      return;
    }

    final startDate = routine.generatedAt;
    final endDate = routine.expiresAt;
    var currentDate = DateTime(startDate.year, startDate.month, startDate.day);

    while (!currentDate.isAfter(endDate)) {
      final dayKey =
          WeeklyRoutine.daysOfWeek[currentDate.weekday - 1].toLowerCase();
      if (routine.dailyWorkouts[dayKey]?.isNotEmpty ?? false) {
        newEvents[
            DateTime(currentDate.year, currentDate.month, currentDate.day)] = [
          'Planned'
        ];
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }

    _plannedEvents = newEvents;
  }

  Future<void> _loadLogsForDay(DateTime day) async {
    Log.info("TrackingViewModel: Loading logs for day: $day");
    _isLoadingDayDetails = true;
    notifyListeners();

    try {
      _selectedDayLogs = await _repository.getLogsForDay(day);
      Log.info(
          "TrackingViewModel: Loaded ${_selectedDayLogs.length} logs for day $day");
    } catch (e, s) {
      Log.error("TrackingViewModel: Failed to load logs for day $day",
          error: e, stackTrace: s);
      _selectedDayLogs = [];
    } finally {
      _isLoadingDayDetails = false;
      notifyListeners();
    }
  }

  void selectDay(DateTime day, {DateTime? focusedDay}) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    Log.info("TrackingViewModel: Selecting day: $normalizedDay");

    if (!isSameDay(_selectedDay, normalizedDay)) {
      _selectedDay = normalizedDay;
      _focusedDay = focusedDay ?? normalizedDay;
      _selectedDayLogs = []; // Clear immediately for better UX
      _loadLogsForDay(normalizedDay);
      notifyListeners();
    }
  }

  void changeFocusedDay(DateTime day) {
    _focusedDay = day;
    notifyListeners();
  }

  List<String> getEventsForDay(DateTime day) {
    final dateOnly = DateTime(day.year, day.month, day.day);
    if (_completedWorkoutDates.contains(dateOnly)) return ['Completed'];
    if (_plannedEvents[dateOnly]?.isNotEmpty ?? false) return ['Planned'];
    return [];
  }

  void _handleError(Object error, StackTrace stack) {
    Log.error("TrackingViewModel Error", error: error, stackTrace: stack);
    _errorMessage = "Failed to load tracking data.";
    _setState(TrackingState.error);
  }

  void _setState(TrackingState newState) {
    Log.info("TrackingViewModel: State changing from $_state to $newState");
    _state = newState;
    notifyListeners();
  }

  // Add a method to manually refresh data
  Future<void> refresh() async {
    Log.info("TrackingViewModel: Manual refresh requested");
    final userId = DatabaseService.instance.getCurrentUserId();
    if (userId != null) {
      await _loadInitialData();
    }
  }

  @override
  void dispose() {
    Log.info("TrackingViewModel: Disposing");
    _routineSubscription?.cancel();
    _logsSubscription?.cancel();
    super.dispose();
  }
}

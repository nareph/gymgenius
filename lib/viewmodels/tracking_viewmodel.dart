import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:gymgenius/models/hive/training_program_model.dart';
import 'package:gymgenius/models/workout_log.dart';
import 'package:gymgenius/repositories/tracking_repository.dart';
import 'package:gymgenius/services/database_service.dart';
import 'package:gymgenius/services/logger_service.dart';
import 'package:table_calendar/table_calendar.dart';

enum TrackingState { initial, loading, loaded, error }

class TrackingViewModel extends ChangeNotifier {
  final TrackingRepository _repository;
  StreamSubscription? _programSubscription;
  StreamSubscription? _logsSubscription;

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

  List<WorkoutLog> _selectedDayLogs = [];
  List<WorkoutLog> get selectedDayLogs => _selectedDayLogs;

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
      await _loadProgramData(userId);
      await _loadCompletedWorkouts(userId);
      await _loadLogsForDay(_selectedDay);

      _setupDataListeners(userId);

      _setState(TrackingState.loaded);
      Log.info("TrackingViewModel: Initial data loaded successfully");
    } catch (error, stackTrace) {
      _handleError(error, stackTrace);
    }
  }

  Future<void> _loadProgramData(String userId) async {
    Log.info("TrackingViewModel: Loading program data...");
    try {
      final program = DatabaseService.instance.getCurrentProgram(userId);
      Log.info("TrackingViewModel: Program found: ${program != null}");

      if (program != null && !program.isExpired()) {
        try {
          _generatePlannedEventsForProgram(program);
          Log.info(
              "TrackingViewModel: Planned events generated: ${_plannedEvents.length}");
        } catch (e, s) {
          Log.error("TrackingViewModel: Failed to parse program",
              error: e, stackTrace: s);
          _plannedEvents = {};
        }
      } else {
        _plannedEvents = {};
        Log.info("TrackingViewModel: No valid program found");
      }
      notifyListeners();
    } catch (error, stackTrace) {
      Log.error("TrackingViewModel: Error loading program data",
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

    _programSubscription?.cancel();
    _logsSubscription?.cancel();

    _programSubscription = DatabaseService.instance.watchPrograms().listen((_) {
      Log.info("TrackingViewModel: Program changed, reloading...");
      _loadProgramData(userId);
    }, onError: (error) {
      Log.error("TrackingViewModel: Error in program stream", error: error);
    });

    _logsSubscription = DatabaseService.instance.watchWorkoutLogs().listen((_) {
      Log.info("TrackingViewModel: Workout logs changed, reloading...");
      _loadCompletedWorkouts(userId);
      if (_completedWorkoutDates.contains(_selectedDay) &&
          _selectedDayLogs.isEmpty) {
        _loadLogsForDay(_selectedDay);
      }
    }, onError: (error) {
      Log.error("TrackingViewModel: Error in logs stream", error: error);
    });
  }

  /// Generate planned events from the Training Program's weekly schedule.
  void _generatePlannedEventsForProgram(TrainingProgramModel program) {
    final newEvents = <DateTime, List<String>>{};

    if (program.durationInWeeks <= 0 || program.weeklySchedule.isEmpty) {
      _plannedEvents = newEvents;
      return;
    }

    final startDate = program.generatedAt;
    final endDate = program.expiresAt;
    var currentDate = DateTime(startDate.year, startDate.month, startDate.day);

    final daysOfWeek = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];

    while (!currentDate.isAfter(endDate)) {
      final dayKey = daysOfWeek[currentDate.weekday - 1];
      final exercises = program.weeklySchedule[dayKey];
      if (exercises is List && exercises.isNotEmpty) {
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
      _selectedDayLogs = [];
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
    _programSubscription?.cancel();
    _logsSubscription?.cancel();
    super.dispose();
  }
}

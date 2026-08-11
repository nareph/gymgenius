// lib/presentation/viewmodels/tracking_viewmodel.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:gymgenius/core/logger/logger_service.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/domain/entities/workout_log.dart';
import 'package:gymgenius/domain/entities/progress_snapshot.dart';
import 'package:gymgenius/domain/entities/weekly_progress_report.dart';
import 'package:gymgenius/domain/enums/progress_period.dart';
import 'package:gymgenius/domain/repositories/progress_repository.dart';
import 'package:gymgenius/domain/repositories/tracking_repository.dart';
import 'package:gymgenius/domain/repositories/user_repository.dart';
import 'package:gymgenius/domain/repositories/workout_repository.dart';
import 'package:table_calendar/table_calendar.dart';

enum TrackingState { initial, loading, loaded, error }

class TrackingViewModel extends ChangeNotifier {
  final WorkoutRepository _workoutRepository;
  final TrackingRepository _trackingRepository;
  final UserRepository _userRepository;
  final ProgressRepository _progressRepository;
  StreamSubscription? _programSubscription;
  StreamSubscription? _logsSubscription;

  TrackingViewModel({
    required WorkoutRepository workoutRepository,
    required TrackingRepository trackingRepository,
    required UserRepository userRepository,
    required ProgressRepository progressRepository,
  })  : _workoutRepository = workoutRepository,
        _trackingRepository = trackingRepository,
        _userRepository = userRepository,
        _progressRepository = progressRepository {
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

  ProgressSnapshot? _progressSnapshot;
  ProgressSnapshot? get progressSnapshot => _progressSnapshot;

  WeeklyProgressReport? _weeklyReport;
  WeeklyProgressReport? get weeklyReport => _weeklyReport;

  bool _isLoadingProgress = false;
  bool get isLoadingProgress => _isLoadingProgress;

  ProgressPeriod _progressPeriod = ProgressPeriod.weekly;
  ProgressPeriod get progressPeriod => _progressPeriod;

  Future<void> _loadInitialData() async {
    Log.info("TrackingViewModel: Loading initial data...");
    _setState(TrackingState.loading);

    try {
      await _loadProgramData();
      await _loadCompletedWorkouts();
      await _loadProgressData();
      await _loadLogsForDay(_selectedDay);
      _setupDataListeners();
      _setState(TrackingState.loaded);
      Log.info("TrackingViewModel: Initial data loaded successfully");
    } catch (error, stackTrace) {
      _handleError(error, stackTrace);
    }
  }

  Future<void> _loadProgramData() async {
    Log.info("TrackingViewModel: Loading program data...");
    try {
      final user = await _userRepository.getCurrentUser();
      if (user == null) {
        _plannedEvents = {};
        return;
      }
      final program = await _workoutRepository.getCurrentProgram(user.id);
      Log.info("TrackingViewModel: Program found: ${program != null}");

      if (program != null && !program.isExpired) {
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

  Future<void> _loadProgressData() async {
    _isLoadingProgress = true;
    notifyListeners();

    try {
      final user = await _userRepository.getCurrentUser();
      if (user == null) {
        _progressSnapshot = null;
        _weeklyReport = null;
        return;
      }

      _progressSnapshot = await _progressRepository.computeSnapshot(
        user.id,
        period: _progressPeriod,
      );
      _weeklyReport = await _progressRepository.computeWeeklyReport(user.id);
    } catch (error, stackTrace) {
      Log.error('TrackingViewModel: Error loading progress',
          error: error, stackTrace: stackTrace);
      _progressSnapshot = null;
      _weeklyReport = null;
    } finally {
      _isLoadingProgress = false;
      notifyListeners();
    }
  }

  Future<void> setProgressPeriod(ProgressPeriod period) async {
    if (_progressPeriod == period) return;
    _progressPeriod = period;
    await _loadProgressData();
  }

  Future<void> _loadCompletedWorkouts() async {
    Log.info("TrackingViewModel: Loading completed workouts...");
    try {
      final user = await _userRepository.getCurrentUser();
      if (user == null) {
        _completedWorkoutDates = {};
        return;
      }
      final logs = await _workoutRepository.getWorkoutLogs(user.id);
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

  void _setupDataListeners() {
    Log.info("TrackingViewModel: Setting up data listeners...");
    _programSubscription?.cancel();
    _logsSubscription?.cancel();

    // For now, we rely on manual refresh.
    // In future, we can add streams to the repositories.
  }

  void _generatePlannedEventsForProgram(TrainingProgram program) {
    final newEvents = <DateTime, List<String>>{};

    if (program.durationWeeks <= 0 || program.weeklySchedule.isEmpty) {
      _plannedEvents = newEvents;
      return;
    }

    final startDate = program.createdAt;
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
      if (exercises!.isNotEmpty) {
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
      _selectedDayLogs = await _trackingRepository.getLogsForDay(day);
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
    await _loadInitialData();
  }

  @override
  void dispose() {
    Log.info("TrackingViewModel: Disposing");
    _programSubscription?.cancel();
    _logsSubscription?.cancel();
    super.dispose();
  }
}

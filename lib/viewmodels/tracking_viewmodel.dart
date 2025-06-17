import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gymgenius/models/routine.dart';
import 'package:gymgenius/repositories/tracking_repository.dart';
import 'package:gymgenius/services/logger_service.dart';
import 'package:table_calendar/table_calendar.dart';

enum TrackingState { initial, loading, loaded, error }

class TrackingViewModel extends ChangeNotifier {
  final TrackingRepository _repository;
  StreamSubscription? _routineSubscription;
  StreamSubscription? _logsSubscription;

  TrackingViewModel(this._repository) {
    _focusedDay = DateTime.now();
    _selectedDay =
        DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day);
    _listenToDataChanges();
    selectDay(_selectedDay); // Load initial day logs
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

  void _listenToDataChanges() {
    _setState(TrackingState.loading);

    // Listen to routine for planned events
    _routineSubscription =
        _repository.getUserDocumentStream()?.listen((snapshot) {
      if (snapshot.exists && snapshot.data()?['currentRoutine'] != null) {
        try {
          final routine =
              WeeklyRoutine.fromMap(snapshot.data()!['currentRoutine']);
          _generatePlannedEventsForRoutine(routine);
        } catch (e, s) {
          Log.error("TrackingViewModel: Failed to parse routine",
              error: e, stackTrace: s);
          _plannedEvents = {};
          notifyListeners();
        }
      } else {
        _plannedEvents = {};
        notifyListeners();
      }
    }, onError: _handleError);

    // Listen to logs for completed events
    _logsSubscription = _repository.getWorkoutLogsStream()?.listen((snapshot) {
      final newCompletedDates = snapshot.docs
          .map((doc) {
            final timestamp = doc.data()['savedAt'] as Timestamp?;
            if (timestamp == null) return null;
            final date = timestamp.toDate();
            return DateTime(date.year, date.month, date.day);
          })
          .whereType<DateTime>()
          .toSet();

      if (!setEquals(_completedWorkoutDates, newCompletedDates)) {
        _completedWorkoutDates = newCompletedDates;
        // If the selected day's completion status changed, refresh its logs
        if (_completedWorkoutDates.contains(_selectedDay) &&
            _selectedDayLogs.isEmpty) {
          _loadLogsForDay(_selectedDay);
        }
        notifyListeners();
      }
      _setState(TrackingState.loaded);
    }, onError: _handleError);
  }

  void _generatePlannedEventsForRoutine(WeeklyRoutine routine) {
    // Same logic as in the original file
    final newEvents = <DateTime, List<String>>{};
    if (routine.durationInWeeks <= 0 || routine.dailyWorkouts.isEmpty) {
      _plannedEvents = newEvents;
      notifyListeners();
      return;
    }
    final startDate = routine.generatedAt.toDate();
    final endDate = routine.expiresAt.toDate();
    var currentDate = DateTime(startDate.year, startDate.month, startDate.day);
    while (!currentDate.isAfter(endDate)) {
      final dayKey =
          WeeklyRoutine.daysOfWeek[currentDate.weekday - 1].toLowerCase();
      if (routine.dailyWorkouts[dayKey]?.isNotEmpty ?? false) {
        newEvents[currentDate] = ['Planned'];
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }
    _plannedEvents = newEvents;
    notifyListeners();
  }

  Future<void> _loadLogsForDay(DateTime day) async {
    _isLoadingDayDetails = true;
    notifyListeners();
    try {
      _selectedDayLogs = await _repository.getLogsForDay(day);
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
    Log.error("TrackingViewModel Stream Error",
        error: error, stackTrace: stack);
    _errorMessage =
        "Failed to load tracking data. Please check your connection.";
    _setState(TrackingState.error);
  }

  void _setState(TrackingState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _routineSubscription?.cancel();
    _logsSubscription?.cancel();
    super.dispose();
  }
}

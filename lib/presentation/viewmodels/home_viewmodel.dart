// lib/presentation/viewmodels/home_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:gymgenius/core/logger/logger_service.dart';
import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/domain/entities/weekly_workout.dart';
import 'package:gymgenius/domain/repositories/health_repository.dart';
import 'package:gymgenius/domain/repositories/user_repository.dart';
import 'package:gymgenius/engines/workout_engine/workout_engine.dart';
import 'package:gymgenius/presentation/widgets/regeneration/regeneration_options_sheet.dart';

enum HomeState { initial, loading, loaded, error }

class HomeViewModel extends ChangeNotifier {
  final WorkoutEngine _workoutEngine;
  final UserRepository _userRepository;
  final HealthRepository _healthRepository;
  BuildContext? _context;

  HomeViewModel({
    required WorkoutEngine workoutEngine,
    required UserRepository userRepository,
    required HealthRepository healthRepository,
  })  : _workoutEngine = workoutEngine,
        _userRepository = userRepository,
        _healthRepository = healthRepository {
    Log.info('HomeViewModel: Created');
    _loadData();
  }

  HomeState _state = HomeState.initial;
  HomeState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isGeneratingProgram = false;
  bool get isGeneratingProgram => _isGeneratingProgram;

  HealthProfile? _healthProfile;
  HealthProfile? get healthProfile => _healthProfile;

  TrainingProgram? _currentProgram;
  TrainingProgram? get currentProgram => _currentProgram;

  WeeklyWorkout? _currentWeeklyWorkout;
  WeeklyWorkout? get currentWeeklyWorkout => _currentWeeklyWorkout;

  bool _isProfileComplete = false;
  bool get isProfileComplete => _isProfileComplete;

  Future<void> _loadData() async {
    Log.info('HomeViewModel: Loading data...');
    _state = HomeState.loading;
    notifyListeners();

    try {
      final user = await _userRepository.getCurrentUser();
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final healthProfile = await _healthRepository.getCurrentProfile();
      _healthProfile = healthProfile;
      _isProfileComplete = healthProfile != null && healthProfile.isComplete;

      final (program, weekly) =
          await _workoutEngine.getCurrentProgramWithWeekly();
      _currentProgram = program;
      _currentWeeklyWorkout = weekly;

      Log.info('HomeViewModel: Profile complete: $_isProfileComplete');
      Log.info('HomeViewModel: Program found: ${_currentProgram != null}');
      Log.info(
          'HomeViewModel: Weekly workout found: ${_currentWeeklyWorkout != null}');

      _state = HomeState.loaded;
      notifyListeners();
    } catch (error, stackTrace) {
      Log.error('HomeViewModel: Error loading data',
          error: error, stackTrace: stackTrace);
      _errorMessage = error.toString();
      _state = HomeState.error;
      notifyListeners();
    }
  }

  Future<void> generateNewProgram() async {
    if (_healthProfile == null || !_healthProfile!.isComplete) {
      _errorMessage = 'Health profile is incomplete.';
      _state = HomeState.error;
      notifyListeners();
      return;
    }

    _isGeneratingProgram = true;
    notifyListeners();

    try {
      await _workoutEngine.generateProgram(
        profile: _healthProfile!,
        previousProgram: _currentProgram,
        options: null,
      );
      await _loadData();
    } catch (e) {
      _errorMessage = 'Failed to generate program: $e';
      _state = HomeState.error;
      notifyListeners();
    } finally {
      _isGeneratingProgram = false;
      notifyListeners();
    }
  }

  Future<void> regenerateProgram(RegenerationOptions options) async {
    if (_healthProfile == null || !_healthProfile!.isComplete) {
      _errorMessage = 'Health profile is incomplete.';
      _state = HomeState.error;
      notifyListeners();
      return;
    }

    _isGeneratingProgram = true;
    notifyListeners();

    try {
      await _workoutEngine.regenerateProgram(
        profile: _healthProfile!,
        previousProgram: _currentProgram!,
        options: options.toMap(),
      );
      await _loadData();

      if (_context != null && _context!.mounted) {
        _showSuccessMessage(_context!, options);
      }
    } catch (e) {
      _errorMessage = 'Failed to regenerate program: $e';
      _state = HomeState.error;
      notifyListeners();
      if (_context != null && _context!.mounted) {
        _showErrorMessage(_context!, e.toString());
      }
    } finally {
      _isGeneratingProgram = false;
      notifyListeners();
    }
  }

  void _showSuccessMessage(BuildContext context, RegenerationOptions options) {
    final message = switch (options.type) {
      RegenerationType.fullProgram =>
        'New training program generated successfully!',
      RegenerationType.specificDay => 'Workout day regenerated successfully!',
      RegenerationType.singleExercise => 'Exercise replaced successfully!',
      RegenerationType.withPreferences => 'Program customized successfully!',
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ $message'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ Failed: $error'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> dismissExpiredProgram() async {
    await _workoutEngine.clearCurrentProgram();
    _currentProgram = null;
    _currentWeeklyWorkout = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    await _loadData();
  }

  void setContext(BuildContext context) {
    _context = context;
  }
}

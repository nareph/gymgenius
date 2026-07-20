import 'package:flutter/material.dart';
import 'package:gymgenius/models/hive/training_program_model.dart';
import 'package:gymgenius/models/hive/weekly_workout_model.dart';
import 'package:gymgenius/models/onboarding.dart';
import 'package:gymgenius/repositories/home_repository.dart';
import 'package:gymgenius/services/logger_service.dart';
import 'package:gymgenius/widgets/regeneration/regeneration_options_sheet.dart';

enum HomeState { initial, loading, loaded, error }

class HomeViewModel extends ChangeNotifier {
  final HomeRepository _repository;
  BuildContext? _context;

  void setContext(BuildContext context) {
    _context = context;
  }

  HomeViewModel(this._repository) {
    Log.info('HomeViewModel: Created');
    _loadData();
  }

  HomeState _state = HomeState.initial;
  HomeState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isGeneratingProgram = false;
  bool get isGeneratingProgram => _isGeneratingProgram;

  OnboardingData? _onboardingData;
  OnboardingData? get onboardingData => _onboardingData;

  TrainingProgramModel? _currentProgram;
  TrainingProgramModel? get currentProgram => _currentProgram;

  WeeklyWorkoutModel? _currentWeeklyWorkout;
  WeeklyWorkoutModel? get currentWeeklyWorkout => _currentWeeklyWorkout;

  bool _isProfileComplete = false;
  bool get isProfileComplete => _isProfileComplete;

  Future<void> _loadData() async {
    Log.info('HomeViewModel: Loading data...');
    _state = HomeState.loading;
    notifyListeners();

    try {
      final data = await _repository.loadHomeScreenData();

      _onboardingData = data.onboardingData;
      _isProfileComplete = data.isProfileComplete;
      _currentProgram = data.currentProgram;
      _currentWeeklyWorkout = data.currentWeeklyWorkout;

      Log.info('HomeViewModel: Profile complete: $_isProfileComplete');
      Log.info('HomeViewModel: Program found: ${_currentProgram != null}');
      Log.info(
          'HomeViewModel: Weekly workout found: ${_currentWeeklyWorkout != null}');

      _state = HomeState.loaded;
      notifyListeners();
    } catch (error, stackTrace) {
      Log.error(
        'HomeViewModel: Error loading data',
        error: error,
        stackTrace: stackTrace,
      );
      _errorMessage = error.toString();
      _state = HomeState.error;
      notifyListeners();
    }
  }

  Future<void> generateNewProgram() async {
    if (_onboardingData == null ||
        !_onboardingData!.isSufficientForAiGeneration) {
      _errorMessage = 'Profile data is incomplete.';
      _state = HomeState.error;
      notifyListeners();
      return;
    }

    _isGeneratingProgram = true;
    notifyListeners();

    try {
      await _repository.generateNewProgram(_onboardingData!, _currentProgram);
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
    if (_onboardingData == null ||
        !_onboardingData!.isSufficientForAiGeneration) {
      _errorMessage = 'Profile data is incomplete.';
      _state = HomeState.error;
      notifyListeners();
      return;
    }

    _isGeneratingProgram = true;
    notifyListeners();

    try {
      await _repository.regenerateProgramWithOptions(
        _onboardingData!,
        _currentProgram,
        options,
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
    await _repository.clearCurrentProgram();
    _currentProgram = null;
    _currentWeeklyWorkout = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    await _loadData();
  } // or map if needed
}

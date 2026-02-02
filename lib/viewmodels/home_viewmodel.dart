// lib/viewmodels/home_viewmodel_simple.dart
import 'package:flutter/material.dart';
import 'package:gymgenius/models/onboarding.dart';
import 'package:gymgenius/models/routine.dart';
import 'package:gymgenius/repositories/home_repository.dart';
import 'package:gymgenius/services/database_service.dart';
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
    Log.info("HomeViewModel: Created");
    _loadData();
  }

  HomeState _state = HomeState.initial;
  HomeState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isGeneratingRoutine = false;
  bool get isGeneratingRoutine => _isGeneratingRoutine;

  OnboardingData? _onboardingData;
  OnboardingData? get onboardingData => _onboardingData;

  WeeklyRoutine? _currentRoutine;
  WeeklyRoutine? get currentRoutine => _currentRoutine;

  bool _isProfileComplete = false;
  bool get isProfileComplete => _isProfileComplete;

  Future<void> _loadData() async {
    Log.info("HomeViewModel: Loading data...");
    _state = HomeState.loading;
    notifyListeners();

    try {
      // Get current user
      final userId = DatabaseService.instance.getCurrentUserId();
      Log.info("HomeViewModel: User ID: $userId");

      if (userId == null) {
        throw Exception("User not authenticated");
      }

      final user = DatabaseService.instance.getUser(userId);
      Log.info("HomeViewModel: User: ${user?.email}");

      if (user == null) {
        throw Exception("User profile not found");
      }

      // Load onboarding data
      if (user.onboardingData != null) {
        _onboardingData = OnboardingData.fromMap(user.onboardingData!);
        Log.info("HomeViewModel: Onboarding data loaded");
      }

      _isProfileComplete = user.onboardingCompleted;
      Log.info("HomeViewModel: Profile complete: $_isProfileComplete");

      // Load routine
      final routine = DatabaseService.instance.getCurrentRoutine(userId);
      Log.info("HomeViewModel: Routine found: ${routine != null}");

      if (routine != null && !routine.isExpired()) {
        _currentRoutine = WeeklyRoutine.fromMap(routine.toMap());
        Log.info("HomeViewModel: Current routine: ${_currentRoutine?.name}");
      }

      _state = HomeState.loaded;
      Log.info("HomeViewModel: State set to LOADED");
      notifyListeners();
    } catch (error, stackTrace) {
      Log.error("HomeViewModel: Error loading data",
          error: error, stackTrace: stackTrace);
      _errorMessage = error.toString();
      _state = HomeState.error;
      notifyListeners();
    }
  }

  Future<void> generateNewRoutine() async {
    if (_onboardingData == null ||
        !_onboardingData!.isSufficientForAiGeneration) {
      _errorMessage = "Profile data is incomplete.";
      _state = HomeState.error;
      notifyListeners();
      return;
    }

    _isGeneratingRoutine = true;
    notifyListeners();

    try {
      await _repository.generateNewRoutine(_onboardingData!, _currentRoutine);
      // Reload data after generating new routine
      await _loadData();
    } catch (e) {
      _errorMessage = "Failed to generate routine: $e";
      _state = HomeState.error;
      notifyListeners();
    } finally {
      _isGeneratingRoutine = false;
      notifyListeners();
    }
  }

  Future<void> regenerateRoutine(RegenerationOptions options) async {
    if (_onboardingData == null ||
        !_onboardingData!.isSufficientForAiGeneration) {
      _errorMessage = "Profile data is incomplete.";
      _state = HomeState.error;
      notifyListeners();
      return;
    }

    _isGeneratingRoutine = true;
    notifyListeners();

    try {
      await _repository.regenerateRoutineWithOptions(
        _onboardingData!,
        _currentRoutine,
        options,
      );

      // Reload data after regeneration
      await _loadData();

      // Show success feedback
      if (_context != null && _context!.mounted) {
        _showSuccessMessage(_context!, options);
      }
    } catch (e) {
      _errorMessage = "Failed to regenerate routine: $e";
      _state = HomeState.error;
      notifyListeners();
      if (_context != null && _context!.mounted) {
        _showErrorMessage(_context!, e.toString());
      }
    } finally {
      _isGeneratingRoutine = false;
      notifyListeners();
    }
  }

  void _showSuccessMessage(BuildContext context, RegenerationOptions options) {
    String message;

    switch (options.type) {
      case RegenerationType.fullRoutine:
        message = 'New routine generated successfully!';
        break;
      case RegenerationType.specificDay:
        message = 'Day regenerated successfully!';
        break;
      case RegenerationType.singleExercise:
        message = 'Exercise replaced successfully!';
        break;
      case RegenerationType.withPreferences:
        message = 'Routine customized successfully!';
        break;
    }

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

  Future<void> dismissExpiredRoutine() async {
    await _repository.clearCurrentRoutine();
    _currentRoutine = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    await _loadData();
  }
}

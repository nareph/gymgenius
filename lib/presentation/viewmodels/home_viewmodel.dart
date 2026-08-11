import 'package:flutter/material.dart';
import 'package:gymgenius/core/logger/logger_service.dart';
import 'package:gymgenius/domain/entities/daily_checkin.dart';
import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/domain/repositories/health_repository.dart';
import 'package:gymgenius/domain/repositories/progress_repository.dart';
import 'package:gymgenius/domain/repositories/recovery_repository.dart';
import 'package:gymgenius/domain/repositories/user_repository.dart';
import 'package:gymgenius/domain/entities/progress_snapshot.dart';
import 'package:gymgenius/engines/decision_engine/decision_engine.dart';
import 'package:gymgenius/engines/decision_engine/models/daily_plan.dart';
import 'package:gymgenius/engines/workout_engine/workout_engine.dart';
import 'package:gymgenius/presentation/screens/recovery/daily_checkin_screen.dart';
import 'package:gymgenius/presentation/widgets/regeneration/regeneration_options_sheet.dart';

enum HomeState { initial, loading, loaded, error }

class HomeViewModel extends ChangeNotifier {
  final WorkoutEngine _workoutEngine;
  final UserRepository _userRepository;
  final HealthRepository _healthRepository;
  final DecisionEngine _decisionEngine;
  final RecoveryRepository _recoveryRepository;
  final ProgressRepository _progressRepository;
  BuildContext? _context;

  HomeViewModel({
    required WorkoutEngine workoutEngine,
    required UserRepository userRepository,
    required HealthRepository healthRepository,
    required DecisionEngine decisionEngine,
    required RecoveryRepository recoveryRepository,
    required ProgressRepository progressRepository,
  })  : _workoutEngine = workoutEngine,
        _userRepository = userRepository,
        _healthRepository = healthRepository,
        _decisionEngine = decisionEngine,
        _recoveryRepository = recoveryRepository,
        _progressRepository = progressRepository {
    Log.info('HomeViewModel: Created');
    _loadData();
  }

  // =========================================================================
  // State
  // =========================================================================
  HomeState _state = HomeState.initial;
  HomeState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isGeneratingProgram = false;
  bool get isGeneratingProgram => _isGeneratingProgram;

  // -------------------------------------------------------------------------
  // Health profile
  // -------------------------------------------------------------------------
  HealthProfile? _healthProfile;
  HealthProfile? get healthProfile => _healthProfile;

  bool _isProfileComplete = false;
  bool get isProfileComplete => _isProfileComplete;

  // -------------------------------------------------------------------------
  // Current program
  // -------------------------------------------------------------------------
  TrainingProgram? _currentProgram;
  TrainingProgram? get currentProgram => _currentProgram;

  // -------------------------------------------------------------------------
  // Daily plan (orchestrated by the DecisionEngine)
  // -------------------------------------------------------------------------
  DailyPlan? _dailyPlan;
  DailyPlan? get dailyPlan => _dailyPlan;

  // =========================================================================
  // Data loading
  // =========================================================================
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

      final program = await _workoutEngine.getCurrentProgram();
      _currentProgram = program;

      // Retrieve today's check-in if it exists (do NOT prompt here;
      // prompting happens in the UI layer via [triggerCheckInIfNeeded]).
      DailyCheckIn? checkIn;
      checkIn = await _recoveryRepository.getDailyCheckIn(
        user.id,
        DateTime.now(),
      );

      ProgressSnapshot? progressSnapshot;
      try {
        progressSnapshot = await _progressRepository.computeSnapshot(user.id);
      } catch (e, s) {
        Log.error('HomeViewModel: Progress snapshot failed',
            error: e, stackTrace: s);
        progressSnapshot = null;
      }

      // Build DailyPlan using DecisionEngine ----
      if (program == null || healthProfile == null) {
        _dailyPlan = null;
      } else {
        _dailyPlan = await _decisionEngine.buildDailyPlanAndPersist(
          program,
          healthProfile,
          checkIn: checkIn,
          progressSnapshot: progressSnapshot,
        );
      }

      Log.info('HomeViewModel: Profile complete: $_isProfileComplete');
      Log.info('HomeViewModel: Program found: ${_currentProgram != null}');
      Log.info('HomeViewModel: DailyPlan loaded: ${_dailyPlan != null}');

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

  // =========================================================================
  // Program generation
  // =========================================================================
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

  // =========================================================================
  // Program dismissal
  // =========================================================================
  Future<void> dismissExpiredProgram() async {
    await _workoutEngine.clearCurrentProgram();

    _currentProgram = null;
    _dailyPlan = null; // also clear the daily plan

    notifyListeners();
  }

  // =========================================================================
  // Daily Check-in auto-trigger
  // =========================================================================

  /// Called by [HomeTabScreen] once the screen is mounted.
  ///
  /// If no check-in exists for today, opens [DailyCheckInScreen] as a
  /// full-screen dialog. On submission the result is forwarded to the
  /// DecisionEngine via [_applyCheckIn].
  Future<void> triggerCheckInIfNeeded(BuildContext context) async {
    final user = await _userRepository.getCurrentUser();
    if (user == null) return;

    // Incomplete profiles should not enter the check-in flow.
    if (_healthProfile == null || !_healthProfile!.isComplete) return;

    final today = DateTime.now();
    final existing = await _recoveryRepository.getDailyCheckIn(user.id, today);
    if (existing != null) return;

    final skipped = await _recoveryRepository.isCheckInSkipped(user.id, today);
    if (skipped) return;

    if (!context.mounted) return;

    final checkIn = await Navigator.of(context).push<DailyCheckIn?>(
      DailyCheckInScreen.route(user.id),
    );

    if (!context.mounted) return;

    if (checkIn != null) {
      await _applyCheckIn(checkIn);
    } else {
      // Skip for now → do not re-prompt until the next calendar day.
      await _recoveryRepository.markCheckInSkipped(user.id, today);
    }
  }

  Future<void> _applyCheckIn(DailyCheckIn checkIn) async {
    if (_currentProgram == null || _healthProfile == null) return;
    _state = HomeState.loading;
    notifyListeners();
    try {
      ProgressSnapshot? progressSnapshot;
      try {
        progressSnapshot =
            await _progressRepository.computeSnapshot(checkIn.userId);
      } catch (_) {
        progressSnapshot = null;
      }

      _dailyPlan = await _decisionEngine.buildDailyPlanAndPersist(
        _currentProgram!,
        _healthProfile!,
        checkIn: checkIn,
        progressSnapshot: progressSnapshot,
      );
      _state = HomeState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = HomeState.error;
    }
    notifyListeners();
  }

  // =========================================================================
  // Manual refresh
  // =========================================================================
  Future<void> refresh() async {
    await _loadData();
  }

  // =========================================================================
  // Context setter (for SnackBars)
  // =========================================================================
  void setContext(BuildContext context) {
    _context = context;
  }
}

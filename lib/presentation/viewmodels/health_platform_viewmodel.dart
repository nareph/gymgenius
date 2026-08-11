import 'package:flutter/foundation.dart';
import 'package:gymgenius/core/logger/logger_service.dart';
import 'package:gymgenius/domain/entities/blood_glucose_reading.dart';
import 'package:gymgenius/domain/entities/blood_pressure_reading.dart';
import 'package:gymgenius/domain/entities/habit.dart';
import 'package:gymgenius/domain/entities/habit_log.dart';
import 'package:gymgenius/domain/entities/health_platform_snapshot.dart';
import 'package:gymgenius/domain/entities/hydration_log.dart';
import 'package:gymgenius/domain/entities/mental_wellness_checkin.dart';
import 'package:gymgenius/domain/enums/energy_level.dart';
import 'package:gymgenius/domain/enums/glucose_context.dart';
import 'package:gymgenius/domain/enums/habit_frequency.dart';
import 'package:gymgenius/domain/enums/stress_level.dart';
import 'package:gymgenius/domain/repositories/health_platform_repository.dart';
import 'package:gymgenius/domain/repositories/health_repository.dart';
import 'package:gymgenius/domain/repositories/user_repository.dart';

enum HealthPlatformUiState { initial, loading, ready, error }

class HealthPlatformViewModel extends ChangeNotifier {
  final HealthPlatformRepository _repository;
  final UserRepository _userRepository;
  final HealthRepository _healthRepository;

  HealthPlatformViewModel({
    required HealthPlatformRepository repository,
    required UserRepository userRepository,
    required HealthRepository healthRepository,
  })  : _repository = repository,
        _userRepository = userRepository,
        _healthRepository = healthRepository;

  HealthPlatformUiState _state = HealthPlatformUiState.initial;
  HealthPlatformUiState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  HealthPlatformSnapshot? _snapshot;
  HealthPlatformSnapshot? get snapshot => _snapshot;

  List<BloodPressureReading> _bpHistory = const [];
  List<BloodPressureReading> get bpHistory => _bpHistory;

  List<BloodGlucoseReading> _glucoseHistory = const [];
  List<BloodGlucoseReading> get glucoseHistory => _glucoseHistory;

  List<HydrationLog> _hydrationToday = const [];
  List<HydrationLog> get hydrationToday => _hydrationToday;

  List<Habit> _habits = const [];
  List<Habit> get habits => _habits;

  String? _userId;

  Future<void> load() async {
    _state = HealthPlatformUiState.loading;
    notifyListeners();
    try {
      final user = await _userRepository.getCurrentUser();
      if (user == null) throw Exception('Not authenticated');
      _userId = user.id;

      final profile = await _healthRepository.getCurrentProfile();
      _snapshot = await _repository.computeSnapshot(
        user.id,
        weightKg: profile?.currentWeightKg,
      );
      _bpHistory = await _repository.getBloodPressureHistory(user.id);
      _glucoseHistory = await _repository.getBloodGlucoseHistory(user.id);
      _hydrationToday =
          await _repository.getHydrationLogsForDay(user.id, DateTime.now());
      _habits = await _repository.getHabits(user.id);
      _state = HealthPlatformUiState.ready;
    } catch (e, s) {
      Log.error('HealthPlatformViewModel.load failed', error: e, stackTrace: s);
      _errorMessage = e.toString();
      _state = HealthPlatformUiState.error;
    }
    notifyListeners();
  }

  Future<void> addBloodPressure({
    required int systolic,
    required int diastolic,
    int? heartRateBpm,
  }) async {
    final userId = _userId;
    if (userId == null) return;
    final now = DateTime.now();
    await _repository.saveBloodPressure(
      BloodPressureReading(
        id: '${userId}_bp_${now.millisecondsSinceEpoch}',
        userId: userId,
        systolic: systolic,
        diastolic: diastolic,
        heartRateBpm: heartRateBpm,
        measuredAt: now,
      ),
    );
    await load();
  }

  Future<void> addBloodGlucose({
    required double valueMmolL,
    required GlucoseContext context,
  }) async {
    final userId = _userId;
    if (userId == null) return;
    final now = DateTime.now();
    await _repository.saveBloodGlucose(
      BloodGlucoseReading(
        id: '${userId}_bg_${now.millisecondsSinceEpoch}',
        userId: userId,
        valueMmolL: valueMmolL,
        context: context,
        measuredAt: now,
      ),
    );
    await load();
  }

  Future<void> addHydration(int amountMl) async {
    final userId = _userId;
    if (userId == null) return;
    final now = DateTime.now();
    await _repository.saveHydrationLog(
      HydrationLog(
        id: '${userId}_h2o_${now.millisecondsSinceEpoch}',
        userId: userId,
        amountMl: amountMl,
        loggedAt: now,
      ),
    );
    await load();
  }

  Future<void> saveWellness({
    required int mood,
    required StressLevel stress,
    required EnergyLevel energy,
    String? notes,
  }) async {
    final userId = _userId;
    if (userId == null) return;
    final now = DateTime.now();
    await _repository.saveMentalWellness(
      MentalWellnessCheckIn(
        id: '${userId}_mw_${now.millisecondsSinceEpoch}',
        userId: userId,
        date: now,
        mood: mood,
        stress: stress,
        energy: energy,
        notes: notes,
      ),
    );
    await load();
  }

  Future<void> createHabit(String name, HabitFrequency frequency) async {
    final userId = _userId;
    if (userId == null) return;
    final now = DateTime.now();
    await _repository.saveHabit(
      Habit(
        id: '${userId}_habit_${now.millisecondsSinceEpoch}',
        userId: userId,
        name: name.trim(),
        frequency: frequency,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await load();
  }

  Future<void> toggleHabitActive(Habit habit) async {
    await _repository.saveHabit(
      habit.copyWith(isActive: !habit.isActive, updatedAt: DateTime.now()),
    );
    await load();
  }

  Future<void> deleteHabit(String id) async {
    await _repository.deleteHabit(id);
    await load();
  }

  Future<void> completeHabitToday(Habit habit) async {
    final userId = _userId;
    if (userId == null) return;
    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day);
    await _repository.saveHabitLog(
      HabitLog(
        id: '${habit.id}_${day.toIso8601String()}',
        userId: userId,
        habitId: habit.id,
        date: day,
        completed: true,
        loggedAt: now,
      ),
    );
    await load();
  }
}

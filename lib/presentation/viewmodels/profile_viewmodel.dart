// lib/presentation/viewmodels/profile_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:gymgenius/core/logger/logger_service.dart';
import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/enums/activity_level.dart';
import 'package:gymgenius/domain/enums/equipment_type.dart';
import 'package:gymgenius/domain/enums/experience_level.dart';
import 'package:gymgenius/domain/enums/fitness_goal.dart';
import 'package:gymgenius/domain/enums/gender.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/domain/enums/session_duration.dart';
import 'package:gymgenius/domain/enums/workout_day.dart';
import 'package:gymgenius/domain/enums/workout_frequency.dart';
import 'package:gymgenius/domain/repositories/health_repository.dart';
import 'package:gymgenius/domain/repositories/user_repository.dart';
import 'package:gymgenius/presentation/mappers/profile_setup_mapper.dart';
import 'package:gymgenius/presentation/question/profile_questions.dart';

enum ProfileState { initial, loading, loaded, saving, error }

class ProfileViewModel extends ChangeNotifier {
  final HealthRepository _healthRepository;
  final UserRepository _userRepository;

  ProfileViewModel({
    required HealthRepository healthRepository,
    required UserRepository userRepository,
  })  : _healthRepository = healthRepository,
        _userRepository = userRepository {
    loadProfile();
  }

  // --- State Properties ---
  ProfileState _state = ProfileState.initial;
  ProfileState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isEditing = false;
  bool get isEditing => _isEditing;

  HealthProfile? _originalProfile;
  Map<String, dynamic> _editValues = {};
  Map<String, dynamic> get displayData => _isEditing
      ? _editValues
      : _originalProfile != null
          ? _profileToMap(_originalProfile!)
          : {};

  // --- Controller Management ---
  final Map<String, TextEditingController> _controllers = {};
  Map<String, TextEditingController> get controllers => _controllers;

  // --- Core Logic ---
  Future<void> loadProfile() async {
    _setState(ProfileState.loading);
    try {
      _originalProfile = await _healthRepository.getCurrentProfile();
      _setState(ProfileState.loaded);
    } catch (e, s) {
      Log.error("ProfileViewModel: Failed to load profile",
          error: e, stackTrace: s);
      _errorMessage = "Could not load your profile.";
      _setState(ProfileState.error);
    }
  }

  void toggleEditMode({bool cancel = false}) {
    if (cancel || _isEditing) {
      _isEditing = false;
      _disposeControllers();
      Log.debug("ProfileViewModel: Exited edit mode.");
    } else {
      _isEditing = true;
      Log.debug("ProfileViewModel: Entering edit mode.");
      if (_originalProfile != null) {
        _editValues = _profileToMap(_originalProfile!);
        _primeControllers(_editValues);
      } else {
        _editValues = {};
        _primeControllers(_editValues);
      }
    }
    notifyListeners();
  }

  Map<String, dynamic> _profileToMap(HealthProfile profile) {
    return {
      'goal': profile.training.goal.value,
      'gender': profile.body.gender.value,
      'experience': profile.training.experience.value,
      'activity_level': profile.training.activityLevel.value,
      'frequency': profile.training.frequency.value,
      'session_duration_minutes': profile.training.sessionDuration.value,
      'workout_days':
          profile.training.preferredDays.map((d) => d.value).toList(),
      'equipment': profile.training.equipment.map((e) => e.value).toList(),
      'focus_areas': profile.training.focusAreas.map((m) => m.value).toList(),
      'country': profile.lifestyle.country,
      'physical_stats': {
        'age': profile.body.age,
        'weight_kg': profile.body.currentWeightKg,
        'height_m': profile.body.heightCm / 100.0,
        'target_weight_kg': profile.body.targetWeightKg,
      },
    };
  }

  void _primeControllers(Map<String, dynamic> data) {
    _disposeControllers();
    for (var question in defaultProfileQuestions) {
      if (question.type == QuestionType.numericInput) {
        if (question.id == 'physical_stats') {
          final stats = data[question.id] as Map<String, dynamic>? ?? {};
          for (var subKeyEntry in statSubKeyEntries) {
            final controllerKey = '${question.id}_${subKeyEntry.key}';
            final textValue = stats[subKeyEntry.key]?.toString() ?? '';
            _controllers[controllerKey] =
                TextEditingController(text: textValue);
          }
        }
      }
    }
  }

  void _disposeControllers() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }

  void updateEditValue(String key, dynamic value) {
    if (!_isEditing) return;
    _editValues[key] = value;
    notifyListeners();
  }

  Future<void> saveChanges() async {
    _controllers.forEach((key, controller) {
      if (key.startsWith('physical_stats_')) {
        final subKey = key.substring('physical_stats_'.length);
        (_editValues['physical_stats'] as Map<String, dynamic>)[subKey] =
            controller.text;
      } else {
        _editValues[key] = controller.text;
      }
    });

    Log.debug("ProfileViewModel: Saving changes: $_editValues");

    _setState(ProfileState.saving);
    try {
      final user = await _userRepository.getCurrentUser();
      if (user == null) throw Exception('User not authenticated');
      final newProfile =
          ProfileSetupMapper.toDomain(_editValues).copyWith(userId: user.id);
      await _healthRepository.saveHealthProfile(newProfile);
      _originalProfile = newProfile;
      _isEditing = false;
      _disposeControllers();
      Log.debug("ProfileViewModel: Changes saved successfully");
      _setState(ProfileState.loaded);
    } catch (e, s) {
      Log.error("ProfileViewModel: Failed to save profile",
          error: e, stackTrace: s);
      _errorMessage = "Failed to save changes. Please try again.";
      _setState(ProfileState.error);
    }
  }

  void _setState(ProfileState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }
}

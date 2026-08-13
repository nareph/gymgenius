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
      'avoided_muscles':
          profile.training.avoidedMuscles.map((m) => m.value).toList(),
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
    final stats = data['physical_stats'] as Map<String, dynamic>? ?? {};
    for (var entry in statSubKeyEntries) {
      final controllerKey = 'physical_stats_${entry.key}';
      final value = stats[entry.key];
      final textValue = value?.toString() ?? '';
      _controllers[controllerKey] = TextEditingController(text: textValue);
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
    // 1. Récupérer les valeurs des champs simples (non numériques)
    _controllers.forEach((key, controller) {
      if (!key.startsWith('physical_stats_')) {
        _editValues[key] = controller.text;
      }
    });

    // 2. Traiter les stats physiques avec le bon typage
    final statsMap =
        (_editValues['physical_stats'] as Map<String, dynamic>?) ?? {};
    for (final entry in statSubKeyEntries) {
      final controllerKey = 'physical_stats_${entry.key}';
      final controller = _controllers[controllerKey];
      if (controller != null) {
        final text = controller.text.trim();
        if (text.isNotEmpty) {
          if (entry.key == 'age') {
            // L'âge doit être un int
            final value = int.tryParse(text);
            if (value != null) {
              statsMap[entry.key] = value;
            } else {
              Log.warning('Invalid integer for age: "$text"');
            }
          } else {
            // Poids, taille → double
            final value = double.tryParse(text);
            if (value != null) {
              statsMap[entry.key] = value;
            } else {
              Log.warning('Invalid number for ${entry.key}: "$text"');
            }
          }
        } else {
          // Champ vide → on le met à null (ou on garde l'ancienne valeur)
          statsMap[entry.key] = null;
        }
      }
    }
    _editValues['physical_stats'] = statsMap;

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
      // On notifie un succès via un message stocké (pour la vue)
      _errorMessage = null; // pas d'erreur
    } catch (e, s) {
      Log.error("ProfileViewModel: Failed to save profile",
          error: e, stackTrace: s);
      _errorMessage = "Failed to save changes. Please try again.";
      _setState(ProfileState.error);
      // Ne pas réinitialiser l'état d'édition, l'utilisateur peut réessayer
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

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gymgenius/models/onboarding_question.dart';
import 'package:gymgenius/repositories/profile_repository.dart';
import 'package:gymgenius/services/logger_service.dart';

enum ProfileState { initial, loading, loaded, saving, error }

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository;

  ProfileViewModel(this._repository) {
    loadProfile();
  }

  // --- State Properties ---
  ProfileState _state = ProfileState.initial;
  ProfileState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isEditing = false;
  bool get isEditing => _isEditing;

  Map<String, dynamic> _originalData = {};
  Map<String, dynamic> _editValues = {};
  Map<String, dynamic> get displayData =>
      _isEditing ? _editValues : _originalData;

  // --- Controller Management ---
  final Map<String, TextEditingController> _controllers = {};
  Map<String, TextEditingController> get controllers => _controllers;

  // --- Core Logic ---
  Future<void> loadProfile() async {
    _setState(ProfileState.loading);
    try {
      _originalData = await _repository.loadProfileData();
      _setState(ProfileState.loaded);
    } catch (e, s) {
      Log.error("ProfileViewModel: Failed to load profile",
          error: e, stackTrace: s);
      _errorMessage = "Could not load your profile.";
      _setState(ProfileState.error);
    }
  }

  void toggleEditMode({bool cancel = false}) {
    Log.debug(
        "ProfileViewModel: toggleEditMode called. cancel: $cancel, current _isEditing: $_isEditing");

    if (cancel || _isEditing) {
      _isEditing = false;
      _disposeControllers(); // Clean up on exit
      Log.debug(
          "ProfileViewModel: Set _isEditing to false. Disposed controllers.");
    } else {
      _isEditing = true;
      Log.debug(
          "ProfileViewModel: Set _isEditing to true. Priming values and controllers.");

      // 1. Prepare the data for editing
      _editValues = jsonDecode(jsonEncode(_originalData));

      // 2. Defensively initialize nested maps
      if (_editValues['physical_stats'] == null ||
          _editValues['physical_stats'] is! Map) {
        _editValues['physical_stats'] = <String, dynamic>{};
      }

      // 3. Prime the controllers based on the prepared data
      _primeControllers(_editValues);
    }

    notifyListeners();
  }

  void _primeControllers(Map<String, dynamic> data) {
    _disposeControllers();
    Log.debug("Priming controllers with data: $data");
    for (var question in defaultOnboardingQuestions) {
      if (question.type == QuestionType.numericInput) {
        if (question.id == 'physical_stats') {
          final stats = data[question.id] as Map<String, dynamic>? ?? {};
          for (var subKeyEntry in statSubKeyEntries) {
            final controllerKey = '${question.id}_${subKeyEntry.key}';
            final textValue = stats[subKeyEntry.key]?.toString() ?? '';
            _controllers[controllerKey] =
                TextEditingController(text: textValue);
            Log.debug(
                "Created controller '$controllerKey' with value '$textValue'");
          }
        } else {
          final textValue = data[question.id]?.toString() ?? '';
          _controllers[question.id] = TextEditingController(text: textValue);
          Log.debug(
              "Created controller '${question.id}' with value '$textValue'");
        }
      }
    }
  }

  void _disposeControllers() {
    if (_controllers.isEmpty) return;
    Log.debug("Disposing ${_controllers.length} controllers.");
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
    // Collect values from controllers right before saving
    _controllers.forEach((key, controller) {
      if (key.startsWith('physical_stats_')) {
        final subKey = key.substring('physical_stats_'.length);
        (_editValues['physical_stats'] as Map<String, dynamic>)[subKey] =
            controller.text;
      } else {
        _editValues[key] = controller.text;
      }
    });

    _setState(ProfileState.saving);
    try {
      await _repository.saveProfileData(_editValues);
      _originalData = Map.from(_editValues);
      _isEditing = false;
      _disposeControllers();
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

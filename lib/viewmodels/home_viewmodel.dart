import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gymgenius/models/onboarding.dart';
import 'package:gymgenius/models/routine.dart';
import 'package:gymgenius/repositories/home_repository.dart';
import 'package:gymgenius/services/logger_service.dart';

enum HomeState { initial, loading, loaded, error, offline }

class HomeViewModel extends ChangeNotifier {
  final HomeRepository _repository;
  StreamSubscription? _profileSubscription;

  HomeViewModel(this._repository) {
    _loadInitialData();
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

  Future<void> _loadInitialData() async {
    _setState(HomeState.loading);

    final (cachedRoutine, cachedOnboarding) =
        await _repository.loadCachedData();
    if (cachedRoutine != null && cachedOnboarding != null) {
      _currentRoutine = cachedRoutine;
      _onboardingData = cachedOnboarding;
      _isProfileComplete = cachedOnboarding.completed;
      _setState(HomeState.loaded); 
    }

    final isOnline = await _repository.checkInternetConnection();
    if (!isOnline) {
      _setState(HomeState.offline);
      return;
    }

    _listenToProfileChanges();
  }

  void _listenToProfileChanges() {
    _profileSubscription?.cancel();
    _profileSubscription =
        _repository.getUserProfileStream()?.listen((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        _errorMessage = "User profile not found.";
        _setState(HomeState.error);
        return;
      }

      final data = snapshot.data()!;
      _onboardingData = OnboardingData.fromMap(data['onboardingData'] is Map
          ? Map<String, dynamic>.from(data['onboardingData'])
          : {});
      _isProfileComplete = data['onboardingCompleted'] as bool? ?? false;

      if (_isProfileComplete) {
        _repository.cacheOnboardingData(_onboardingData!);
      }

      if (data['currentRoutine'] != null) {
        _currentRoutine = WeeklyRoutine.fromMap(
            Map<String, dynamic>.from(data['currentRoutine']));
        _repository.cacheRoutineData(_currentRoutine!);
      } else {
        _currentRoutine = null;
      }
      _setState(HomeState.loaded);
    }, onError: (error) {
      Log.error("HomeViewModel: Error in profile stream: $error");
      _errorMessage = "Failed to load profile data.";
      _setState(HomeState.error);
    });
  }

  Future<void> generateNewRoutine() async {
    if (_onboardingData == null ||
        !_onboardingData!.isSufficientForAiGeneration) {
      _errorMessage = "Profile data is incomplete.";
      _setState(HomeState.error);
      return;
    }

    _isGeneratingRoutine = true;
    notifyListeners();

    try {
      await _repository.generateNewRoutine(_onboardingData!, _currentRoutine);
    } catch (e) {
      _errorMessage = "Failed to generate routine: $e";
    } finally {
      _isGeneratingRoutine = false;
      notifyListeners();
    }
  }

  Future<void> dismissExpiredRoutine() async {
    await _repository.clearCurrentRoutine();
    _currentRoutine = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    await _loadInitialData();
  }

  void _setState(HomeState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }
}

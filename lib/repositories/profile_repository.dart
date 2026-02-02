// lib/repositories/profile_repository.dart
import 'package:gymgenius/models/hive/user_model.dart';
import 'package:gymgenius/models/onboarding.dart';
import 'package:gymgenius/services/database_service.dart';
import 'package:gymgenius/services/logger_service.dart';

class ProfileRepository {
  final DatabaseService _db;

  ProfileRepository({DatabaseService? database})
      : _db = database ?? DatabaseService.instance;

  UserModel? get _currentUser => _db.getCurrentUser();

  /// Loads profile data from local database
  Future<Map<String, dynamic>> loadProfileData() async {
    if (_currentUser == null) throw Exception("User not authenticated");

    try {
      final user = _db.getUser(_currentUser!.uid);
      if (user?.onboardingData != null) {
        Log.debug("ProfileRepository: Loaded profile from database.");
        return Map<String, dynamic>.from(user!.onboardingData!);
      }
      return {};
    } catch (e) {
      Log.error("ProfileRepository: Failed to load profile", error: e);
      return {};
    }
  }

  /// Saves the user's profile data to local database
  Future<void> saveProfileData(Map<String, dynamic> data) async {
    if (_currentUser == null) {
      throw Exception("User not authenticated for saving");
    }

    final user = _db.getUser(_currentUser!.uid);
    if (user == null) throw Exception("User not found");

    // Check if data is sufficient using OnboardingData validation
    final onboardingData = OnboardingData.fromMap(data);
    final isComplete = onboardingData.isSufficientForAiGeneration;

    Log.debug("ProfileRepository: Checking completion status");
    Log.debug("  - Name: ${data['name']}");
    Log.debug("  - Goals: ${data['fitnessGoals']}");
    Log.debug("  - Level: ${data['fitnessLevel']}");
    Log.debug("  - Is complete: $isComplete");

    user.onboardingData = data;
    user.onboardingCompleted = isComplete;
    user.profileLastUpdatedAt = DateTime.now();

    await _db.updateUser(user);

    Log.debug(
        "ProfileRepository: Profile data saved. Status: ${user.onboardingCompleted}");
  }

  /// Signs out the current user
  Future<void> signOut() async {
    await _db.setCurrentUser(null);
  }

  /// Updates the onboarding data for the currently authenticated user
  Future<void> updateOnboardingData(Map<String, dynamic> answersMap) async {
    if (_currentUser == null) {
      throw Exception(
          'Cannot update onboarding data, user is not authenticated.');
    }

    final user = _db.getUser(_currentUser!.uid);
    if (user == null) throw Exception("User not found");

    // Use OnboardingData to properly validate
    final onboardingData = OnboardingData.fromMap(answersMap);
    final isComplete = onboardingData.isSufficientForAiGeneration;

    Log.debug("ProfileRepository: Updating onboarding data");
    Log.debug("  - Name: ${answersMap['name']}");
    Log.debug("  - Goals: ${answersMap['fitnessGoals']}");
    Log.debug("  - Level: ${answersMap['fitnessLevel']}");
    Log.debug("  - Frequency: ${answersMap['frequency']}");
    Log.debug("  - Equipment: ${answersMap['equipment']}");
    Log.debug("  - Is sufficient: $isComplete");

    user.onboardingData = answersMap;
    user.onboardingCompleted = isComplete;
    user.profileLastUpdatedAt = DateTime.now();

    await _db.updateUser(user);

    Log.debug(
        "ProfileRepository: Data updated. Complete: ${user.onboardingCompleted}");
  }
}

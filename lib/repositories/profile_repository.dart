import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymgenius/models/onboarding.dart';
import 'package:gymgenius/services/logger_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ProfileRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  User? get _currentUser => _auth.currentUser;

  /// Loads profile data, trying online first then falling back to cache.
  Future<Map<String, dynamic>> loadProfileData() async {
    if (_currentUser == null) throw Exception("User not authenticated");

    try {
      final doc = await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .get()
          .timeout(const Duration(seconds: 5));
      if (doc.exists && doc.data()?['onboardingData'] is Map) {
        Log.debug("ProfileRepository: Fetched profile from Firestore.");
        final data = Map<String, dynamic>.from(doc.data()!['onboardingData']);
        await _cacheOnboardingData(data);
        return data;
      }
    } catch (e) {
      Log.warning(
          "ProfileRepository: Online fetch failed, falling back to cache.",
          error: e);
    }

    Log.debug("ProfileRepository: Loading profile from cache.");
    return await _loadCachedOnboardingData();
  }

  /// Saves the user's profile data to both Firestore and local cache.
  Future<void> saveProfileData(Map<String, dynamic> data) async {
    if (_currentUser == null) {
      throw Exception("User not authenticated for saving");
    }

    final dataToSet = {
      'onboardingData': data,
      'onboardingCompleted': true,
      'profileLastUpdatedAt': FieldValue.serverTimestamp(),
    };
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .set(dataToSet, SetOptions(merge: true));
    await _cacheOnboardingData(data);
    Log.debug("ProfileRepository: Profile data saved to Firestore and cache.");
  }

  /// Loads onboarding data from local SharedPreferences.
  Future<Map<String, dynamic>> _loadCachedOnboardingData() async {
    if (_currentUser == null) return {};
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString =
          prefs.getString('cached_onboarding_${_currentUser!.uid}');
      return jsonString != null
          ? Map<String, dynamic>.from(json.decode(jsonString))
          : {};
    } catch (e) {
      Log.error("ProfileRepository: Failed to load cached data", error: e);
      return {};
    }
  }

  /// Caches onboarding data to local SharedPreferences.
  Future<void> _cacheOnboardingData(Map<String, dynamic> data) async {
    if (_currentUser == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'cached_onboarding_${_currentUser!.uid}', json.encode(data));
    } catch (e) {
      Log.error("ProfileRepository: Failed to cache data", error: e);
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Updates the onboarding data for the currently authenticated user.
  ///
  /// This method determines if the profile is complete based on the provided data
  /// and updates both the onboardingData map and the onboardingCompleted flag in Firestore.
  Future<void> updateOnboardingData(Map<String, dynamic> answersMap) async {
    if (_currentUser == null) {
      throw Exception(
          'Cannot update onboarding data, user is not authenticated.');
    }

    // Use the OnboardingData model to process the data and check for completion.
    final OnboardingData data = OnboardingData.fromMap(answersMap);
    final bool isNowComplete = data.isSufficientForAiGeneration;

    final OnboardingData dataToSave = data.copyWith(completed: isNowComplete);

    Log.debug(
        "ProfileRepository: Updating OnboardingData for user ${_currentUser!.uid}. Completion status: $isNowComplete");

    await _firestore.collection('users').doc(_currentUser!.uid).set(
      {
        'onboardingData': dataToSave.toMap(),
        'onboardingCompleted': isNowComplete,
        'profileLastUpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    // Also update the local cache.
    await _cacheOnboardingData(dataToSave.toMap());
  }
}

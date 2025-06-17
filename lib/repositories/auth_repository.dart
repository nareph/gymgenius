import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymgenius/services/logger_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository for handling all authentication and user session-related logic.
///
/// This class acts as an abstraction layer over FirebaseAuth and other services,
/// providing a clean API for the rest of the application (e.g., BLoCs) to interact with.
class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  /// Provides direct access to the current user object from FirebaseAuth.
  User? get currentUser => _firebaseAuth.currentUser;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Stream of [User] which will emit the current user when the auth state changes.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // --- Authentication Methods ---

  /// Signs in a user with the given [email] and [password].
  ///
  /// Throws a [FirebaseAuthException] if signing in fails.
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      // Allow specific exceptions to be caught by the BLoC.
      rethrow;
    } catch (e, s) {
      Log.error("AuthRepository: Unknown error during signIn",
          error: e, stackTrace: s);
      // Throw a generic exception for unknown errors.
      throw Exception('An unknown error occurred during sign-in.');
    }
  }

  /// Sends a password reset link to the given [email].
  ///
  /// Throws a [FirebaseAuthException] if the request fails.
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      rethrow;
    } catch (e, s) {
      Log.error("AuthRepository: Unknown error during password reset request",
          error: e, stackTrace: s);
      throw Exception('An unknown error occurred during password reset.');
    }
  }

  /// Signs up a new user with the given [email] and [password],
  /// and creates a corresponding user document in Firestore.
  ///
  /// The [onboardingData] is optional and will be saved to the new user's profile.
  Future<void> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? onboardingData,
  }) async {
    try {
      // 1. Create the user with Firebase Authentication
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;

      if (user == null) {
        throw Exception('User creation succeeded but user object is null.');
      }

      // 2. Prepare the user profile data for Firestore
      bool finalOnboardingCompletedFlag = false;
      Map<String, dynamic> onboardingDataToSave = {};

      if (onboardingData != null && onboardingData.isNotEmpty) {
        onboardingDataToSave = Map<String, dynamic>.from(onboardingData);
        // Ensure the 'completed' flag is set correctly
        if (onboardingDataToSave['completed'] != true) {
          onboardingDataToSave['completed'] = true;
        }
        finalOnboardingCompletedFlag = true;
      }

      final userProfileData = {
        'email': user.email,
        'uid': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'displayName': user.email?.split('@')[0] ?? 'New User',
        'onboardingData': onboardingDataToSave,
        'onboardingCompleted': finalOnboardingCompletedFlag,
      };

      Log.debug(
          "AuthRepository: Creating user profile in Firestore for ${user.uid}");

      // 3. Create the document in the 'users' collection
      await _firestore.collection('users').doc(user.uid).set(userProfileData);
    } on FirebaseAuthException {
      // Allow specific exceptions to be caught by the BLoC.
      rethrow;
    } catch (e, s) {
      Log.error("AuthRepository: Unknown error during signUp",
          error: e, stackTrace: s);
      throw Exception('An unknown error occurred during sign-up.');
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // --- User Profile and Cache Logic ---

  /// Checks if the user's profile setup is marked as complete in Firestore.
  /// This method is intended to be called online and will throw exceptions on network failure.
  Future<bool> isProfileSetupComplete(String userId) async {
    if (userId.isEmpty) {
      Log.warning("isProfileSetupComplete called with an empty userId.");
      return false;
    }

    // The try-catch is removed here so the BLoC can handle network errors
    // and decide whether to fall back to cache.
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .get(const GetOptions(source: Source.server)) // Force server request
        .timeout(const Duration(seconds: 5));

    if (doc.exists && (doc.data()?['onboardingCompleted'] as bool? ?? false)) {
      Log.debug("User $userId has completed onboarding (from Firestore).");
      return true;
    }

    Log.debug("User $userId has NOT completed onboarding (from Firestore).");
    return false;
  }

  /// Checks local cache for any usable data (onboarding profile or active routine).
  /// This is used as a fallback when offline to grant access to the app.
  Future<bool> hasUsableCachedData(String userId) async {
    if (userId.isEmpty) return false;
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check for valid onboarding data in cache.
      final onboardingJson = prefs.getString('cached_onboarding_$userId');
      if (onboardingJson != null) {
        final data = json.decode(onboardingJson) as Map<String, dynamic>;
        // Define what constitutes "usable" data.
        if (data['name'] != null &&
            data['fitnessGoals'] != null &&
            data['fitnessLevel'] != null) {
          Log.debug("User $userId has valid cached onboarding data.");
          return true;
        }
      }

      // Check for a non-expired routine in cache.
      final routineJson = prefs.getString('cached_routine_$userId');
      if (routineJson != null) {
        final data = json.decode(routineJson) as Map<String, dynamic>;
        if (data['expiresAt'] != null) {
          final expiresAt =
              DateTime.fromMillisecondsSinceEpoch(data['expiresAt']);
          if (DateTime.now().isBefore(expiresAt)) {
            Log.debug("User $userId has a valid cached routine.");
            return true;
          }
        }
      }

      Log.debug("User $userId has no usable cached data.");
      return false;
    } catch (e, s) {
      Log.error("Error checking all cached data for user $userId",
          error: e, stackTrace: s);
      return false;
    }
  }
}

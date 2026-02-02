// lib/repositories/auth_repository.dart
import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gymgenius/models/hive/user_model.dart';
import 'package:gymgenius/models/onboarding.dart';
import 'package:gymgenius/services/database_service.dart';
import 'package:gymgenius/services/logger_service.dart';
import 'package:uuid/uuid.dart';

/// Repository for handling all authentication and user session-related logic.
/// This is a local-only implementation without Firebase.
///
/// IMPORTANT: This app supports SINGLE USER mode only. Creating a new user
/// will automatically delete all previous user data.
class AuthRepository {
  final DatabaseService _db;
  final FlutterSecureStorage _secureStorage;
  final _uuid = const Uuid();

  // Stream controller for auth state changes
  final _authStateController = StreamController<UserModel?>.broadcast();

  UserModel? _currentUser;
  bool _initialized = false;

  /// Provides direct access to the current user object.
  UserModel? get currentUser => _currentUser;

  AuthRepository({
    DatabaseService? database,
    FlutterSecureStorage? secureStorage,
  })  : _db = database ?? DatabaseService.instance,
        _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    _initializeCurrentUser();
  }

  /// Initialize current user from database
  Future<void> _initializeCurrentUser() async {
    try {
      final userId = _db.getCurrentUserId();
      Log.info("AuthRepository: Initializing, userId: $userId");

      if (userId != null) {
        _currentUser = _db.getUser(userId);
        Log.info("AuthRepository: Found user: ${_currentUser?.email}");
      } else {
        Log.info("AuthRepository: No user found");
      }

      _initialized = true;

      // Emit initial state after a short delay to ensure listeners are ready
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!_authStateController.isClosed) {
          _authStateController.add(_currentUser);
          Log.info(
              "AuthRepository: Emitted initial state - user: ${_currentUser?.email}");
        }
      });
    } catch (error, stackTrace) {
      Log.error("AuthRepository: Error initializing current user",
          error: error, stackTrace: stackTrace);
      _initialized = true;
      _authStateController.add(null);
    }
  }

  /// Stream of [UserModel] which will emit the current user when the auth state changes.
  Stream<UserModel?> get authStateChanges async* {
    // If already initialized, emit current state immediately
    if (_initialized) {
      yield _currentUser;
    }
    // Then continue with the stream
    yield* _authStateController.stream;
  }

  // --- Authentication Methods ---

  /// Signs in a user with the given [email] and [password].
  /// Throws an [AuthException] if signing in fails.
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Hash the password for comparison
      final hashedPassword = _hashPassword(password);

      // Get stored credentials
      final storedHash = await _secureStorage.read(key: 'password_$email');
      final storedUid = await _secureStorage.read(key: 'uid_$email');

      if (storedHash == null || storedUid == null) {
        throw AuthException('No user found with this email');
      }

      if (storedHash != hashedPassword) {
        throw AuthException('Incorrect password');
      }

      // Load user from database
      final user = _db.getUser(storedUid);
      if (user == null) {
        throw AuthException('User data not found');
      }

      // Set as current user
      _currentUser = user;
      await _db.setCurrentUser(user.uid);

      // Emit state change AFTER updating _currentUser
      _authStateController.add(_currentUser);
      Log.debug(
          "AuthRepository: User ${user.email} signed in successfully, state emitted");
    } catch (e) {
      if (e is AuthException) rethrow;
      Log.error("AuthRepository: Error during sign-in", error: e);
      throw AuthException('An error occurred during sign-in');
    }
  }

  /// Sends a password reset link to the given [email].
  /// In local mode, this generates a reset token.
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      final storedUid = await _secureStorage.read(key: 'uid_$email');
      if (storedUid == null) {
        throw AuthException('No user found with this email');
      }

      // Generate reset token (in a real app, you'd send this via email)
      final resetToken = _uuid.v4();
      await _secureStorage.write(
        key: 'reset_token_$email',
        value: resetToken,
      );

      Log.debug("AuthRepository: Password reset token generated for $email");
      // In a real implementation, send this token via email
    } catch (e) {
      if (e is AuthException) rethrow;
      Log.error("AuthRepository: Error during password reset", error: e);
      throw AuthException('An error occurred during password reset');
    }
  }

  /// Signs up a new user with the given [email] and [password].
  /// Note: Existing user data should be cleared BEFORE calling this (in home_screen.dart)
  Future<void> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? onboardingData,
  }) async {
    try {
      Log.debug("AuthRepository: Starting signup for $email");

      // Check if user already exists with this email
      final existingUid = await _secureStorage.read(key: 'uid_$email');
      if (existingUid != null) {
        throw AuthException('An account with this email already exists');
      }

      // Create new user
      final uid = _uuid.v4();
      final hashedPassword = _hashPassword(password);

      // Store credentials securely
      await _secureStorage.write(key: 'uid_$email', value: uid);
      await _secureStorage.write(key: 'password_$email', value: hashedPassword);

      // Validate onboarding data
      bool isOnboardingComplete = false;
      if (onboardingData != null && onboardingData.isNotEmpty) {
        final onboarding = OnboardingData.fromMap(onboardingData);
        isOnboardingComplete = onboarding.isSufficientForAiGeneration;

        Log.debug("AuthRepository: Onboarding data validation");
        Log.debug("  - Name: ${onboardingData['name']}");
        Log.debug("  - Goals: ${onboardingData['fitnessGoals']}");
        Log.debug("  - Level: ${onboardingData['fitnessLevel']}");
        Log.debug("  - Is sufficient: $isOnboardingComplete");
      }

      // Create user model
      final user = UserModel(
        uid: uid,
        email: email,
        displayName: onboardingData?['name'] as String? ?? email.split('@')[0],
        createdAt: DateTime.now(),
        onboardingData: onboardingData,
        onboardingCompleted: isOnboardingComplete,
      );

      Log.debug("AuthRepository: Created user model");
      Log.debug("  - UID: ${user.uid}");
      Log.debug("  - Email: ${user.email}");
      Log.debug("  - Display Name: ${user.displayName}");
      Log.debug("  - Onboarding Complete: ${user.onboardingCompleted}");

      // Save to database (DatabaseService handles clearing old data if different UID)
      await _db.saveUser(user);

      // Set as current user
      _currentUser = user;
      await _db.setCurrentUser(uid);

      // Emit state change AFTER updating _currentUser
      _authStateController.add(_currentUser);
      Log.debug("AuthRepository: User $email signed up successfully");
    } catch (e, s) {
      if (e is AuthException) rethrow;
      Log.error("AuthRepository: Error during sign-up",
          error: e, stackTrace: s);
      throw AuthException('An error occurred during sign-up');
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    _currentUser = null;
    await _db.setCurrentUser(null);
    _authStateController.add(null);
    Log.debug("AuthRepository: User signed out, state emitted");
  }

  // --- User Profile Logic ---

  /// Checks if the user's profile setup is marked as complete.
  Future<bool> isProfileSetupComplete(String userId) async {
    if (userId.isEmpty) {
      Log.warning("isProfileSetupComplete called with an empty userId.");
      return false;
    }

    final user = _db.getUser(userId);
    if (user != null && user.onboardingCompleted) {
      Log.debug("User $userId has completed onboarding.");
      return true;
    }

    Log.debug("User $userId has NOT completed onboarding.");
    return false;
  }

  /// Checks if user has usable cached data (onboarding profile or active routine).
  Future<bool> hasUsableCachedData(String userId) async {
    if (userId.isEmpty) return false;

    try {
      final user = _db.getUser(userId);
      if (user == null) return false;

      // Check for valid onboarding data
      if (user.onboardingData != null) {
        final onboarding = OnboardingData.fromMap(user.onboardingData!);
        if (onboarding.isSufficientForAiGeneration) {
          Log.debug("User $userId has sufficient onboarding data.");
          return true;
        }
      }

      // Check for non-expired routine
      final routine = _db.getCurrentRoutine(userId);
      if (routine != null && !routine.isExpired()) {
        Log.debug("User $userId has a valid routine.");
        return true;
      }

      Log.debug("User $userId has no usable data.");
      return false;
    } catch (e, s) {
      Log.error("Error checking cached data for user $userId",
          error: e, stackTrace: s);
      return false;
    }
  }

  /// Hash password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  void dispose() {
    _authStateController.close();
  }
}

/// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

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

  final _authStateController = StreamController<UserModel?>.broadcast();

  UserModel? _currentUser;
  bool _initialized = false;

  UserModel? get currentUser => _currentUser;

  AuthRepository({
    DatabaseService? database,
    FlutterSecureStorage? secureStorage,
  })  : _db = database ?? DatabaseService.instance,
        _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    _initializeCurrentUser();
  }

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

  Stream<UserModel?> get authStateChanges async* {
    if (_initialized) {
      yield _currentUser;
    }
    yield* _authStateController.stream;
  }

  // --- Authentication Methods ---

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final hashedPassword = _hashPassword(password);

      final storedHash = await _secureStorage.read(key: 'password_$email');
      final storedUid = await _secureStorage.read(key: 'uid_$email');

      if (storedHash == null || storedUid == null) {
        throw AuthException('No user found with this email');
      }

      if (storedHash != hashedPassword) {
        throw AuthException('Incorrect password');
      }

      final user = _db.getUser(storedUid);
      if (user == null) {
        throw AuthException('User data not found');
      }

      _currentUser = user;
      await _db.setCurrentUser(user.uid);
      _authStateController.add(_currentUser);
      Log.debug("AuthRepository: User ${user.email} signed in successfully");
    } catch (e) {
      if (e is AuthException) rethrow;
      Log.error("AuthRepository: Error during sign-in", error: e);
      throw AuthException('An error occurred during sign-in');
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      final storedUid = await _secureStorage.read(key: 'uid_$email');
      if (storedUid == null) {
        throw AuthException('No user found with this email');
      }

      final resetToken = _uuid.v4();
      await _secureStorage.write(
        key: 'reset_token_$email',
        value: resetToken,
      );

      Log.debug("AuthRepository: Password reset token generated for $email");
    } catch (e) {
      if (e is AuthException) rethrow;
      Log.error("AuthRepository: Error during password reset", error: e);
      throw AuthException('An error occurred during password reset');
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? onboardingData,
  }) async {
    try {
      Log.debug("AuthRepository: Starting signup for $email");

      final existingUid = await _secureStorage.read(key: 'uid_$email');
      if (existingUid != null) {
        throw AuthException('An account with this email already exists');
      }

      final uid = _uuid.v4();
      final hashedPassword = _hashPassword(password);

      await _secureStorage.write(key: 'uid_$email', value: uid);
      await _secureStorage.write(key: 'password_$email', value: hashedPassword);

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

      await _db.saveUser(user);
      _currentUser = user;
      await _db.setCurrentUser(uid);
      _authStateController.add(_currentUser);
      Log.debug("AuthRepository: User $email signed up successfully");
    } catch (e, s) {
      if (e is AuthException) rethrow;
      Log.error("AuthRepository: Error during sign-up",
          error: e, stackTrace: s);
      throw AuthException('An error occurred during sign-up');
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    await _db.setCurrentUser(null);
    _authStateController.add(null);
    Log.debug("AuthRepository: User signed out, state emitted");
  }

  // --- User Profile Logic ---

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

  Future<bool> hasUsableCachedData(String userId) async {
    if (userId.isEmpty) return false;

    try {
      final user = _db.getUser(userId);
      if (user == null) return false;

      if (user.onboardingData != null) {
        final onboarding = OnboardingData.fromMap(user.onboardingData!);
        if (onboarding.isSufficientForAiGeneration) {
          Log.debug("User $userId has sufficient onboarding data.");
          return true;
        }
      }

      // Check for non-expired program
      final program = _db.getCurrentProgram(userId);
      if (program != null && !program.isExpired()) {
        Log.debug("User $userId has a valid program.");
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

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  void dispose() {
    _authStateController.close();
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

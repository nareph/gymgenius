import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gymgenius/core/exceptions/auth_exception.dart';
import 'package:gymgenius/core/logger/logger_service.dart';
import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/entities/user.dart';
import 'package:gymgenius/domain/repositories/auth_repository.dart';
import 'package:gymgenius/domain/repositories/health_repository.dart';
import 'package:gymgenius/domain/repositories/user_repository.dart';
import 'package:uuid/uuid.dart';

class AuthRepositoryImpl implements AuthRepository {
  final UserRepository _userRepository;
  final HealthRepository _healthRepository;
  final FlutterSecureStorage _secureStorage;
  final _uuid = const Uuid();

  AuthRepositoryImpl({
    required UserRepository userRepository,
    required HealthRepository healthRepository,
    FlutterSecureStorage? secureStorage,
  })  : _userRepository = userRepository,
        _healthRepository = healthRepository,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  @override
  Future<User?> getCurrentUser() => _userRepository.getCurrentUser();

  @override
  Future<HealthProfile?> getCurrentHealthProfile() =>
      _healthRepository.getCurrentProfile();

  @override
  Future<void> signIn(String email, String password) async {
    final hashed = _hashPassword(password);
    final storedHash = await _secureStorage.read(key: 'password_$email');
    final storedUid = await _secureStorage.read(key: 'uid_$email');

    if (storedHash == null || storedUid == null) {
      throw AuthException('No user found with this email');
    }
    if (storedHash != hashed) {
      throw AuthException('Incorrect password');
    }
  }

  @override
  Future<void> signUp(
      String email, String password, HealthProfile profile) async {
    final existing = await _secureStorage.read(key: 'uid_$email');
    if (existing != null) {
      throw AuthException('An account with this email already exists');
    }

    final uid = _uuid.v4();
    final hashed = _hashPassword(password);

    await _secureStorage.write(key: 'uid_$email', value: uid);
    await _secureStorage.write(key: 'password_$email', value: hashed);

    // IMPORTANT: save the HealthProfile BEFORE the User record. Saving
    // the User is what makes `watchUser()` emit (AuthBloc is subscribed
    // to it from construction time) and triggers
    // `AuthBloc._handleUserStatusCheck()`, which immediately reads
    // `_healthRepository.getCurrentProfile()`. That reaction happens
    // asynchronously via Dart's event loop — there's no guarantee it
    // waits for any code written after `saveUser()` in this function.
    // If the profile isn't saved yet when AuthBloc checks, it finds
    // nothing and reports ALL required fields as missing (the exact
    // symptom seen: 10/10 fields, not a partial/inconsistent read).
    // Saving the profile first closes that race entirely: by the time
    // anything can react to the user existing, the profile is already
    // durable.
    final healthProfile = profile.copyWith(userId: uid);
    await _healthRepository.saveHealthProfile(healthProfile);

    final user =
        User(id: uid, email: email, displayName: email.split('@').first);
    await _userRepository.saveUser(user);
  }

  @override
  Future<void> signOut() async {
    final user = await _userRepository.getCurrentUser();
    if (user != null) {
      await _userRepository.deleteUser(user.id);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    final storedUid = await _secureStorage.read(key: 'uid_$email');
    if (storedUid == null) {
      throw AuthException('No user found with this email');
    }
    final resetToken = _uuid.v4();
    await _secureStorage.write(key: 'reset_token_$email', value: resetToken);
    Log.debug("AuthRepositoryImpl: Password reset token generated for $email");
  }

  @override
  Future<bool> isProfileComplete(String userId) async {
    final profile = await _healthRepository.getHealthProfile(userId);
    return profile != null && profile.isComplete;
  }

  @override
  Stream<User?> watchUser() {
    return _userRepository.watchUser('');
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

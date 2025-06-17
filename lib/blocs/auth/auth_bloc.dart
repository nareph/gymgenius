// lib/blocs/auth/auth_bloc.dart
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymgenius/repositories/auth_repository.dart';
import 'package:gymgenius/services/logger_service.dart';

// Include the event and state files as parts of this library
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _userSubscription;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState.unknown()) {
    _userSubscription = _authRepository.authStateChanges.listen(
      (user) => add(_AuthUserChanged(user)),
    );

    on<_AuthUserChanged>(_onUserChanged);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthStateCheckRequested>(_onStateCheckRequested);
  }

  Future<void> _handleUserStatusCheck(
      User? user, Emitter<AuthState> emit) async {
    Log.debug(
        "AuthBloc: Handling user status check for user: ${user?.uid ?? 'null'}");

    if (user != null) {
      emit(const AuthState.unknown());
      Log.debug("AuthBloc: Emitted unknown state during check");

      try {
        final isComplete =
            await _authRepository.isProfileSetupComplete(user.uid);
        Log.info("AuthBloc: Profile complete: $isComplete for ${user.uid}");

        final newState =
            AuthState.authenticated(user: user, isProfileComplete: isComplete);
        Log.debug("AuthBloc: Emitting authenticated state: $newState");
        emit(newState);
      } catch (e) {
        Log.warning(
            "AuthBloc: Online check failed. Falling back to cache check.",
            error: e);
        final hasCache = await _authRepository.hasUsableCachedData(user.uid);
        if (hasCache) {
          emit(AuthState.authenticated(user: user, isProfileComplete: true));
        } else {
          emit(AuthState.authenticatedOfflineNoCache(user: user));
        }
      }
    } else {
      Log.debug("AuthBloc: No user, emitting unauthenticated");
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onUserChanged(
      _AuthUserChanged event, Emitter<AuthState> emit) async {
    await _handleUserStatusCheck(event.user, emit);
  }

  /// Called when the UI manually requests a state re-check (e.g., "Try Again" button).
  Future<void> _onStateCheckRequested(
      AuthStateCheckRequested event, Emitter<AuthState> emit) async {
    Log.debug("AuthBloc: Manual state check requested.");
    // We re-run the check logic. We can get the current user directly from FirebaseAuth
    // as it's the most up-to-date source of truth.
    await _handleUserStatusCheck(_authRepository.currentUser, emit);
  }

  void _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) {
    _authRepository.signOut();
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}

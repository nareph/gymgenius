// lib/blocs/auth/auth_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gymgenius/models/hive/user_model.dart';
import 'package:gymgenius/repositories/auth_repository.dart';
import 'package:gymgenius/services/logger_service.dart';
import 'package:gymgenius/services/database_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<UserModel?>? _userSubscription;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState.unknown()) {
    Log.info("AuthBloc: Initializing...");

    // Register event handlers FIRST
    on<_AuthUserChanged>(_onUserChanged);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthStateCheckRequested>(_onCheckRequested);

    // Then set up the stream subscription
    _userSubscription = _authRepository.authStateChanges.listen(
      (user) {
        Log.info(
            "AuthBloc: Auth state change received - user: ${user?.email ?? 'null'}");
        add(_AuthUserChanged(user));
      },
      onError: (error) {
        Log.error("AuthBloc: Error in auth stream", error: error);
        add(const _AuthUserChanged(null));
      },
    );

    // Trigger initial state check
    _initializeAuthState();
  }

  /// Initialize auth state on bloc creation
  void _initializeAuthState() {
    final user = _authRepository.currentUser;
    Log.info("AuthBloc: Initial user check - user: ${user?.email ?? 'null'}");
    add(_AuthUserChanged(user));
  }

  Future<void> _onCheckRequested(
    AuthStateCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    Log.info("AuthBloc: Manual check requested");
    final user = _authRepository.currentUser;
    Log.info("AuthBloc: Direct check - user: ${user?.email ?? 'null'}");
    await _handleUserStatusCheck(user, emit);
  }

  Future<void> _onUserChanged(
    _AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    Log.info(
        "AuthBloc: User changed event - user: ${event.user?.email ?? 'null'}");
    await _handleUserStatusCheck(event.user, emit);
  }

  Future<void> _handleUserStatusCheck(
      UserModel? user, Emitter<AuthState> emit) async {
    Log.info("AuthBloc: Handling user status check");

    if (user == null) {
      Log.info("AuthBloc: No user, emitting unauthenticated");
      emit(const AuthState.unauthenticated());
      return;
    }

    // First check if profile is already marked as complete in the user object
    if (user.onboardingCompleted) {
      Log.info("AuthBloc: Profile marked as complete in user object");
      emit(AuthState.authenticated(user: user, isProfileComplete: true));
      return;
    }

    // User exists but profile completion status unknown, emit loading
    emit(const AuthState.unknown());
    Log.debug("AuthBloc: Emitted unknown state during check");

    try {
      final isComplete = await _authRepository.isProfileSetupComplete(user.uid);
      Log.info("AuthBloc: Profile complete: $isComplete for ${user.uid}");

      // Update user object with completion status if needed
      if (isComplete && !user.onboardingCompleted) {
        user.onboardingCompleted = true;
        // Save updated user to database
        await DatabaseService.instance.saveUser(user);
      }

      final newState =
          AuthState.authenticated(user: user, isProfileComplete: isComplete);
      Log.info(
          "AuthBloc: Emitting authenticated state with profile complete: $isComplete");
      emit(newState);
    } catch (e) {
      Log.warning("AuthBloc: Check failed. Falling back to cache check.",
          error: e);
      // Check user object directly
      if (user.onboardingCompleted) {
        emit(AuthState.authenticated(user: user, isProfileComplete: true));
      } else {
        final hasCache = await _authRepository.hasUsableCachedData(user.uid);
        if (hasCache) {
          emit(AuthState.authenticated(user: user, isProfileComplete: true));
        } else {
          emit(AuthState.authenticatedOfflineNoCache(user: user));
        }
      }
    }
  }

  void _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) {
    Log.info("AuthBloc: Logout requested");
    _authRepository.signOut();
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    _authRepository.dispose();
    return super.close();
  }
}

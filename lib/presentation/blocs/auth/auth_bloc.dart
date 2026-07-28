import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gymgenius/core/logger/logger_service.dart';
import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/entities/user.dart';
import 'package:gymgenius/domain/repositories/auth_repository.dart';
import 'package:gymgenius/domain/repositories/health_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final HealthRepository _healthRepository;
  StreamSubscription<User?>? _userSubscription;

  AuthBloc({
    required AuthRepository authRepository,
    required HealthRepository healthRepository,
  })  : _authRepository = authRepository,
        _healthRepository = healthRepository,
        super(const AuthState.unknown()) {
    Log.info("AuthBloc: Initializing...");

    on<_AuthUserChanged>(_onUserChanged);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthStateCheckRequested>(_onCheckRequested);

    _userSubscription = _authRepository.watchUser().listen(
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

    _initializeAuthState();
  }

  void _initializeAuthState() async {
    final user = await _authRepository.getCurrentUser();
    Log.info("AuthBloc: Initial user check - user: ${user?.email ?? 'null'}");
    add(_AuthUserChanged(user));
  }

  Future<void> _onCheckRequested(
    AuthStateCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    Log.info("AuthBloc: Manual check requested");
    final user = await _authRepository.getCurrentUser();
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
      User? user, Emitter<AuthState> emit) async {
    Log.info("AuthBloc: Handling user status check");

    if (user == null) {
      Log.info("AuthBloc: No user, emitting unauthenticated");
      emit(const AuthState.unauthenticated());
      return;
    }

    // HealthProfile.isComplete now checks answeredQuestionIds (real user
    // input), not defaulted values, so this is a straightforward read —
    // no separate raw-answers lookup needed.
    final HealthProfile? healthProfile =
        await _healthRepository.getCurrentProfile();

    if (healthProfile != null && healthProfile.isComplete) {
      Log.info("AuthBloc: Profile complete for ${user.id}");
      emit(AuthState.authenticated(user: user, isProfileComplete: true));
    } else {
      final missing =
          healthProfile?.missingFieldIds ?? HealthProfile.requiredFieldIds;
      Log.info(
          "AuthBloc: Profile incomplete for ${user.id} (missing: $missing), "
          "emitting authenticated with incomplete profile");
      emit(AuthState.authenticated(
        user: user,
        isProfileComplete: false,
        missingFieldIds: missing,
      ));
    }
  }

  void _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) {
    Log.info("AuthBloc: Logout requested");
    _authRepository.signOut();
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}

// lib/presentation/blocs/login/login_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:gymgenius/core/exceptions/auth_exception.dart';
import 'package:gymgenius/core/logger/logger_service.dart';
import 'package:gymgenius/domain/repositories/auth_repository.dart';
import 'package:gymgenius/presentation/validators/form_validators.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;

  LoginBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const LoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
    on<LoginPasswordResetRequested>(_onPasswordResetRequested);
  }

  void _onEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
    final email = Email.dirty(event.email);
    emit(state.copyWith(
        email: email, isValid: Formz.validate([email, state.password])));
  }

  void _onPasswordChanged(
      LoginPasswordChanged event, Emitter<LoginState> emit) {
    final password = Password.dirty(event.password);
    emit(state.copyWith(
        password: password, isValid: Formz.validate([state.email, password])));
  }

  Future<void> _onSubmitted(
      LoginSubmitted event, Emitter<LoginState> emit) async {
    if (!state.isValid) return;
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      await _authRepository.signIn(
        state.email.value,
        state.password.value,
      );

      Log.info("LoginBloc: signIn successful.");
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on AuthException catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: _mapAuthErrorToMessage(e.message),
      ));
    } catch (e) {
      Log.error("LoginBloc: Unexpected error during login", error: e);
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: "Login failed. Please try again.",
      ));
    }
  }

  Future<void> _onPasswordResetRequested(
      LoginPasswordResetRequested event, Emitter<LoginState> emit) async {
    if (state.email.isNotValid) {
      emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: "Please enter a valid email to reset your password."));
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      await _authRepository.sendPasswordResetEmail(state.email.value);
      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        successMessage:
            "If the email is in our system, a reset link has been sent.",
      ));
    } on AuthException catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      Log.error("LoginBloc: Error sending password reset", error: e);
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: "Failed to send reset email. Please try again.",
      ));
    }
  }

  String _mapAuthErrorToMessage(String errorMessage) {
    final lower = errorMessage.toLowerCase();
    if (lower.contains('no user found') || lower.contains('not found')) {
      return 'No account found with this email. Please sign up.';
    } else if (lower.contains('incorrect password') ||
        lower.contains('wrong password')) {
      return 'Incorrect password. Please try again.';
    } else if (lower.contains('invalid email')) {
      return 'Invalid email address format.';
    } else if (lower.contains('too many')) {
      return 'Too many login attempts. Please try again later.';
    } else if (lower.contains('disabled') || lower.contains('suspended')) {
      return 'This account has been disabled. Please contact support.';
    } else {
      return errorMessage;
    }
  }
}

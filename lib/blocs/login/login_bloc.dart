// lib/blocs/login/login_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:gymgenius/repositories/auth_repository.dart';
import 'package:gymgenius/services/logger_service.dart';
import 'package:gymgenius/models/form_validators.dart';

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

  /// Handles the login submission event.
  Future<void> _onSubmitted(
      LoginSubmitted event, Emitter<LoginState> emit) async {
    if (!state.isValid) return;
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      await _authRepository.signInWithEmailAndPassword(
        email: state.email.value,
        password: state.password.value,
      );

      Log.info("LoginBloc: signInWithEmailAndPassword successful.");

      // Emit a success state WITHOUT a successMessage.
      // This will trigger the navigation in the UI.
      emit(state.copyWith(status: FormzSubmissionStatus.success));
      
    } on AuthException catch (e) {
      // Handle local authentication exceptions with specific error messages
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

  /// Handles the password reset request event.
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
      await _authRepository.sendPasswordResetEmail(email: state.email.value);

      // Emit a success state WITH a successMessage.
      // This will trigger the SnackBar in the UI.
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

  /// Map authentication error messages to user-friendly text
  String _mapAuthErrorToMessage(String errorMessage) {
    final lowerMessage = errorMessage.toLowerCase();
    
    if (lowerMessage.contains('no user found') || lowerMessage.contains('not found')) {
      return 'No account found with this email. Please sign up.';
    } else if (lowerMessage.contains('incorrect password') || lowerMessage.contains('wrong password')) {
      return 'Incorrect password. Please try again.';
    } else if (lowerMessage.contains('invalid email')) {
      return 'Invalid email address format.';
    } else if (lowerMessage.contains('too many')) {
      return 'Too many login attempts. Please try again later.';
    } else if (lowerMessage.contains('disabled') || lowerMessage.contains('suspended')) {
      return 'This account has been disabled. Please contact support.';
    } else {
      return errorMessage;
    }
  }
}
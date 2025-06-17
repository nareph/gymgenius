import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:gymgenius/repositories/auth_repository.dart';
import 'package:gymgenius/services/logger_service.dart';

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

      //await Future.delayed(const Duration(milliseconds: 500));

      // Emit a success state WITHOUT a successMessage.
      // This will trigger the navigation in the UI.
      emit(state.copyWith(status: FormzSubmissionStatus.success));
      // emit(state.copyWith(status: FormzSubmissionStatus.initial));
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: "Login failed. Please check your credentials.",
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
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: "Failed to send reset email. Please try again.",
      ));
    }
  }
}

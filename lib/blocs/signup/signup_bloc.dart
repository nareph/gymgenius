// lib/blocs/signup/signup_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/blocs/signup/signup_event.dart';
import 'package:gymgenius/blocs/signup/signup_state.dart';
import 'package:gymgenius/repositories/auth_repository.dart';
import 'package:gymgenius/services/logger_service.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final AuthRepository _authRepository;

  SignUpBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const SignUpState()) {
    on<SignUpEmailChanged>(_onEmailChanged);
    on<SignUpPasswordChanged>(_onPasswordChanged);
    on<SignUpSubmitted>(_onSubmitted);
  }

  void _onEmailChanged(SignUpEmailChanged event, Emitter<SignUpState> emit) {
    emit(state.copyWith(
      email: event.email,
      status: SignUpStatus.initial,
      errorMessage: null,
    ));
  }

  void _onPasswordChanged(
      SignUpPasswordChanged event, Emitter<SignUpState> emit) {
    emit(state.copyWith(
      password: event.password,
      status: SignUpStatus.initial,
      errorMessage: null,
    ));
  }

  Future<void> _onSubmitted(
      SignUpSubmitted event, Emitter<SignUpState> emit) async {
    if (state.email.isEmpty || state.password.isEmpty) {
      emit(state.copyWith(
        status: SignUpStatus.failure,
        errorMessage: 'Email and password cannot be empty',
      ));
      return;
    }

    emit(state.copyWith(status: SignUpStatus.loading));

    try {
      Log.debug('SignUpBloc: Creating account...');

      await _authRepository.signUp(
        email: state.email,
        password: state.password,
        onboardingData: event.onboardingData,
      );

      Log.debug('SignUpBloc: Account created successfully');
      emit(state.copyWith(status: SignUpStatus.success));
    } catch (e) {
      Log.error('SignUpBloc: Sign up failed', error: e);
      emit(state.copyWith(
        status: SignUpStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}

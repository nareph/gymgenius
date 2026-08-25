import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gymgenius/core/exceptions/auth_exception.dart';
import 'package:gymgenius/core/logger/logger_service.dart';
import 'package:gymgenius/domain/repositories/auth_repository.dart';

part 'signup_event.dart';
part 'signup_state.dart';

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

  void _onEmailChanged(
    SignUpEmailChanged event,
    Emitter<SignUpState> emit,
  ) {
    emit(
      state.copyWith(
        email: event.email,
        status: SignUpStatus.initial,
        errorMessage: null,
      ),
    );
  }

  void _onPasswordChanged(
    SignUpPasswordChanged event,
    Emitter<SignUpState> emit,
  ) {
    emit(
      state.copyWith(
        password: event.password,
        status: SignUpStatus.initial,
        errorMessage: null,
      ),
    );
  }

  Future<void> _onSubmitted(
    SignUpSubmitted event,
    Emitter<SignUpState> emit,
  ) async {
    final email = event.email.trim();
    final password = event.password;

    if (email.isEmpty || password.isEmpty) {
      emit(
        state.copyWith(
          status: SignUpStatus.failure,
          errorMessage: 'Email and password cannot be empty',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: SignUpStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      Log.debug('SignUpBloc: Creating account...');

      await _authRepository.signUp(email, password);

      Log.debug('SignUpBloc: Account created successfully');

      emit(
        state.copyWith(
          status: SignUpStatus.success,
          errorMessage: null,
        ),
      );
    } on AuthException catch (e) {
      Log.error('SignUpBloc: Auth error', error: e);

      emit(
        state.copyWith(
          status: SignUpStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      Log.error('SignUpBloc: Sign up failed', error: e);

      emit(
        state.copyWith(
          status: SignUpStatus.failure,
          errorMessage: 'Failed to create account. Please try again.',
        ),
      );
    }
  }
}

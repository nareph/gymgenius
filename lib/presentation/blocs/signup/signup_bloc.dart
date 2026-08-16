import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/core/exceptions/auth_exception.dart';
import 'package:gymgenius/core/logger/logger_service.dart';
import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/enums/activity_level.dart';
import 'package:gymgenius/domain/enums/budget_level.dart';
import 'package:gymgenius/domain/enums/experience_level.dart';
import 'package:gymgenius/domain/enums/fitness_goal.dart';
import 'package:gymgenius/domain/enums/gender.dart';
import 'package:gymgenius/domain/enums/session_duration.dart';
import 'package:gymgenius/domain/enums/workout_frequency.dart';
import 'package:gymgenius/domain/repositories/auth_repository.dart';
import 'package:gymgenius/domain/value_objects/body_measurements.dart';
import 'package:gymgenius/domain/value_objects/lifestyle_preferences.dart';
import 'package:gymgenius/domain/value_objects/workout_preferences.dart';

part 'signup_event.dart';
part 'signup_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final AuthRepository _authRepository;

  SignUpBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
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

    // A profile is no longer collected before sign-up — onboarding now
    // happens AFTER account creation (HomeTabScreen gates program
    // generation behind CompleteProfileView, not account creation
    // itself). When none was provided (the normal path now), build an
    // empty, explicitly-unanswered HealthProfile: answeredQuestionIds
    // stays empty, so HealthProfile.isComplete correctly reports false
    // and missingFieldIds lists every required field — the existing
    // CompleteProfileView gate picks this up with no separate code path.
    final profile = event.profile ?? _emptyProfile();

    emit(state.copyWith(status: SignUpStatus.loading));

    try {
      Log.debug('SignUpBloc: Creating account...');
      await _authRepository.signUp(
        state.email,
        state.password,
        profile,
      );
      Log.debug('SignUpBloc: Account created successfully');
      emit(state.copyWith(status: SignUpStatus.success));
    } on AuthException catch (e) {
      Log.error('SignUpBloc: Auth error', error: e);
      emit(state.copyWith(
        status: SignUpStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      Log.error('SignUpBloc: Sign up failed', error: e);
      emit(state.copyWith(
        status: SignUpStatus.failure,
        errorMessage: 'Failed to create account. Please try again.',
      ));
    }
  }

  /// All field VALUES here are arbitrary placeholders — never read
  /// anywhere, since `HealthProfile.isComplete` is false (empty
  /// `answeredQuestionIds`) until the user actually answers the
  /// onboarding questions. `userId` is overwritten by
  /// AuthRepositoryImpl.signUp() via `profile.copyWith(userId: uid)`.
  HealthProfile _emptyProfile() {
    final now = DateTime.now();
    return HealthProfile(
      userId: '',
      body: BodyMeasurements(
        age: 0,
        heightCm: 0,
        currentWeightKg: 0,
        gender: Gender.male,
      ),
      training: WorkoutPreferences(
        goal: FitnessGoal.generalFitness,
        experience: ExperienceLevel.beginner,
        activityLevel: ActivityLevel.moderatelyActive,
        frequency: WorkoutFrequency.threeToFour,
        sessionDuration: SessionDuration.medium45,
        preferredDays: const [],
        equipment: const [],
        focusAreas: const [],
      ),
      lifestyle: const LifestylePreferences(
        country: '',
        budget: BudgetLevel.medium,
      ),
      answeredQuestionIds: const [],
      createdAt: now,
      updatedAt: now,
    );
  }
}

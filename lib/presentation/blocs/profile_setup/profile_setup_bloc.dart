import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:gymgenius/core/logger/logger_service.dart';
import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/repositories/auth_repository.dart';
import 'package:gymgenius/domain/repositories/health_repository.dart';
import 'package:gymgenius/presentation/mappers/profile_setup_mapper.dart';

part 'profile_setup_event.dart';
part 'profile_setup_state.dart';

class ProfileSetupBloc extends Bloc<ProfileSetupEvent, ProfileSetupState> {
  final HealthRepository _healthRepository;
  final AuthRepository _authRepository;

  ProfileSetupBloc({
    required HealthRepository healthRepository,
    required AuthRepository authRepository,
    Map<String, dynamic>? initialAnswers,
  })  : _healthRepository = healthRepository,
        _authRepository = authRepository,
        super(ProfileSetupState(answers: initialAnswers ?? const {})) {
    on<UpdateAnswer>(_onUpdateAnswer);
    on<CompleteProfileSetup>(_onComplete);
  }

  void _onUpdateAnswer(
    UpdateAnswer event,
    Emitter<ProfileSetupState> emit,
  ) {
    final newAnswers = Map<String, dynamic>.from(state.answers);
    newAnswers[event.questionId] = event.answerValue;
    emit(state.copyWith(answers: newAnswers));
  }

  Future<void> _onComplete(
    CompleteProfileSetup event,
    Emitter<ProfileSetupState> emit,
  ) async {
    Log.debug('ProfileSetupBloc: Completing profile setup');

    try {
      // 1. Build the domain HealthProfile from raw answers.
      var profile = ProfileSetupMapper.toDomain(state.answers);

      // 2. Retrieve the current authenticated user ID.
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      // 3. Assign the correct userId to the profile.
      profile = profile.copyWith(userId: currentUser.id);

      // 4. Save the profile (it will be created, not updated).
      await _healthRepository.saveHealthProfile(profile);

      Log.debug('ProfileSetupBloc: Profile saved successfully');

      emit(state.copyWith(
        profile: profile,
        status: ProfileSetupStatus.complete,
      ));
    } catch (e) {
      Log.error('ProfileSetupBloc: Failed to save profile', error: e);
      emit(state.copyWith(
        status: ProfileSetupStatus.error,
        errorMessage: 'Failed to save profile: $e',
      ));
    }
  }
}

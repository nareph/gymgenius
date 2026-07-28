import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gymgenius/core/logger/logger_service.dart';
import 'package:gymgenius/presentation/mappers/profile_setup_mapper.dart';
import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/repositories/health_repository.dart';

part 'profile_setup_event.dart';
part 'profile_setup_state.dart';

class ProfileSetupBloc extends Bloc<ProfileSetupEvent, ProfileSetupState> {
  final HealthRepository? _healthRepository;

  /// [initialAnswers] lets the screen resume an in-progress profile with
  /// pre-filled values when a page for an already-answered question is
  /// revisited in the same session. For cross-session resume (after an
  /// app restart), ProfileSetupScreen instead filters WHICH questions to
  /// show using `HealthProfile.missingFieldIds` — it doesn't need the
  /// previous raw values, since only unanswered questions are shown.
  ProfileSetupBloc({
    HealthRepository? healthRepository,
    Map<String, dynamic>? initialAnswers,
  })  : _healthRepository = healthRepository,
        super(ProfileSetupState(answers: initialAnswers ?? const {})) {
    on<UpdateAnswer>(_onUpdateAnswer);
    on<CompleteProfileSetup>(_onComplete);
  }

  void _onUpdateAnswer(UpdateAnswer event, Emitter<ProfileSetupState> emit) {
    final newAnswers = Map<String, dynamic>.from(state.answers);
    newAnswers[event.questionId] = event.answerValue;
    emit(state.copyWith(answers: newAnswers));
  }

  Future<void> _onComplete(
      CompleteProfileSetup event, Emitter<ProfileSetupState> emit) async {
    Log.debug('ProfileSetupBloc: Completing profile setup');

    // Build HealthProfile from collected answers. `answeredQuestionIds` is
    // computed inside the mapper and travels with the profile — no
    // separate persistence step needed.
    try {
      final profile = ProfileSetupMapper.toDomain(state.answers);
      emit(state.copyWith(
          profile: profile, status: ProfileSetupStatus.complete));

      if (event.isPostLogin && _healthRepository != null) {
        await _healthRepository!.saveHealthProfile(profile);
        Log.debug('ProfileSetupBloc: Profile saved for existing user');
      }
    } catch (e) {
      Log.error('ProfileSetupBloc: Failed to build profile', error: e);
      emit(state.copyWith(
        status: ProfileSetupStatus.error,
        errorMessage: 'Failed to build profile: $e',
      ));
    }
  }
}

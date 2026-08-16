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

    try {
      var profile = ProfileSetupMapper.toDomain(state.answers);

      if (event.isPostLogin && _healthRepository != null) {
        // ProfileSetupMapper.toDomain() only knows about the answers
        // collected in THIS session — it has no way to know which user
        // this belongs to, so it can't set a correct userId. Without
        // this fix, saveHealthProfile() writes under whatever
        // placeholder/empty userId the mapper defaults to, while
        // AuthBloc's re-check reads by the REAL current user id and
        // finds nothing there — the save silently goes nowhere, and the
        // app keeps reporting every field missing right after
        // completion. Fetching the existing (empty, placeholder)
        // profile created at sign-up and carrying its real userId over
        // fixes this — we're completing that record, not replacing it.
        final existing = await _healthRepository!.getCurrentProfile();
        if (existing != null) {
          profile = profile.copyWith(userId: existing.userId);
        }

        await _healthRepository!.saveHealthProfile(profile);
        Log.debug('ProfileSetupBloc: Profile saved for existing user');
      }

      emit(state.copyWith(
        profile: profile,
        status: ProfileSetupStatus.complete,
      ));
    } catch (e) {
      Log.error('ProfileSetupBloc: Failed to build profile', error: e);
      emit(state.copyWith(
        status: ProfileSetupStatus.error,
        errorMessage: 'Failed to build profile: $e',
      ));
    }
  }
}

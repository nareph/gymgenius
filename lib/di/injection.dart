// lib/di/injection.dart

import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:gymgenius/data/repositories/auth_repository_impl.dart';
import 'package:gymgenius/data/repositories/health_repository_impl.dart';
import 'package:gymgenius/data/repositories/tracking_repository_impl.dart';
import 'package:gymgenius/data/repositories/user_repository_impl.dart';
import 'package:gymgenius/data/repositories/workout_repository_impl.dart';

import 'package:gymgenius/domain/repositories/auth_repository.dart';
import 'package:gymgenius/domain/repositories/health_repository.dart';
import 'package:gymgenius/domain/repositories/tracking_repository.dart';
import 'package:gymgenius/domain/repositories/user_repository.dart';
import 'package:gymgenius/domain/repositories/workout_repository.dart';
import 'package:gymgenius/engines/workout_engine/optimizers/local_program_optimizer.dart';
import 'package:gymgenius/engines/workout_engine/optimizers/program_optimizer.dart';
import 'package:gymgenius/engines/workout_engine/services/generation_service.dart';
import 'package:gymgenius/engines/workout_engine/workout_engine.dart';

import 'package:gymgenius/presentation/blocs/auth/auth_bloc.dart';
import 'package:gymgenius/presentation/blocs/exercise_library/exercise_library_bloc.dart';
import 'package:gymgenius/presentation/blocs/login/login_bloc.dart';
import 'package:gymgenius/presentation/blocs/signup/signup_bloc.dart';

import 'package:gymgenius/presentation/providers/workout_session_manager.dart';

import 'package:gymgenius/presentation/viewmodels/home_viewmodel.dart';
import 'package:gymgenius/presentation/viewmodels/profile_viewmodel.dart';
import 'package:gymgenius/presentation/viewmodels/tracking_viewmodel.dart';
// ExerciseLoggingViewModel and ActiveWorkoutViewModel are not registered here
// because they require BuildContext or dynamic Exercise parameters.

final getIt = GetIt.instance;

void setupDependencies() {
  // ============================================================
  // Secure Storage
  // ============================================================
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // ============================================================
  // Repositories
  // ============================================================
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(),
  );
  getIt.registerLazySingleton<HealthRepository>(
    () => HealthRepositoryImpl(),
  );
  getIt.registerLazySingleton<WorkoutRepository>(
    () => WorkoutRepositoryImpl(),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      userRepository: getIt<UserRepository>(),
      healthRepository: getIt<HealthRepository>(),
      secureStorage: getIt<FlutterSecureStorage>(),
    ),
  );

  getIt.registerLazySingleton<TrackingRepository>(
    () => TrackingRepositoryImpl(
      workoutRepository: getIt<WorkoutRepository>(),
    ),
  );

  // ============================================================
  // Workout Engine
  // ============================================================
  getIt.registerFactory<ProgramOptimizer>(() => const LocalProgramOptimizer());

  getIt.registerLazySingleton<GenerationService>(() => GenerationService());
  getIt.registerLazySingleton<WorkoutEngine>(() => WorkoutEngine());

  // ============================================================
  // Providers (ChangeNotifier)
  // ============================================================
  getIt.registerLazySingleton<WorkoutSessionManager>(
    () => WorkoutSessionManager(),
  );

  // ============================================================
  // BLoCs
  // ============================================================
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      authRepository: getIt<AuthRepository>(),
      healthRepository: getIt<HealthRepository>(),
    ),
  );

  getIt.registerFactory<LoginBloc>(
    () => LoginBloc(
      authRepository: getIt<AuthRepository>(),
    ),
  );

  getIt.registerFactory<SignUpBloc>(
    () => SignUpBloc(
      authRepository: getIt<AuthRepository>(),
    ),
  );

  // Exercise Library
  getIt.registerFactory(() => ExerciseLibraryBloc());

  // ============================================================
  // ViewModels
  // ============================================================
  getIt.registerFactory<HomeViewModel>(
    () => HomeViewModel(
      workoutEngine: getIt<WorkoutEngine>(),
      userRepository: getIt<UserRepository>(),
      healthRepository: getIt<HealthRepository>(),
    ),
  );

  getIt.registerFactory<TrackingViewModel>(
    () => TrackingViewModel(
      workoutRepository: getIt<WorkoutRepository>(),
      trackingRepository: getIt<TrackingRepository>(),
      userRepository: getIt<UserRepository>(),
    ),
  );

  getIt.registerFactory<ProfileViewModel>(
    () => ProfileViewModel(
      healthRepository: getIt<HealthRepository>(),
      userRepository: getIt<UserRepository>(),
    ),
  );

  // ============================================================
  // Note: ExerciseLoggingViewModel and ActiveWorkoutViewModel
  // are not registered here because they depend on dynamic
  // parameters (Exercise, BuildContext). They should be
  // instantiated directly in the UI where the context and
  // exercise are available.
  // ============================================================
}

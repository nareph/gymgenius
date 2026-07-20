// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/blocs/auth/auth_bloc.dart';
import 'package:gymgenius/providers/workout_session_manager.dart';
import 'package:gymgenius/repositories/auth_repository.dart';
import 'package:gymgenius/repositories/home_repository.dart';
import 'package:gymgenius/repositories/profile_repository.dart';
import 'package:gymgenius/repositories/tracking_repository.dart';
import 'package:gymgenius/repositories/workout_repository.dart';
import 'package:gymgenius/services/ai_service.dart';
import 'package:gymgenius/services/database_service.dart';
import 'package:gymgenius/services/logger_service.dart';
import 'package:gymgenius/services/workout_service.dart';
import 'package:gymgenius/theme/app_theme.dart';
import 'package:gymgenius/viewmodels/home_viewmodel.dart';
import 'package:gymgenius/viewmodels/profile_viewmodel.dart';
import 'package:gymgenius/viewmodels/tracking_viewmodel.dart';
import 'package:gymgenius/widgets/auth_wrapper.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseService.initialize();

  Log.info('--- GymGenius Started (Local Database Mode) ---');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepository(),
        ),
        RepositoryProvider<WorkoutRepository>(
          create: (_) => WorkoutRepository(),
        ),
        RepositoryProvider<AIService>(
          create: (_) => AIService(),
        ),
        RepositoryProvider<WorkoutService>(
          create: (context) => WorkoutService(
            repository: context.read<WorkoutRepository>(),
            aiService: context.read<AIService>(),
          ),
        ),
        RepositoryProvider<HomeRepository>(
          create: (context) => HomeRepository(
            workoutRepository: context.read<WorkoutRepository>(),
            workoutService: context.read<WorkoutService>(),
          ),
        ),
        RepositoryProvider<TrackingRepository>(
          create: (_) => TrackingRepository(),
        ),
        RepositoryProvider<ProfileRepository>(
          create: (_) => ProfileRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          ChangeNotifierProvider(
            create: (context) => WorkoutSessionManager(),
          ),
          ChangeNotifierProvider(
            create: (context) => HomeViewModel(context.read<HomeRepository>()),
          ),
          ChangeNotifierProvider(
            create: (context) => TrackingViewModel(context.read()),
          ),
          ChangeNotifierProvider(
            create: (context) => ProfileViewModel(context.read()),
          ),
        ],
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymGenius',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

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
import 'package:gymgenius/services/database_service.dart';
import 'package:gymgenius/services/logger_service.dart';
import 'package:gymgenius/theme/app_theme.dart';
import 'package:gymgenius/viewmodels/home_viewmodel.dart';
import 'package:gymgenius/viewmodels/profile_viewmodel.dart';
import 'package:gymgenius/viewmodels/tracking_viewmodel.dart';
import 'package:gymgenius/widgets/auth_wrapper.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive database
  await DatabaseService.initialize();

  Log.info("--- GymGenius Started (Local Database Mode) ---");

  runApp(const MyApp());
}

/// The root widget of the application. Its primary role is to provide
/// all necessary dependencies (Repositories, BLoCs, ViewModels) to the entire app.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepository(),
        ),
        RepositoryProvider<HomeRepository>(
          create: (_) => HomeRepository(),
        ),
        RepositoryProvider<TrackingRepository>(
          create: (_) => TrackingRepository(),
        ),
        RepositoryProvider<ProfileRepository>(
          create: (_) => ProfileRepository(),
        ),
        RepositoryProvider<WorkoutRepository>(
          create: (_) => WorkoutRepository(),
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
            create: (context) => HomeViewModel(context.read()),
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

/// AppView builds the MaterialApp and contains the root Navigator
/// that will be controlled by the AuthBloc's state.
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

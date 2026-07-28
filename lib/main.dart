// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/core/logger/logger_service.dart';
import 'package:gymgenius/data/datasources/local/hive/boxes/hive_datasource.dart';
import 'package:gymgenius/di/injection.dart';
import 'package:gymgenius/presentation/blocs/auth/auth_bloc.dart';
import 'package:gymgenius/presentation/blocs/login/login_bloc.dart';
import 'package:gymgenius/presentation/blocs/signup/signup_bloc.dart';
import 'package:gymgenius/presentation/providers/workout_session_manager.dart';
import 'package:gymgenius/presentation/theme/app_theme.dart';
import 'package:gymgenius/presentation/viewmodels/home_viewmodel.dart';
import 'package:gymgenius/presentation/viewmodels/profile_viewmodel.dart';
import 'package:gymgenius/presentation/viewmodels/tracking_viewmodel.dart';
import 'package:gymgenius/presentation/widgets/auth_wrapper.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveDatasource.initialize();
  setupDependencies();

  Log.info('--- GymGenius Started (Local Database Mode) ---');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // BLoC
        BlocProvider<AuthBloc>(
          create: (context) => getIt<AuthBloc>(),
        ),
        BlocProvider<LoginBloc>(
          create: (context) => getIt<LoginBloc>(),
        ),
        BlocProvider<SignUpBloc>(
          create: (context) => getIt<SignUpBloc>(),
        ),
        // Providers
        ChangeNotifierProvider(
          create: (context) => getIt<WorkoutSessionManager>(),
        ),
        ChangeNotifierProvider<HomeViewModel>(
          create: (context) => getIt<HomeViewModel>(),
        ),
        ChangeNotifierProvider<TrackingViewModel>(
          create: (context) => getIt<TrackingViewModel>(),
        ),
        ChangeNotifierProvider<ProfileViewModel>(
          create: (context) => getIt<ProfileViewModel>(),
        ),
      ],
      child: const AppView(),
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

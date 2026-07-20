// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gymgenius/screens/auth/login_screen.dart';
import 'package:gymgenius/screens/auth/sign_up_screen.dart';
import 'package:gymgenius/screens/onboarding/onboarding_screen.dart';
import 'package:gymgenius/services/database_service.dart';
import 'package:gymgenius/services/logger_service.dart';
import 'package:gymgenius/widgets/data_loss_warning_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const HomeScreen());
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  _HomeView _currentView = _HomeView.landing;
  Map<String, dynamic>? _onboardingData;
  final _secureStorage = const FlutterSecureStorage();

  void _showLogin() {
    setState(() {
      _currentView = _HomeView.login;
      Log.debug('HomeScreen: Switched to login view');
    });
  }

  void _showSignUp(Map<String, dynamic>? onboardingData) {
    setState(() {
      _currentView = _HomeView.signUp;
      _onboardingData = onboardingData;
      Log.debug('HomeScreen: Switched to signup view with data');
    });
  }

  /// Check if user exists and show warning dialog if needed
  Future<void> _showOnboarding() async {
    Log.debug('HomeScreen: _showOnboarding called');

    final db = DatabaseService.instance;
    // Vérifier les nouvelles boxes : users, programs, weekly_workouts, workout_logs
    final hasExistingData = db.users.isNotEmpty ||
        db.programs.isNotEmpty ||
        db.weeklyWorkouts.isNotEmpty ||
        db.workoutLogs.isNotEmpty;

    Log.debug('HomeScreen: Has existing data? $hasExistingData');
    Log.debug('  - Users: ${db.users.length}');
    Log.debug('  - Programs: ${db.programs.length}');
    Log.debug('  - Weekly Workouts: ${db.weeklyWorkouts.length}');
    Log.debug('  - Logs: ${db.workoutLogs.length}');

    if (hasExistingData) {
      Log.debug('HomeScreen: Showing data loss warning dialog');

      final confirmed = await DataLossWarningDialog.show(context);

      Log.debug('HomeScreen: User confirmed? $confirmed');

      if (confirmed != true) {
        Log.debug('HomeScreen: User cancelled');
        return;
      }

      Log.warning('HomeScreen: User confirmed deletion, clearing data...');
      await _clearAllUserData();
      Log.info('HomeScreen: Data cleared, verification:');
      Log.info('  - Users: ${db.users.length}');
      Log.info('  - Programs: ${db.programs.length}');
      Log.info('  - Weekly Workouts: ${db.weeklyWorkouts.length}');
      Log.info('  - Logs: ${db.workoutLogs.length}');
    }

    setState(() {
      _currentView = _HomeView.onboarding;
    });
  }

  /// Clear ALL user data (Hive + FlutterSecureStorage)
  Future<void> _clearAllUserData() async {
    try {
      Log.warning('═══════════════════════════════════════════════════');
      Log.warning('HomeScreen: USER CONFIRMED DATA DELETION');
      Log.warning('═══════════════════════════════════════════════════');

      // 1. Clear Hive database (handles all boxes)
      await DatabaseService.instance.clearAllData();

      // 2. Clear FlutterSecureStorage
      final allKeys = await _secureStorage.readAll();
      int deletedCount = 0;

      for (var key in allKeys.keys) {
        if (key.startsWith('uid_') ||
            key.startsWith('password_') ||
            key.startsWith('reset_token_')) {
          await _secureStorage.delete(key: key);
          deletedCount++;
        }
      }

      Log.debug(
          'HomeScreen: Deleted $deletedCount credential(s) from secure storage');
      Log.warning('HomeScreen: ✅ ALL DATA WIPED SUCCESSFULLY');
      Log.warning('═══════════════════════════════════════════════════');
    } catch (e, s) {
      Log.error('HomeScreen: ❌ FAILED to clear data', error: e, stackTrace: s);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _buildCurrentView(),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case _HomeView.landing:
        return _LandingPage(
          key: const ValueKey('landing'),
          onGetStarted: _showOnboarding,
          onLogin: _showLogin,
        );
      case _HomeView.login:
        return LoginScreen(
          key: const ValueKey('login'),
          onSignUpRequested: _showOnboarding,
        );
      case _HomeView.onboarding:
        return OnboardingScreen(
          key: const ValueKey('onboarding'),
          isPostLoginCompletion: false,
          onSignUpRequested: _showSignUp,
        );
      case _HomeView.signUp:
        return SignUpScreen(
          key: const ValueKey('signup'),
          onboardingData: _onboardingData,
          onLoginRequested: _showLogin,
        );
    }
  }
}

enum _HomeView {
  landing,
  login,
  onboarding,
  signUp,
}

class _LandingPage extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onLogin;

  const _LandingPage({
    super.key,
    required this.onGetStarted,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surface,
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.08,
              vertical: screenHeight * 0.05,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Logo
                Image.asset(
                  'assets/launcher_icon/launcher_icon.png',
                  height: screenHeight * 0.15,
                  errorBuilder: (context, error, stackTrace) {
                    Log.error('Failed to load app logo',
                        error: error, stackTrace: stackTrace);
                    return Icon(
                      Icons.fitness_center,
                      size: screenHeight * 0.15,
                      color: colorScheme.primary,
                    );
                  },
                ),
                SizedBox(height: screenHeight * 0.02),

                // App Title
                Text(
                  "GYMGENIUS",
                  textAlign: TextAlign.center,
                  style: textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),

                // App Tagline
                Text(
                  "Your AI-Powered Fitness Coach",
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface.withAlpha(217),
                  ),
                ),
                SizedBox(height: screenHeight * 0.1),

                // "Get Started" Button
                ElevatedButton(
                  onPressed: () {
                    Log.debug('User tapped GET STARTED button');
                    onGetStarted();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("GET STARTED"),
                ),
                SizedBox(height: screenHeight * 0.025),

                // "Log In" Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withAlpha(204),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Log.debug('User tapped Log In button');
                        onLogin();
                      },
                      child: Text(
                        "Log In",
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

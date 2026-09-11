import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gymgenius/core/logger/logger_service.dart';
import 'package:gymgenius/data/datasources/local/hive/boxes/hive_datasource.dart';
import 'package:gymgenius/presentation/screens/auth/login_screen.dart';
import 'package:gymgenius/presentation/screens/auth/sign_up_screen.dart';
import 'package:gymgenius/presentation/widgets/data_loss_warning_dialog.dart';

/// NOTE: This screen no longer routes through ProfileSetupScreen before
/// account creation. Onboarding now happens AFTER sign-up (see
/// AuthWrapper -> HomeTabScreen's CompleteProfileView gate) — "Get
/// Started" goes straight to account creation with an empty profile;
/// SignUpBloc fills in a placeholder HealthProfile when none is
/// provided. This avoids asking for 11 answers before the user even has
/// an account to lose if they drop off partway through.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const HomeScreen(),
    );
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  _HomeView _currentView = _HomeView.landing;

  final _secureStorage = const FlutterSecureStorage();

  void _showLogin() {
    setState(() {
      _currentView = _HomeView.login;
      Log.debug('HomeScreen: Switched to login view');
    });
  }

  void _showSignUp() {
    setState(() {
      _currentView = _HomeView.signUp;
      Log.debug('HomeScreen: Switched to signup view');
    });
  }

  /// Checks for stale local data (e.g. a previous session that wasn't
  /// cleanly signed out) before starting a brand new account, then
  /// proceeds to sign-up.
  Future<void> _startSignUp() async {
    Log.debug('HomeScreen: _startSignUp called');

    final hasExistingData = HiveDatasource.getAllUsers().isNotEmpty ||
        HiveDatasource.getCurrentUserId() != null;

    Log.debug(
      'HomeScreen: Has existing data? $hasExistingData',
    );

    if (hasExistingData) {
      Log.debug(
        'HomeScreen: Showing data loss warning dialog',
      );

      final confirmed = await DataLossWarningDialog.show(
        context,
      );

      Log.debug(
        'HomeScreen: User confirmed? $confirmed',
      );

      if (confirmed != true) {
        Log.debug(
          'HomeScreen: User cancelled',
        );

        return;
      }

      Log.warning(
        'HomeScreen: User confirmed deletion, clearing data...',
      );

      await _clearAllUserData();
    }

    if (!mounted) {
      return;
    }

    _showSignUp();
  }

  /// Clear ALL user data (Hive + FlutterSecureStorage).
  Future<void> _clearAllUserData() async {
    try {
      Log.warning(
        '═══════════════════════════════════════════════════',
      );
      Log.warning(
        'HomeScreen: USER CONFIRMED DATA DELETION',
      );
      Log.warning(
        '═══════════════════════════════════════════════════',
      );

      await HiveDatasource.clearAll();

      final allKeys = await _secureStorage.readAll();

      int deletedCount = 0;

      for (final key in allKeys.keys) {
        if (key.startsWith('uid_') ||
            key.startsWith('password_') ||
            key.startsWith('reset_token_')) {
          await _secureStorage.delete(
            key: key,
          );

          deletedCount++;
        }
      }

      Log.debug(
        'HomeScreen: Deleted '
        '$deletedCount credential(s) from secure storage',
      );

      Log.warning(
        'HomeScreen: ✅ ALL DATA WIPED SUCCESSFULLY',
      );

      Log.warning(
        '═══════════════════════════════════════════════════',
      );
    } catch (e, s) {
      Log.error(
        'HomeScreen: ❌ FAILED to clear data',
        error: e,
        stackTrace: s,
      );

      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(
        milliseconds: 300,
      ),
      transitionBuilder: (
        Widget child,
        Animation<double> animation,
      ) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: _buildCurrentView(),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case _HomeView.landing:
        return _LandingPage(
          key: const ValueKey('landing'),
          onGetStarted: _startSignUp,
          onLogin: _showLogin,
        );

      case _HomeView.login:
        return LoginScreen(
          key: const ValueKey('login'),
          onSignUpRequested: _startSignUp,
        );

      case _HomeView.signUp:
        return SignUpScreen(
          key: const ValueKey('signUp'),
          onLoginRequested: _showLogin,
        );
    }
  }
}

enum _HomeView {
  landing,
  login,
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
                Image.asset(
                  'assets/launcher_icon/launcher_icon.png',
                  height: screenHeight * 0.15,
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    Log.error(
                      'Failed to load app logo',
                      error: error,
                      stackTrace: stackTrace,
                    );

                    return Icon(
                      Icons.fitness_center,
                      size: screenHeight * 0.15,
                      color: colorScheme.primary,
                    );
                  },
                ),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                Text(
                  'NUVORA',
                  textAlign: TextAlign.center,
                  style: textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.01,
                ),
                Text(
                  'Your Personal Health Intelligence',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface.withAlpha(217),
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.1,
                ),
                ElevatedButton(
                  onPressed: () {
                    Log.debug(
                      'User tapped GET STARTED button',
                    );

                    onGetStarted();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'GET STARTED',
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.025,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withAlpha(204),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Log.debug(
                          'User tapped Log In button',
                        );

                        onLogin();
                      },
                      child: Text(
                        'Log In',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: screenHeight * 0.04,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

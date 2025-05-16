// lib/screens/main_dashboard_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymgenius/screens/tabs/home_tab_screen.dart';
import 'package:gymgenius/screens/tabs/profile_tab_screen.dart';
import 'package:gymgenius/screens/tabs/tracking_tab_screen.dart';
import 'package:gymgenius/services/logger_service.dart';

// Constants for tab indices
const int kHomeTabIndex = 0;
const int kTrackingTabIndex = 1;
const int kProfileTabIndex = 2;

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _selectedIndex = kHomeTabIndex;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final PageController _pageController;
  late final Stream<User?> _authStateChanges;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _authStateChanges = _auth.authStateChanges();
    _verifyAuthState();
  }

  Future<void> _verifyAuthState() async {
    try {
      final User? initialUser = _auth.currentUser;
      if (initialUser == null) {
        Log.warning('Current user is null during initialization');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _auth.currentUser == null) {
            Log.info('Redirecting to home screen due to null user');
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/home', (Route<dynamic> route) => false);
          }
        });
      } else {
        Log.debug('User ${initialUser.uid} successfully initialized dashboard');
      }
    } catch (e, stack) {
      Log.error('Error verifying auth state', error: e, stackTrace: stack);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    Log.debug('Dashboard resources disposed');
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (!mounted) return;
    setState(() {
      _selectedIndex = index;
      Log.debug('Tab changed to index: $index');
    });
  }

  void _navigateToTab(int index) {
    if (index >= kHomeTabIndex && index <= kProfileTabIndex) {
      _onItemTapped(index);
    } else {
      Log.warning('Invalid tab navigation attempt to index: $index');
    }
  }

  String _getAppBarTitle(int index, User user) {
    try {
      final displayName =
          user.displayName ?? user.email?.split('@').first ?? 'User';

      switch (index) {
        case kHomeTabIndex:
          return 'Welcome, $displayName!';
        case kTrackingTabIndex:
          return 'Your Progress';
        case kProfileTabIndex:
          return 'My Profile';
        default:
          Log.warning('Unexpected tab index: $index');
          return 'GymGenius';
      }
    } catch (e, stack) {
      Log.error('Error generating app bar title', error: e, stackTrace: stack);
      return 'GymGenius';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<User?>(
      stream: _authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          Log.debug('Waiting for auth state verification');
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          Log.warning('No authenticated user found');
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data!;
        Log.debug('Building dashboard for user ${user.uid}');

        final List<Widget> widgetOptions = <Widget>[
          HomeTabScreen(user: user, onNavigateToTab: _navigateToTab),
          TrackingTabScreen(user: user),
          ProfileTabScreen(user: user),
        ];

        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAppLogo(colorScheme),
                const SizedBox(width: 12),
                Text(
                  _getAppBarTitle(_selectedIndex, user),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: widgetOptions,
          ),
          bottomNavigationBar: _buildBottomNavBar(),
        );
      },
    );
  }

  Widget _buildAppLogo(ColorScheme colorScheme) {
    return Image.asset(
      'assets/launcher_icon/launcher_icon.png',
      width: 32,
      height: 32,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        Log.error('App logo load failed', error: error, stackTrace: stackTrace);
        return Icon(
          Icons.fitness_center,
          color: colorScheme.primary,
          size: 32,
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_filled),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.show_chart_outlined),
          activeIcon: Icon(Icons.show_chart),
          label: 'Tracking',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
    );
  }
}

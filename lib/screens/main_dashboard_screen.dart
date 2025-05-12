// lib/screens/main_dashboard_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymgenius/screens/tabs/home_tab_screen.dart';
import 'package:gymgenius/screens/tabs/profile_tab_screen.dart';
import 'package:gymgenius/screens/tabs/tracking_tab_screen.dart';

// Optional: Constants for tab indices for better readability and maintenance.
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
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    // Check if user is null here too, though AuthWrapper should prevent this screen
    // from being built if user is null initially.
    final User? initialUser = _auth.currentUser;
    if (initialUser == null) {
      // This scenario should ideally be caught by AuthWrapper earlier.
      // If it happens, it means something went wrong with the auth flow.
      // Navigate away or handle appropriately. For now, we'll rely on AuthWrapper.
      print(
          "MainDashboardScreen initState: currentUser is null. This should not happen if AuthWrapper is working.");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted)
          Navigator.of(context).pushReplacementNamed('/home'); // Or login
      });
    }
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (!mounted) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToTab(int index) {
    if (index >= 0 && index < 3) {
      _onItemTapped(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser; // Get user, can be null

    // If user becomes null while this screen is trying to build,
    // return an empty container. AuthWrapper will handle redirecting.
    if (user == null) {
      print(
          "MainDashboardScreen build: currentUser is null. Returning empty container.");
      // This allows AuthWrapper to take over when it processes the sign-out event.
      return const Scaffold(
          body: Center(
              child: CircularProgressIndicator())); // Or just SizedBox.shrink()
    }

    // If we reach here, user is not null.
    final List<Widget> widgetOptions = <Widget>[
      HomeTabScreen(
        user: user, // Now 'user' is guaranteed non-null by the check above
        onNavigateToTab: _navigateToTab,
      ),
      TrackingTabScreen(user: user),
      ProfileTabScreen(user: user),
    ];

    return Scaffold(
      appBar: AppBar(
        title:
            Text(_getAppBarTitle(_selectedIndex, user)), // Pass non-null user
        elevation: 1.0,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_max_outlined),
            activeIcon: Icon(Icons.home_max),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
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
      ),
    );
  }

  String _getAppBarTitle(int index, User user) {
    // User here is guaranteed non-null by build method check
    String? displayName = user.displayName;
    if (displayName == null || displayName.trim().isEmpty) {
      displayName = user.email?.split('@')[0];
    }

    switch (index) {
      case kHomeTabIndex:
        return 'Welcome, ${displayName ?? "User"}!';
      case kTrackingTabIndex:
        return 'Your Progress';
      case kProfileTabIndex:
        return 'My Profile';
      default:
        return 'GymGenius';
    }
  }
}

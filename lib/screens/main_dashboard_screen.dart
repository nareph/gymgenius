// lib/screens/main_dashboard_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/blocs/auth/auth_bloc.dart';
import 'package:gymgenius/screens/tabs/home_tab_screen.dart';
import 'package:gymgenius/screens/tabs/profile_tab_screen.dart';
import 'package:gymgenius/screens/tabs/tracking_tab_screen.dart';
import 'package:gymgenius/services/logger_service.dart';
import 'package:gymgenius/widgets/sync_status_widget.dart'; // Import the widget

const int kHomeTabIndex = 0;
const int kTrackingTabIndex = 1;
const int kProfileTabIndex = 2;

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const MainDashboardScreen());
  }

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _selectedIndex = kHomeTabIndex;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    });
  }

  void _navigateToTab(int index) {
    if (index >= kHomeTabIndex && index <= kProfileTabIndex) {
      _onItemTapped(index);
    }
  }

  String _getAppBarTitle(int index, User? user) {
    final displayName =
        user?.displayName ?? user?.email?.split('@').first ?? 'User';
    switch (index) {
      case kHomeTabIndex:
        return 'Welcome, $displayName!';
      case kTrackingTabIndex:
        return 'Your Progress';
      case kProfileTabIndex:
        return 'My Profile';
      default:
        return 'GymGenius';
    }
  }

  Widget _buildAppLogo() {
    return Image.asset(
      'assets/launcher_icon/launcher_icon.png',
      width: 32,
      height: 32,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        Log.error('App logo load failed', error: error, stackTrace: stackTrace);
        return const Icon(Icons.fitness_center, size: 32);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState.user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Authenticating...")));
    }

    final List<Widget> widgetOptions = <Widget>[
      HomeTabScreen(onNavigateToTab: _navigateToTab),
      const TrackingTabScreen(),
      const ProfileTabScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        // --- REINTEGRATION OF TITLE AND ACTIONS ---
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAppLogo(),
            const SizedBox(width: 12),
            Text(_getAppBarTitle(_selectedIndex, user)),
          ],
        ),
        centerTitle: true,
        actions: const [
          SyncStatusWidget(showInAppBar: true),
          SizedBox(width: 8), // Add some padding
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _selectedIndex = index);
        },
        children: widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_filled),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.show_chart_outlined),
              activeIcon: Icon(Icons.show_chart),
              label: 'Tracking'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

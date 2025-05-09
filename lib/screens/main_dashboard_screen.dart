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
// Add other indices if you have more tabs (e.g., kCommunityTabIndex = 2, then Profile would be 3).

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _selectedIndex = kHomeTabIndex; // Default to Home tab, using the constant
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // PageController is used if you opt for PageView instead of IndexedStack for tab navigation
  // and want programmatic control with animation. For IndexedStack, it's not strictly necessary
  // unless you need to jump to pages from outside the BottomNavigationBar.
  late PageController _pageController;

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

  // Called when a bottom navigation bar item is tapped.
  void _onItemTapped(int index) {
    if (!mounted) return;
    setState(() {
      _selectedIndex = index;
      // If using PageView with BottomNavigationBar, you would typically animate or jump:
      // _pageController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.ease);
      // _pageController.jumpToPage(index);
      // For IndexedStack, simply changing _selectedIndex is enough to switch the visible child.
    });
  }

  // This method can be called by child tabs (e.g., HomeTabScreen) to navigate to another tab.
  void _navigateToTab(int index) {
    // Ensure the index is valid for the number of tabs (currently 3: 0, 1, 2)
    if (index >= 0 && index < 3) {
      // Update '3' if you add more tabs
      _onItemTapped(index); // Reuses the same logic to update state and UI
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    // If no user is logged in, redirect to the home/login screen.
    if (user == null) {
      // Schedule navigation after the current build phase to avoid errors.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Check if the widget is still in the tree
          // '/home' should be your initial screen for unauthenticated users (e.g., your HomeScreen with Get Started/Login)
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      });
      // Display a loader while redirecting.
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Define the list of widget options for each tab.
    // Pass the `user` object and navigation callbacks where needed.
    final List<Widget> widgetOptions = <Widget>[
      HomeTabScreen(
        user: user,
        onNavigateToTab:
            _navigateToTab, // Pass the callback for inter-tab navigation
      ),
      TrackingTabScreen(user: user),
      ProfileTabScreen(user: user),
      // Add other tab screens here if necessary
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(_selectedIndex, user)),
        // automaticallyImplyLeading: false, // Set to true if you want a back button when pushed onto stack,
        // false if this is a root screen after login and no back navigation is desired.
        // Default behavior is usually fine.
        elevation: 1.0, // Subtle elevation for the AppBar
      ),
      // IndexedStack is used to preserve the state of each tab when switching.
      // PageView could also be used if different transition animations are desired.
      body: IndexedStack(
        index: _selectedIndex,
        children: widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        // `type: BottomNavigationBarType.fixed` is useful if you have 4+ items
        // to prevent the "shifting" animation and ensure all labels are visible.
        // For 3 items, `fixed` or `shifting` (default) behave similarly in terms of label visibility.
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons
                .home_max_outlined), // Using outlined version for consistency
            activeIcon: Icon(Icons.home_max), // Filled version when active
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons
                .bar_chart_outlined), // Alternative: Icons.timeline, Icons.show_chart
            activeIcon: Icon(Icons.bar_chart),
            label: 'Tracking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded), // Using outlined version
            activeIcon:
                Icon(Icons.person_rounded), // Filled version when active
            label: 'Profile',
          ),
          // Add other BottomNavigationBarItems here
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // Optional styling: these often come from BottomNavigationBarThemeData in AppTheme.
        // selectedItemColor: Theme.of(context).colorScheme.primary,
        // unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        // showUnselectedLabels: true, // Ensure unselected labels are visible
      ),
    );
  }

  // Helper function to determine the AppBar title based on the selected tab.
  String _getAppBarTitle(int index, User user) {
    String? displayName = user.displayName;
    // Fallback for display name if not set on Firebase User profile
    if (displayName == null || displayName.trim().isEmpty) {
      displayName = user.email?.split('@')[0]; // Use part of email before '@'
    }

    switch (index) {
      case kHomeTabIndex:
        return 'Welcome, ${displayName ?? "User"}!'; // More personalized welcome message
      case kTrackingTabIndex:
        return 'Your Progress';
      case kProfileTabIndex:
        return 'My Profile';
      // case kCommunityTabIndex: // Example if you add a community tab
      //   return 'Community';
      default:
        return 'GymGenius'; // Fallback title
    }
  }
}

// lib/screens/main_dashboard_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymgenius/screens/tabs/home_tab_screen.dart';
import 'package:gymgenius/screens/tabs/profile_tab_screen.dart';
import 'package:gymgenius/screens/tabs/tracking_tab_screen.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Plus besoin de _widgetOptions comme variable d'instance ici si on la construit dans build

  @override
  void initState() {
    super.initState();
    // Pas besoin d'initialiser _widgetOptions ici
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Construire la liste des widgets directement ici.
    // Elle sera reconstruite à chaque appel de build, ce qui est acceptable
    // car les onglets eux-mêmes sont des StatefulWidget et gèrent leur propre état.
    final List<Widget> widgetOptions = <Widget>[
      HomeTabScreen(user: user),
      TrackingTabScreen(user: user),
      ProfileTabScreen(user: user),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(
            _selectedIndex, user)), // Passer user pour le titre si besoin
      ),
      body: Center(
        // Ou utilisez IndexedStack pour préserver l'état des onglets
        // child: IndexedStack(
        //   index: _selectedIndex,
        //   children: widgetOptions,
        // ),
        child: widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Tracking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  String _getAppBarTitle(int index, User user) {
    // Ajout de User user si vous voulez l'utiliser
    switch (index) {
      case 0:
        // return 'Welcome, ${user.displayName ?? user.email?.split('@')[0]}'; // Exemple si vous voulez un message d'accueil
        return 'GymGenius';
      case 1:
        return 'Tracking';
      case 2:
        return 'Profile';
      default:
        return 'GymGenius';
    }
  }
}

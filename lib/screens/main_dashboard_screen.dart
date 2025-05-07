// lib/screens/main_dashboard_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymgenius/screens/tabs/home_tab_screen.dart';
import 'package:gymgenius/screens/tabs/profile_tab_screen.dart';
import 'package:gymgenius/screens/tabs/tracking_tab_screen.dart';

// Optionnel: Constantes pour les index des onglets
const int kHomeTabIndex = 0;
const int kTrackingTabIndex = 1;
const int kProfileTabIndex = 2;
// Ajoutez d'autres index si vous avez plus d'onglets (ex: kCommunityTabIndex = 2, et Profile devient 3)

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _selectedIndex = kHomeTabIndex; // Utiliser la constante
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late PageController
      _pageController; // Pour IndexedStack si on veut naviguer programmatique avec animation

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
      // Si vous utilisez PageView avec BottomNavigationBar, vous feriez :
      // _pageController.jumpToPage(index);
      // Pour IndexedStack, juste changer _selectedIndex est suffisant pour l'affichage,
      // mais si HomeTabScreen doit changer d'onglet, il peut appeler cette méthode.
    });
  }

  // Cette méthode peut être utilisée par HomeTabScreen pour changer d'onglet
  void _navigateToTab(int index) {
    if (index >= 0 && index < 3) {
      // Mettez le nombre total d'onglets ici
      _onItemTapped(
          index); // Réutilise la même logique pour mettre à jour l'état
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    if (user == null) {
      // S'assurer que cela est appelé après le build pour éviter les erreurs
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Vérifier si le widget est toujours monté
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      });
      // Afficher un loader pendant la redirection
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<Widget> widgetOptions = <Widget>[
      HomeTabScreen(
        user: user,
        onNavigateToTab: _navigateToTab, // Passer la méthode pour la navigation
      ),
      TrackingTabScreen(user: user),
      ProfileTabScreen(user: user),
      // Ajoutez d'autres onglets ici si nécessaire
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(_selectedIndex, user)),
        // automaticallyImplyLeading: false, // Si vous ne voulez pas de bouton retour sur la première page
      ),
      body: IndexedStack(
        // Utiliser IndexedStack pour préserver l'état des onglets
        index: _selectedIndex,
        children: widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType
            .fixed, // Utile si vous avez 4+ items pour éviter le shifting
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons
                .calendar_today_outlined), // ou Icons.timeline / Icons.bar_chart
            label: 'Tracking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
          // Ajoutez d'autres items ici
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // selectedItemColor: Theme.of(context).colorScheme.primary, // Optionnel pour styler
        // unselectedItemColor: Colors.grey, // Optionnel
      ),
    );
  }

  String _getAppBarTitle(int index, User user) {
    String? displayName = user.displayName;
    if (displayName == null || displayName.trim().isEmpty) {
      displayName = user.email?.split('@')[0];
    }

    switch (index) {
      case kHomeTabIndex:
        return 'Welcome, ${displayName ?? "User"}!'; // Message d'accueil plus personnalisé
      case kTrackingTabIndex:
        return 'Your Progress';
      case kProfileTabIndex:
        return 'My Profile';
      // case kCommunityTabIndex: // Si vous ajoutez un onglet communauté
      //   return 'Community';
      default:
        return 'GymGenius';
    }
  }
}

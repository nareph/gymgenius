// lib/screens/tabs/profile_tab_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pour formater la date

class ProfileTabScreen extends StatefulWidget {
  final User user;
  const ProfileTabScreen({super.key, required this.user});

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Helper pour afficher les informations du profil
  Widget _buildProfileInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool isLoading = false,
    bool dense = false, // Added for GridView items
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      dense: dense, // Use dense layout for grid items
      leading: Icon(icon, color: colorScheme.primary, size: dense ? 20 : 24),
      title: Text(title,
          style: TextStyle(
              fontWeight: FontWeight.w500, fontSize: dense ? 14 : null)),
      subtitle: isLoading
          ? LinearProgressIndicator(
              minHeight: 10, color: colorScheme.secondary.withOpacity(0.5))
          : Text(subtitle,
              style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: dense ? 12 : null)),
      trailing: onTap != null
          ? Icon(Icons.edit_outlined, size: dense ? 18 : 20)
          : null,
      onTap: onTap,
      contentPadding: dense
          ? const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0)
          : null, // Adjust padding for dense
    );
  }

  // Helper pour formater les données d'onboarding (si elles sont complexes)
  String _formatOnboardingDataValue(dynamic value) {
    if (value is Timestamp) {
      return DateFormat.yMMMMd().add_jm().format(value.toDate());
    } else if (value is List) {
      return value.join(', ');
    } else if (value is Map) {
      return value.entries.map((e) => "${e.key}: ${e.value}").join('\n');
    }
    return value?.toString() ?? 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('users').doc(widget.user.uid).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
              child: Text("Error: ${snapshot.error}",
                  style: TextStyle(color: colorScheme.error)));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("User profile not found."));
        }

        Map<String, dynamic> userData =
            snapshot.data!.data() as Map<String, dynamic>;
        String userEmail =
            widget.user.email ?? userData['email'] ?? 'No email provided';
        Timestamp? createdAtTimestamp = userData['createdAt'] as Timestamp?;
        String memberSince = createdAtTimestamp != null
            ? DateFormat.yMMMMd().format(createdAtTimestamp.toDate())
            : 'N/A';

        Map<String, dynamic> onboardingInfo = {};
        List<String> standardKeys = ['email', 'createdAt', 'uid'];
        userData.forEach((key, value) {
          if (!standardKeys.contains(key)) {
            onboardingInfo[key] = value;
          }
        });
        // Convert map to list of entries for GridView.builder
        final onboardingEntries = onboardingInfo.entries.toList();

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: colorScheme.secondaryContainer,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.user.email?.split('@')[0] ?? 'User Profile',
                    style: textTheme.headlineSmall,
                  ),
                  Text(
                    userEmail,
                    style: textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _buildProfileInfoTile(
                    icon: Icons.email_outlined,
                    title: "Email",
                    subtitle: userEmail,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildProfileInfoTile(
                    icon: Icons.calendar_today_outlined,
                    title: "Member Since",
                    subtitle: memberSince,
                  ),
                ],
              ),
            ),
            if (onboardingEntries.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text("Your Preferences",
                  style: textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12), // Increased spacing a bit
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding:
                      const EdgeInsets.all(12.0), // Padding around the grid
                  child: GridView.builder(
                    shrinkWrap: true, // Important for GridView in ListView
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
                    itemCount: onboardingEntries.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Number of columns
                      crossAxisSpacing: 10, // Spacing between columns
                      mainAxisSpacing: 10, // Spacing between rows
                      childAspectRatio:
                          2.0, // Adjust this ratio (width/height) to fit content.
                      // For ListTile, it's usually wider than tall. Try values between 2.0 and 3.5.
                      // If items have varying subtitle lengths, this might need fine-tuning
                      // or a different approach if heights become too inconsistent.
                    ),
                    itemBuilder: (context, index) {
                      final entry = onboardingEntries[index];
                      String title = entry.key
                          .replaceAllMapped(RegExp(r'([A-Z])'),
                              (match) => ' ${match.group(1)}')
                          .capitalizeFirstLetter();

                      return Container(
                        // Optional: Add a container for slight elevation or border per item
                        decoration: BoxDecoration(
                          // color: colorScheme.surfaceVariant.withOpacity(0.3), // Example background
                          borderRadius: BorderRadius.circular(8),
                          // border: Border.all(color: colorScheme.outline.withOpacity(0.2)) // Example border
                        ),
                        child: _buildProfileInfoTile(
                          icon: _getIconForOnboardingKey(entry.key),
                          title: title,
                          subtitle: _formatOnboardingDataValue(entry.value),
                          dense: true, // Use dense version for grid items
                          // onTap: () { /* TODO: Logique pour modifier cette préférence */ }
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: TextButton.icon(
                icon: Icon(Icons.edit_note, color: colorScheme.primary),
                label: Text("Edit My Preferences",
                    style: TextStyle(color: colorScheme.primary)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Editing preferences coming soon!")),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getIconForOnboardingKey(String key) {
    switch (key.toLowerCase()) {
      case 'fitnesslevel':
        return Icons.fitness_center_outlined;
      case 'goals':
        return Icons.flag_outlined;
      case 'availability':
      case 'trainingdays':
        return Icons.event_available_outlined;
      case 'preferredduration':
        return Icons.timer_outlined;
      case 'equipment':
        return Icons.build_circle_outlined;
      default:
        return Icons.tune_outlined;
    }
  }
}

extension StringExtension on String {
  String capitalizeFirstLetter() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

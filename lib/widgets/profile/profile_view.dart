// lib/widgets/profile/profile_view.dart
import 'package:flutter/material.dart';
import 'package:gymgenius/models/onboarding_question.dart';
import 'package:gymgenius/widgets/profile/preference_display_item.dart';
import 'package:gymgenius/widgets/profile/preference_edit_item.dart';
import 'package:gymgenius/widgets/profile/profile_header.dart';

/// ProfileView: A stateless widget responsible for displaying the profile UI.
///
/// This widget is "dumb" and receives all its data and callbacks from its parent.
/// It renders the UI based on the provided state, including the edit mode,
/// and passes the TextEditingControllers from the ViewModel to the edit items.
class ProfileView extends StatelessWidget {
  final String displayName;
  final String email;
  final bool isEditing;
  final bool isSaving;
  final Map<String, dynamic> sourceDataForUI;
  final VoidCallback onToggleEdit;
  final VoidCallback onSaveChanges;
  final VoidCallback onCancelChanges;
  final Function(String key, dynamic value) onUpdatePreference;
  final bool isOffline;
  // Controllers are now passed in from the ViewModel.
  final Map<String, TextEditingController> controllers;

  const ProfileView({
    super.key,
    required this.displayName,
    required this.email,
    required this.isEditing,
    required this.isSaving,
    required this.sourceDataForUI,
    required this.onToggleEdit,
    required this.onSaveChanges,
    required this.onCancelChanges,
    required this.onUpdatePreference,
    required this.controllers,
    this.isOffline = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    bool noPreferencesSet = sourceDataForUI.values.every((v) =>
        v == null ||
        (v is List && v.isEmpty) ||
        (v is Map &&
            v.values.every((val) => val == null || val.toString().isEmpty)) ||
        (v is String && v.isEmpty));

    if (noPreferencesSet && !isEditing && !isSaving) {
      return _buildNoPreferencesState(context, colorScheme, textTheme);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          if (isOffline) _buildOfflineBanner(context, colorScheme),
          ProfileHeader(
              displayName: displayName, email: email, memberSince: 'N/A'),
          const SizedBox(height: 24),
          _buildPreferencesHeader(context, colorScheme, textTheme),
          const SizedBox(height: 12),
          if (isSaving) _buildSavingIndicator(),
          if (!isSaving) _buildPreferencesList(context, colorScheme),
          if (isEditing && !isSaving) _buildActionButtons(context, colorScheme),
        ],
      ),
    );
  }

  /// Builds the UI state for when a user has not yet set any preferences.
  Widget _buildNoPreferencesState(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (isOffline) _buildOfflineBanner(context, colorScheme),
          ProfileHeader(
              displayName: displayName, email: email, memberSince: 'N/A'),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(Icons.fact_check_outlined,
                      size: 56, color: colorScheme.primary),
                  const SizedBox(height: 16),
                  Text("Set Your Preferences",
                      style: textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    isOffline
                        ? "You're currently offline. Connect to the internet to set or update your preferences."
                        : "Complete your fitness profile to get personalized AI workout plans tailored just for you.",
                    style: textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit_note_outlined),
                    label: const Text("Set Preferences Now"),
                    onPressed: isOffline ? null : onToggleEdit,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a banner to indicate that the app is in offline mode.
  Widget _buildOfflineBanner(BuildContext context, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: colorScheme.errorContainer.withAlpha(128),
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined,
              color: colorScheme.onErrorContainer, size: 20),
          const SizedBox(width: 12),
          Expanded(
              child: Text(
                  "You're currently offline. Changes will not be saved.",
                  style: TextStyle(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  /// Builds the header for the preferences section with an "Edit All" button.
  Widget _buildPreferencesHeader(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Your Preferences",
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        if (!isEditing && !isSaving)
          TextButton.icon(
            icon: Icon(Icons.edit_outlined,
                size: 20,
                color: isOffline
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.primary),
            label: Text("Edit All",
                style: textTheme.labelLarge?.copyWith(
                    color: isOffline
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.primary)),
            onPressed: isOffline ? null : onToggleEdit,
          ),
      ],
    );
  }

  /// Builds a loading indicator shown while preferences are being saved.
  Widget _buildSavingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Saving your preferences..."),
          ],
        ),
      ),
    );
  }

  /// Builds the list of preferences, switching between display and edit items.
  Widget _buildPreferencesList(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: defaultOnboardingQuestions.map((question) {
        if (isEditing) {
          return PreferenceEditItem(
            key: ValueKey('edit_${question.id}'),
            question: question,
            currentValue: sourceDataForUI[question.id],
            controllers:
                controllers, // Pass the controllers from the ViewModel.
            onUpdate: onUpdatePreference,
            isOffline: isOffline,
          );
        } else {
          return PreferenceDisplayItem(
            key: ValueKey('display_${question.id}'),
            question: question,
            currentValue: sourceDataForUI[question.id],
          );
        }
      }).toList(),
    );
  }

  /// Builds the "Cancel" and "Save Changes" buttons for edit mode.
  Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
              onPressed: onCancelChanges, child: const Text("Cancel")),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.save_alt_outlined, size: 20),
            label: const Text("Save Changes"),
            onPressed: onSaveChanges,
          ),
        ],
      ),
    );
  }
}

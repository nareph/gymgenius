// lib/presentation/widgets/profile/profile_view.dart

import 'package:flutter/material.dart';
import 'package:gymgenius/domain/enums/equipment_type.dart';
import 'package:gymgenius/domain/enums/experience_level.dart';
import 'package:gymgenius/domain/enums/fitness_goal.dart';
import 'package:gymgenius/domain/enums/gender.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/domain/enums/session_duration.dart';
import 'package:gymgenius/domain/enums/workout_day.dart';
import 'package:gymgenius/domain/enums/workout_frequency.dart';
import 'package:gymgenius/domain/enums/activity_level.dart';
import 'package:gymgenius/presentation/widgets/profile/preference_display_item.dart';
import 'package:gymgenius/presentation/widgets/profile/preference_edit_item.dart';
import 'package:gymgenius/presentation/widgets/profile/profile_header.dart';

class ProfileField {
  final String id;
  final String label;
  final FieldType type;
  final List<String>? options;
  final Map<String, String>? optionLabels;

  const ProfileField({
    required this.id,
    required this.label,
    required this.type,
    this.options,
    this.optionLabels,
  });
}

enum FieldType { singleChoice, multipleChoice, numeric }

final List<ProfileField> profileFields = [
  ProfileField(
    id: 'goal',
    label: 'Fitness Goal',
    type: FieldType.singleChoice,
    options: FitnessGoal.values.map((e) => e.value).toList(),
    optionLabels: {for (var e in FitnessGoal.values) e.value: e.displayName},
  ),
  ProfileField(
    id: 'gender',
    label: 'Gender',
    type: FieldType.singleChoice,
    options: Gender.values.map((e) => e.value).toList(),
    optionLabels: {for (var e in Gender.values) e.value: e.displayName},
  ),
  ProfileField(
    id: 'experience',
    label: 'Experience Level',
    type: FieldType.singleChoice,
    options: ExperienceLevel.values.map((e) => e.value).toList(),
    optionLabels: {
      for (var e in ExperienceLevel.values) e.value: e.displayName
    },
  ),
  ProfileField(
    id: 'activity_level',
    label: 'Activity Level',
    type: FieldType.singleChoice,
    options: ActivityLevel.values.map((e) => e.value).toList(),
    optionLabels: {for (var e in ActivityLevel.values) e.value: e.displayName},
  ),
  ProfileField(
    id: 'frequency',
    label: 'Workout Frequency',
    type: FieldType.singleChoice,
    options: WorkoutFrequency.values.map((e) => e.value).toList(),
    optionLabels: {
      for (var e in WorkoutFrequency.values) e.value: e.displayName
    },
  ),
  ProfileField(
    id: 'session_duration_minutes',
    label: 'Session Duration',
    type: FieldType.singleChoice,
    options: SessionDuration.values.map((e) => e.value).toList(),
    optionLabels: {
      for (var e in SessionDuration.values) e.value: e.displayName
    },
  ),
  ProfileField(
    id: 'workout_days',
    label: 'Preferred Workout Days',
    type: FieldType.multipleChoice,
    options: WorkoutDay.values.map((e) => e.value).toList(),
    optionLabels: {for (var e in WorkoutDay.values) e.value: e.displayName},
  ),
  ProfileField(
    id: 'equipment',
    label: 'Available Equipment',
    type: FieldType.multipleChoice,
    options: EquipmentType.values.map((e) => e.value).toList(),
    optionLabels: {for (var e in EquipmentType.values) e.value: e.displayName},
  ),
  ProfileField(
    id: 'focus_areas',
    label: 'Focus Areas',
    type: FieldType.multipleChoice,
    options: MuscleGroup.values.map((e) => e.value).toList(),
    optionLabels: {for (var e in MuscleGroup.values) e.value: e.displayName},
  ),
  ProfileField(
    id: 'country',
    label: 'Country',
    type: FieldType.singleChoice,
    options: [
      'Cameroon',
      'Nigeria',
      'Ghana',
      'Kenya',
      'South Africa',
      'USA',
      'UK',
      'France',
      'Germany',
      'Other'
    ],
    optionLabels: {
      'Cameroon': 'Cameroon',
      'Nigeria': 'Nigeria',
      'Ghana': 'Ghana',
      'Kenya': 'Kenya',
      'South Africa': 'South Africa',
      'USA': 'USA',
      'UK': 'United Kingdom',
      'France': 'France',
      'Germany': 'Germany',
      'Other': 'Other',
    },
  ),
];

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

    bool noPreferencesSet = profileFields.every((field) {
      final value = sourceDataForUI[field.id];
      return value == null ||
          (value is List && value.isEmpty) ||
          (value is Map &&
              value.values.every((v) => v == null || v.toString().isEmpty)) ||
          (value is String && value.isEmpty);
    });

    if (noPreferencesSet && !isEditing && !isSaving) {
      return _buildNoPreferencesState(context, colorScheme, textTheme);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          if (isOffline) _buildOfflineBanner(context, colorScheme),
          ProfileHeader(
            displayName: displayName,
            email: email,
            memberSince: 'N/A',
          ),
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

  Widget _buildNoPreferencesState(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (isOffline) _buildOfflineBanner(context, colorScheme),
          ProfileHeader(
            displayName: displayName,
            email: email,
            memberSince: 'N/A',
          ),
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

  Widget _buildPreferencesList(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: profileFields.map((field) {
        if (isEditing) {
          return PreferenceEditItem(
            key: ValueKey('edit_${field.id}'),
            field: field,
            currentValue: sourceDataForUI[field.id],
            controllers: controllers,
            onUpdate: onUpdatePreference,
            isOffline: isOffline,
          );
        } else {
          return PreferenceDisplayItem(
            key: ValueKey('display_${field.id}'),
            field: field,
            currentValue: sourceDataForUI[field.id],
          );
        }
      }).toList(),
    );
  }

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

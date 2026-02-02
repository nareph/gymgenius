// lib/widgets/regeneration/regenerate_button.dart
import 'package:flutter/material.dart';
import 'package:gymgenius/models/onboarding.dart';
import 'package:gymgenius/models/routine.dart';
import 'package:gymgenius/widgets/regeneration/regeneration_options_sheet.dart';

class RegenerateButton extends StatelessWidget {
  final OnboardingData onboardingData;
  final WeeklyRoutine? currentRoutine;
  final String? currentDay;
  final String? targetExerciseId;
  final Function(RegenerationOptions) onRegenerate;
  final bool isGenerating;
  final String tooltip;
  final ButtonStyle? style;
  const RegenerateButton({
    super.key,
    required this.onboardingData,
    required this.onRegenerate,
    this.currentRoutine,
    this.currentDay,
    this.targetExerciseId,
    this.isGenerating = false,
    this.tooltip = 'Edit Routine',
    this.style,
  });
  @override
  Widget build(BuildContext context) {
    if (isGenerating) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return IconButton(
      icon: const Icon(Icons.edit_note),
      tooltip: tooltip,
      onPressed: () => _showRegenerationSheet(context),
      style: style,
    );
  }

  void _showRegenerationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => RegenerationOptionsSheet(
        onboardingData: onboardingData,
        currentRoutine: currentRoutine,
        currentDay: currentDay,
        targetExerciseId: targetExerciseId,
        onApply: onRegenerate,
      ),
    );
  }
}

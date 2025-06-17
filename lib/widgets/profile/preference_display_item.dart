// lib/widgets/profile/preference_display_item.dart
import 'package:flutter/material.dart';
import 'package:gymgenius/extensions/string_extensions.dart';
import 'package:gymgenius/models/onboarding_question.dart';
import 'package:gymgenius/utils/ui_helpers.dart';

class PreferenceDisplayItem extends StatelessWidget {
  final OnboardingQuestion question;
  final dynamic currentValue;

  const PreferenceDisplayItem({
    super.key,
    required this.question,
    required this.currentValue,
  });

  String _getDisplayValue() {
    if (currentValue == null ||
        (currentValue is List && currentValue.isEmpty) ||
        (question.id == 'physical_stats' &&
            currentValue is Map &&
            currentValue.values
                .every((v) => v == null || v.toString().isEmpty)) ||
        (currentValue is Map &&
            currentValue.isEmpty &&
            question.id != 'physical_stats')) {
      return 'Not set';
    }

    switch (question.type) {
      case QuestionType.singleChoice:
        final selectedOption = question.options.firstWhere(
          (opt) => opt.value == currentValue,
          orElse: () => AnswerOption(
              value: '', text: currentValue?.toString() ?? 'Not set'),
        );
        return selectedOption.text;
      case QuestionType.multipleChoice:
        if (currentValue is List) {
          final text = currentValue
              .map((val) => question.options
                  .firstWhere((opt) => opt.value == val,
                      orElse: () =>
                          AnswerOption(value: '', text: val.toString()))
                  .text)
              .join(', ');
          return text.isEmpty ? 'Not set' : text;
        }
        return 'Not set';
      case QuestionType.numericInput:
        if (question.id == 'physical_stats' && currentValue is Map) {
          final text = statSubKeyEntries
              .map((subKeyEntry) {
                final value = currentValue[subKeyEntry.key];
                if (value != null && value.toString().isNotEmpty) {
                  return "${subKeyEntry.label.toCapitalizedDisplay()}: $value${subKeyEntry.unit.isNotEmpty ? ' ${subKeyEntry.unit}' : ''}";
                }
                return null;
              })
              .where((s) => s != null)
              .join('  |  ');
          return text.isEmpty ? 'Not set' : text;
        }
        return currentValue?.toString() ?? 'Not set';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant.withAlpha(77)),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(getIconForOnboardingKey(question.id),
            color: colorScheme.primary, size: 22),
        title: Text(
          question.text,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          _getDisplayValue(),
          style: textTheme.bodyMedium
              ?.copyWith(color: colorScheme.onSurfaceVariant),
          overflow: TextOverflow.ellipsis,
          maxLines: 3,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      ),
    );
  }
}

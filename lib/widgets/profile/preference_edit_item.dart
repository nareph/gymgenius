// lib/widgets/profile/preference_edit_item.dart
import 'package:flutter/material.dart';
import 'package:gymgenius/extensions/string_extensions.dart';
import 'package:gymgenius/models/onboarding_question.dart';

class PreferenceEditItem extends StatelessWidget {
  final OnboardingQuestion question;
  final dynamic currentValue;
  final Map<String, TextEditingController> controllers;
  final Function(String key, dynamic value) onUpdate;
  final bool isOffline;

  const PreferenceEditItem({
    super.key,
    required this.question,
    required this.currentValue,
    required this.controllers,
    required this.onUpdate,
    required this.isOffline,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final String displayTitle = question.text;

    Widget editingWidget;

    switch (question.type) {
      case QuestionType.singleChoice:
        String? currentValueInEdit = currentValue?.toString();
        if (currentValueInEdit != null &&
            !question.options.any((opt) => opt.value == currentValueInEdit)) {
          currentValueInEdit = null;
        }
        editingWidget = DropdownButtonFormField<String>(
          key: ValueKey('${question.id}_dropdown_edit_$currentValueInEdit'),
          decoration: InputDecoration(
            labelText: displayTitle,
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          value: currentValueInEdit,
          items: question.options
              .map(
                (option) => DropdownMenuItem<String>(
                    value: option.value,
                    child: Text(option.text, style: textTheme.bodyMedium)),
              )
              .toList(),
          onChanged:
              isOffline ? null : (newValue) => onUpdate(question.id, newValue),
          isExpanded: true,
        );
        break;

      case QuestionType.multipleChoice:
        List<String> selectedValues =
            List<String>.from(currentValue as List<dynamic>? ?? <String>[]);
        editingWidget = Column(
          key: ValueKey('${question.id}_multichoice_edit'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0, top: 8.0),
              child: Text(displayTitle,
                  style: textTheme.labelLarge
                      ?.copyWith(color: colorScheme.onSurfaceVariant)),
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: question.options
                  .map((option) => ChoiceChip(
                        label: Text(option.text),
                        selected: selectedValues.contains(option.value),
                        onSelected: isOffline
                            ? null
                            : (isSelected) {
                                if (isSelected) {
                                  selectedValues.add(option.value);
                                } else {
                                  selectedValues.remove(option.value);
                                }
                                onUpdate(question.id, selectedValues);
                              },
                        selectedColor: colorScheme.primary,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                      ))
                  .toList(),
            ),
          ],
        );
        break;

      case QuestionType.numericInput:
        if (question.id == 'physical_stats') {
          editingWidget = Column(
            key: ValueKey('${question.id}_numericgroup_edit'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                child: Text(displayTitle,
                    style: textTheme.labelLarge
                        ?.copyWith(color: colorScheme.onSurfaceVariant)),
              ),
              ...statSubKeyEntries.map((subKeyEntry) {
                final statKey = subKeyEntry.key;
                final controllerKey = '${question.id}_$statKey';
                TextEditingController statController =
                    controllers[controllerKey]!;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: TextFormField(
                    key: ValueKey(controllerKey),
                    controller: statController,
                    enabled: !isOffline,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText:
                          "${subKeyEntry.label.toCapitalizedDisplay()}${subKeyEntry.unit.isNotEmpty ? ' (${subKeyEntry.unit})' : ''}",
                      hintText: subKeyEntry.hint,
                      isDense: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (newValue) {
                      final Map<String, dynamic> currentStats =
                          Map<String, dynamic>.from(
                              (currentValue as Map<dynamic, dynamic>?) ?? {});
                      currentStats[statKey] = newValue.trim().isEmpty
                          ? null
                          : num.tryParse(newValue.trim());
                      onUpdate(question.id, currentStats);
                    },
                  ),
                );
              }),
            ],
          );
        } else {
          TextEditingController controller = controllers[question.id]!;
          editingWidget = TextFormField(
            key: ValueKey('${question.id}_numeric_edit_$currentValue'),
            controller: controller,
            enabled: !isOffline,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: displayTitle,
              isDense: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: (newValue) {
              onUpdate(
                  question.id,
                  newValue.trim().isEmpty
                      ? null
                      : num.tryParse(newValue.trim()));
            },
          );
        }
        break;
    }

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: colorScheme.outlineVariant.withAlpha(128)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: editingWidget,
      ),
    );
  }
}

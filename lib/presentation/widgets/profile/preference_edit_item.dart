import 'package:flutter/material.dart';
import 'package:gymgenius/presentation/widgets/profile/profile_view.dart';

class PreferenceEditItem extends StatelessWidget {
  final ProfileField field;
  final dynamic currentValue;
  final Map<String, TextEditingController> controllers;
  final Function(String key, dynamic value) onUpdate;
  final bool isOffline;

  const PreferenceEditItem({
    super.key,
    required this.field,
    required this.currentValue,
    required this.controllers,
    required this.onUpdate,
    this.isOffline = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          _buildEditor(context, colorScheme),
          const Divider(height: 20),
        ],
      ),
    );
  }

  Widget _buildEditor(BuildContext context, ColorScheme colorScheme) {
    if (field.type == FieldType.numeric) {
      final controllerKey = field.id;
      final controller = controllers[controllerKey];
      if (controller == null) return const SizedBox.shrink();
      return TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          hintText: 'Enter value',
        ),
        keyboardType: TextInputType.number,
        enabled: !isOffline,
      );
    } else if (field.type == FieldType.singleChoice) {
      final options = field.options ?? [];
      return Wrap(
        spacing: 8,
        runSpacing: 4,
        children: options.map((option) {
          final isSelected = currentValue == option;
          return ChoiceChip(
            label: Text(field.optionLabels?[option] ?? option),
            selected: isSelected,
            onSelected: isOffline
                ? null
                : (selected) {
                    onUpdate(field.id, selected ? option : null);
                  },
            selectedColor: colorScheme.primary,
            labelStyle: TextStyle(
              color: isSelected ? colorScheme.onPrimary : null,
            ),
          );
        }).toList(),
      );
    } else if (field.type == FieldType.multipleChoice) {
      final options = field.options ?? [];
      final selectedValues = (currentValue as List?)?.cast<String>() ?? [];
      return Wrap(
        spacing: 8,
        runSpacing: 4,
        children: options.map((option) {
          final isSelected = selectedValues.contains(option);
          return FilterChip(
            label: Text(field.optionLabels?[option] ?? option),
            selected: isSelected,
            onSelected: isOffline
                ? null
                : (selected) {
                    List<String> newSelection = List.from(selectedValues);
                    if (selected) {
                      newSelection.add(option);
                    } else {
                      newSelection.remove(option);
                    }
                    onUpdate(field.id, newSelection);
                  },
            selectedColor: colorScheme.primary,
            labelStyle: TextStyle(
              color: isSelected ? colorScheme.onPrimary : null,
            ),
          );
        }).toList(),
      );
    }
    return const SizedBox.shrink();
  }
}

// lib/presentation/widgets/profile/preference_display_item.dart

import 'package:flutter/material.dart';
import 'package:gymgenius/presentation/widgets/profile/profile_view.dart';

class PreferenceDisplayItem extends StatelessWidget {
  final ProfileField field;
  final dynamic currentValue;

  const PreferenceDisplayItem({
    super.key,
    required this.field,
    required this.currentValue,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    String displayText = _formatValue(currentValue);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              field.label,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              displayText,
              style: textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'Not set';
    if (value is List) {
      if (value.isEmpty) return 'None selected';
      return value.map((e) {
        // Try to get display name from option labels if available
        final label = field.optionLabels?[e];
        return label ?? e.toString();
      }).join(', ');
    }
    if (field.optionLabels != null &&
        field.optionLabels!.containsKey(value.toString())) {
      return field.optionLabels![value.toString()]!;
    }
    return value.toString();
  }
}

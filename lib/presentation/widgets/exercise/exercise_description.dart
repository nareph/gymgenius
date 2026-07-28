// lib/presentation/widgets/exercise/exercise_description.dart

import 'package:flutter/material.dart';

class ExerciseDescription extends StatelessWidget {
  final String description;

  const ExerciseDescription({
    super.key,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final paragraphs = description.split('\n\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'How to perform',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...paragraphs.map((paragraph) => _buildParagraph(context, paragraph)),
      ],
    );
  }

  Widget _buildParagraph(BuildContext context, String text) {
    // Target line (starts with **Target: ...**)
    if (text.startsWith('**Target:')) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: _buildFormattedText(
            context,
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    // Regular paragraph
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _buildFormattedText(context, text),
    );
  }

  Widget _buildFormattedText(
    BuildContext context,
    String text, {
    TextStyle? style,
  }) {
    final parts = text.split('**');
    final children = <Widget>[];

    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 0) {
        // Regular text
        if (parts[i].isNotEmpty) {
          children.add(Text(
            parts[i],
            style: style ??
                Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
          ));
        }
      } else {
        // Bold text
        children.add(Text(
          parts[i],
          style: style?.copyWith(fontWeight: FontWeight.bold) ??
              Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                  ),
        ));
      }
    }

    return Wrap(children: children);
  }
}

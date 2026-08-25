// lib/presentation/screens/profile_setup/views/profile_summary_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/presentation/blocs/profile_setup/profile_setup_bloc.dart';
import 'package:gymgenius/presentation/question/profile_questions.dart';

/// Final page of the onboarding flow: shows everything the user just
/// answered before it's actually saved, with an explicit confirm
/// button. Each row is tappable — jumps back to that question's page
/// (via [onEditQuestion]) so the user can fix something they notice is
/// wrong without restarting the whole flow.
class ProfileSummaryView extends StatelessWidget {
  final List<ProfileQuestion> questions;
  final bool isPostLogin;
  final void Function(int questionIndex) onEditQuestion;

  const ProfileSummaryView({
    super.key,
    required this.questions,
    required this.isPostLogin,
    required this.onEditQuestion,
  });

  String _formatAnswer(ProfileQuestion question, dynamic answer) {
    if (answer == null) {
      return question.isRequired ? 'Not answered' : 'Skipped';
    }

    if (question.id == 'physical_stats' && answer is Map) {
      final parts = <String>[];
      for (final entry in statSubKeyEntries) {
        final value = answer[entry.key];
        if (value != null && value.toString().isNotEmpty) {
          parts.add('${entry.label}: $value ${entry.unit}');
        }
      }
      return parts.isEmpty ? 'Not answered' : parts.join('  •  ');
    }

    if (answer is List) {
      if (answer.isEmpty) return 'Skipped';
      final texts = answer.map((value) {
        final match = question.options.where((o) => o.value == value);
        return match.isNotEmpty ? match.first.text : value.toString();
      });
      return texts.join(', ');
    }

    final match = question.options.where((o) => o.value == answer);
    return match.isNotEmpty ? match.first.text : answer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final state = context.watch<ProfileSetupBloc>().state;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Review your answers",
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            "Tap any answer to change it, then save.",
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: questions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final question = questions[index];
                final answer = state.answers[question.id];
                return InkWell(
                  onTap: () => onEditQuestion(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                question.text,
                                style: textTheme.labelLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatAnswer(question, answer),
                                style: textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          if (state.status == ProfileSetupStatus.error)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                state.errorMessage ?? 'Something went wrong. Try again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.error),
              ),
            ),
          ElevatedButton(
            onPressed: () => context.read<ProfileSetupBloc>().add(
                  CompleteProfileSetup(isPostLogin: isPostLogin),
                ),
            child: const Text("CONFIRM & SAVE"),
          ),
        ],
      ),
    );
  }
}

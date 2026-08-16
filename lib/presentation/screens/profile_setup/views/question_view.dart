// lib/presentation/screens/profile_setup/views/question_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/presentation/blocs/profile_setup/profile_setup_bloc.dart';
import 'package:gymgenius/presentation/question/profile_questions.dart';

class QuestionView extends StatefulWidget {
  final ProfileQuestion question;
  final VoidCallback onNext;

  const QuestionView({
    super.key,
    required this.question,
    required this.onNext,
  });

  @override
  State<QuestionView> createState() => _QuestionViewState();
}

class _QuestionViewState extends State<QuestionView> {
  Set<String> _selectedValues = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadInitialAnswer();
    });
  }

  void _loadInitialAnswer() {
    final bloc = context.read<ProfileSetupBloc>();
    final existingAnswer = bloc.state.answers[widget.question.id];

    if (widget.question.type == QuestionType.multipleChoice &&
        existingAnswer is List) {
      setState(() {
        _selectedValues = Set<String>.from(existingAnswer.whereType<String>());
      });
    }
  }

  void _handleSingleChoiceSelection(String selectedValue) {
    context.read<ProfileSetupBloc>().add(
          UpdateAnswer(
            questionId: widget.question.id,
            answerValue: selectedValue,
          ),
        );
    widget.onNext();
  }

  void _handleMultiChoiceSelection(String value, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedValues.add(value);
      } else {
        _selectedValues.remove(value);
      }
    });
    context.read<ProfileSetupBloc>().add(
          UpdateAnswer(
            questionId: widget.question.id,
            answerValue: _selectedValues.toList(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Only relevant for multipleChoice — singleChoice questions in this
    // questionnaire are all required and advance immediately on tap.
    final canProceedWithoutAnswer = !widget.question.isRequired;
    final canProceed = canProceedWithoutAnswer || _selectedValues.isNotEmpty;
    final showAsSkip = canProceedWithoutAnswer && _selectedValues.isEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.08, vertical: screenHeight * 0.03),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.question.text,
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: screenHeight * 0.03),
          if (widget.question.type == QuestionType.singleChoice)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widget.question.options
                      .map(
                        (option) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7.0),
                          child: ElevatedButton(
                            onPressed: () =>
                                _handleSingleChoiceSelection(option.value),
                            child:
                                Text(option.text, textAlign: TextAlign.center),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            )
          else if (widget.question.type == QuestionType.multipleChoice)
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 10.0,
                        runSpacing: 12.0,
                        alignment: WrapAlignment.center,
                        children: widget.question.options.map((option) {
                          final bool isSelected =
                              _selectedValues.contains(option.value);
                          return InkWell(
                            onTap: () => _handleMultiChoiceSelection(
                                option.value, !isSelected),
                            borderRadius: BorderRadius.circular(25.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18.0, vertical: 10.0),
                              constraints: const BoxConstraints(minWidth: 70),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(25.0),
                                border: Border.all(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.outlineVariant,
                                  width: 1.5,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color:
                                              colorScheme.primary.withAlpha(76),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Text(
                                option.text,
                                textAlign: TextAlign.center,
                                style: textTheme.labelLarge?.copyWith(
                                  color: isSelected
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurfaceVariant,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  // For optional questions (focus_areas, avoided_muscles),
                  // this button is enabled even with zero selections and
                  // relabels itself "SKIP" — replacing the old AppBar-level
                  // SKIP that submitted the ENTIRE form regardless of which
                  // question was on screen. Each question now owns its own
                  // skip affordance, only when it's actually optional.
                  ElevatedButton(
                    onPressed: canProceed ? widget.onNext : null,
                    child: Text(showAsSkip ? "SKIP" : "NEXT"),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

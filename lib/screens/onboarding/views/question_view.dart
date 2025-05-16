// lib/screens/onboarding/views/question_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/models/onboarding_question.dart'; // For OnboardingQuestion model
import 'package:gymgenius/screens/onboarding/bloc/onboarding_bloc.dart'; // For OnboardingBloc

// QuestionView: A widget to display single-choice or multiple-choice onboarding questions.
class QuestionView extends StatefulWidget {
  final OnboardingQuestion question; // The question data to display
  final VoidCallback
      onNext; // Callback to proceed to the next question or complete onboarding

  const QuestionView({
    super.key,
    required this.question,
    required this.onNext,
  });

  @override
  State<QuestionView> createState() => _QuestionViewState();
}

class _QuestionViewState extends State<QuestionView> {
  // Local state to manage selected values for multiple-choice questions.
  // Using a Set ensures no duplicate values.
  Set<String> _selectedValues = {};

  @override
  void initState() {
    super.initState();
    // Load any existing answer for this question from the BLoC after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Ensure the widget is still in the tree
        _loadInitialAnswer();
      }
    });
  }

  // Loads an existing answer from the OnboardingBloc's state.
  // This is useful if the user navigates back and forth or if pre-filling data.
  void _loadInitialAnswer() {
    final bloc = context.read<OnboardingBloc>();
    final existingAnswer = bloc.state.answers[widget.question.id];

    if (widget.question.type == QuestionType.multipleChoice &&
        existingAnswer is List) {
      // For multiple choice, pre-fill the _selectedValues Set.
      setState(() {
        _selectedValues = Set<String>.from(existingAnswer.whereType<String>());
      });
    }
    // For single choice, selection is typically transient (button press advances).
    // If visual pre-selection of a single-choice button were needed, logic would go here.
  }

  // Handles selection for single-choice questions.
  // Updates the BLoC and calls the onNext callback to proceed.
  void _handleSingleChoiceSelection(String selectedValue) {
    context.read<OnboardingBloc>().add(
          UpdateAnswer(
            questionId: widget.question.id,
            answerValue: selectedValue,
          ),
        );
    widget.onNext(); // Proceed to the next step immediately
  }

  // Handles selection changes for multiple-choice questions.
  // Updates the local _selectedValues state and the BLoC.
  void _handleMultiChoiceSelection(String value, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedValues.add(value);
      } else {
        _selectedValues.remove(value);
      }
    });
    // Update the BLoC state with the new list of selected values.
    context.read<OnboardingBloc>().add(
          UpdateAnswer(
            questionId: widget.question.id,
            answerValue:
                _selectedValues.toList(), // Convert Set to List for BLoC state
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.08, vertical: screenHeight * 0.03),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Display the question text.
          Text(
            widget.question.text,
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: screenHeight * 0.03),

          // Conditionally render answer options based on the question type.
          if (widget.question.type == QuestionType.singleChoice)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widget.question.options
                      .map((option) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 7.0),
                            child: ElevatedButton(
                              onPressed: () =>
                                  _handleSingleChoiceSelection(option.value),
                              child: Text(option.text,
                                  textAlign: TextAlign.center),
                            ),
                          ))
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
                        spacing: 10.0, // Horizontal spacing between chips
                        runSpacing:
                            12.0, // Vertical spacing between lines of chips
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
                                          color: colorScheme.primary
                                              .withAlpha((0.3 * 255).round()),
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
                  // "Next" button for multiple-choice questions, enabled only if at least one option is selected.
                  SizedBox(height: screenHeight * 0.03),
                  ElevatedButton(
                    onPressed:
                        _selectedValues.isNotEmpty ? widget.onNext : null,
                    child: const Text("NEXT"),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

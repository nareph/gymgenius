// lib/screens/onboarding/views/question_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/models/onboarding_question.dart'; // Ensure this path is correct
import 'package:gymgenius/screens/onboarding/bloc/onboarding_bloc.dart'; // Ensure this path is correct

class QuestionView extends StatefulWidget {
  final OnboardingQuestion question;
  final VoidCallback onNext; // Callback to proceed to the next question/step

  const QuestionView({
    super.key,
    required this.question,
    required this.onNext,
  });

  @override
  State<QuestionView> createState() => _QuestionViewState();
}

class _QuestionViewState extends State<QuestionView> {
  // Local state to manage selected values for multiple-choice questions
  Set<String> _selectedValues = {};

  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to ensure the context is available and build is complete
    // before accessing the Bloc to load initial state.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Check if the widget is still in the tree
        _loadInitialAnswer();
      }
    });
  }

  // Loads the existing answer from the Bloc state when the view is initialized or question changes.
  void _loadInitialAnswer() {
    // Accessing the Bloc here is safe as it's called after the initial build.
    final bloc = context.read<OnboardingBloc>();
    final existingAnswer = bloc.state.answers[widget.question.id];

    if (widget.question.type == QuestionType.multipleChoice &&
        existingAnswer is List) {
      // Pre-fill selected values for multiple-choice questions
      setState(() {
        _selectedValues = Set<String>.from(existingAnswer.whereType<String>());
      });
    } else if (widget.question.type == QuestionType.singleChoice &&
        existingAnswer is String) {
      // For single choice, the selection is usually transient (button press leads to next).
      // If you needed to visually pre-select a single choice button, logic would go here.
      // For now, no visual pre-fill for single choice as it auto-advances.
    }
    // For numericInput, the state is managed by the specific NumericInputView.
  }

  // Handles selection for single-choice questions.
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
  void _handleMultiChoiceSelection(String value, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedValues.add(value);
      } else {
        _selectedValues.remove(value);
      }
    });
    // Update the Bloc state with the new list of selected values
    context.read<OnboardingBloc>().add(
          UpdateAnswer(
            questionId: widget.question.id,
            answerValue: _selectedValues.toList(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    // Access theme properties and screen dimensions
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // The background is now managed by the parent screen (OnboardingScreen)
    // or the global theme. No need for a background Container here.

    // General padding for the view's content
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.08, vertical: screenHeight * 0.05),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Center content vertically
        crossAxisAlignment:
            CrossAxisAlignment.stretch, // Stretch children horizontally
        children: [
          // --- Question Text ---
          Text(
            widget.question.text,
            textAlign: TextAlign.center,
            // Uses 'headlineMedium' style from the theme
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface, // Ensure good contrast
            ),
          ),
          SizedBox(height: screenHeight * 0.05), // Adjusted spacing

          // --- Answer Options (Conditional Display based on QuestionType) ---
          if (widget.question.type == QuestionType.singleChoice)
            // --- CASE: Single Choice ---
            // Spread operator to add list of widgets
            ...widget.question.options.map((option) => Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 7.0), // Slightly less vertical padding
                  child: ElevatedButton(
                    onPressed: () => _handleSingleChoiceSelection(option.value),
                    // Style comes automatically from ElevatedButtonThemeData.
                    // If you wanted a style *different* from the main theme (e.g., less vibrant background),
                    // you would style it here. Otherwise, leave it empty to use the theme.
                    // style: ElevatedButton.styleFrom(
                    //   backgroundColor: colorScheme.primaryContainer, // Example override
                    //   foregroundColor: colorScheme.onPrimaryContainer,
                    //   padding: const EdgeInsets.symmetric(vertical: 14),
                    // ),
                    // Text style is taken from ElevatedButtonThemeData.textStyle (typically labelLarge)
                    child: Text(option.text, textAlign: TextAlign.center),
                  ),
                ))
          else if (widget.question.type == QuestionType.multipleChoice)
            // --- CASE: Multiple Choice (Using Wrap for selectable tags/chips) ---
            Column(
              // Wrap the Wrap and Next button in a Column to manage spacing
              children: [
                Wrap(
                  spacing: 10.0, // Horizontal spacing between chips
                  runSpacing: 12.0, // Vertical spacing between lines of chips
                  alignment: WrapAlignment.center, // Center chips horizontally
                  children: widget.question.options.map((option) {
                    final bool isSelected =
                        _selectedValues.contains(option.value);

                    return InkWell(
                      // Using InkWell for better tap feedback (ripple)
                      onTap: () => _handleMultiChoiceSelection(
                          option.value, !isSelected),
                      borderRadius:
                          BorderRadius.circular(25.0), // Match border radius
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18.0,
                            vertical: 10.0), // Adjusted padding
                        constraints: const BoxConstraints(
                            minWidth: 70), // Minimum width for chips
                        decoration: BoxDecoration(
                          // Use theme colors
                          color: isSelected
                              ? colorScheme.primary // Primary color if selected
                              : colorScheme
                                  .surfaceContainerHighest, // A slightly elevated surface if not selected
                          borderRadius: BorderRadius.circular(
                              25.0), // More rounded corners for chip-like feel
                          border: Border.all(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.outlineVariant, // Outline color
                            width: 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: colorScheme.primary.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : [],
                        ),
                        child: Text(
                          option.text,
                          textAlign: TextAlign.center,
                          // Use 'labelLarge' from theme, adjust color/weight based on selection
                          style: textTheme.labelLarge?.copyWith(
                            color: isSelected
                                ? colorScheme.onPrimary // Text on primary color
                                : colorScheme
                                    .onSurfaceVariant, // Text on surface color
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ), // End of Wrap

                // --- "Next" Button for Multiple Choice ---
                SizedBox(
                    height: screenHeight * 0.06), // Spacing before Next button
                ElevatedButton(
                  onPressed: _selectedValues.isNotEmpty
                      ? widget.onNext
                      : null, // Enable only if at least one option is selected
                  // Style comes from the global theme.
                  // If you need a specific style (e.g., different color) for this "Next" button:
                  // style: ElevatedButton.styleFrom(
                  //   backgroundColor: Colors.green.shade700,
                  //   foregroundColor: Colors.white,
                  //   padding: const EdgeInsets.symmetric(vertical: 14),
                  // ).merge(Theme.of(context).elevatedButtonTheme.style), // Merge to keep theme's disabled state, shape, etc.
                  child: const Text("NEXT"),
                ),
              ],
            ),

          // Placeholder for NumericInputView (if this QuestionView was to handle it)
          // else if (widget.question.type == QuestionType.numericInput)
          //   NumericInputView(question: widget.question, onNext: widget.onNext)
        ],
      ),
    );
  }
}

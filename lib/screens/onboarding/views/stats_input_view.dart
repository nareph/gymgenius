// lib/screens/onboarding/views/stats_input_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For InputFormatters
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/models/onboarding_question.dart'; // For OnboardingQuestion
import 'package:gymgenius/screens/onboarding/bloc/onboarding_bloc.dart'; // For OnboardingBloc

class StatsInputView extends StatefulWidget {
  final OnboardingQuestion
      question; // Receives the question for its ID and title
  final VoidCallback onNext; // Callback to proceed to the next step

  const StatsInputView({
    super.key,
    required this.question,
    required this.onNext,
  });

  @override
  State<StatsInputView> createState() => _StatsInputViewState();
}

class _StatsInputViewState extends State<StatsInputView> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _heightController =
      TextEditingController(); // Assuming height in meters
  final _weightController = TextEditingController(); // Assuming weight in kg
  final _targetWeightController =
      TextEditingController(); // Assuming target weight in kg

  @override
  void initState() {
    super.initState();
    // Pre-fill fields if data already exists in BLoC state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadInitialStats();
      }
    });
  }

  void _loadInitialStats() {
    final bloc = context.read<OnboardingBloc>();
    final existingAnswer = bloc.state.answers[widget.question.id];

    if (existingAnswer is Map<String, dynamic>) {
      setState(() {
        _ageController.text = existingAnswer['age']?.toString() ?? '';
        _heightController.text = existingAnswer['height_m']?.toString() ?? '';
        _weightController.text = existingAnswer['weight_kg']?.toString() ?? '';
        _targetWeightController.text =
            existingAnswer['target_weight_kg']?.toString() ?? '';
      });
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  void _submitStats() {
    if (_formKey.currentState?.validate() ?? false) {
      // Ensure form is not null before validating
      final statsData = {
        'age': int.tryParse(_ageController.text.trim()) ?? 0,
        'height_m': double.tryParse(_heightController.text.trim()) ??
            0.0, // Store as meters
        'weight_kg': double.tryParse(_weightController.text.trim()) ?? 0.0,
        'target_weight_kg':
            double.tryParse(_targetWeightController.text.trim()) ?? 0.0,
      };
      // Dispatch event to update BLoC state
      context.read<OnboardingBloc>().add(
            UpdateAnswer(
              questionId: widget
                  .question.id, // Use the question ID (e.g., "physical_stats")
              answerValue: statsData,
            ),
          );
      widget.onNext(); // Proceed to the next step
    }
  }

  // Generic validator for number fields
  String? _validateNumber(
    String? value, {
    bool allowDecimal = false,
    required String fieldName, // Use 'required' for clarity
    double? minValue, // Optional minimum value
    double? maxValue, // Optional maximum value
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your $fieldName.';
    }
    final number = allowDecimal
        ? double.tryParse(value.trim())
        : int.tryParse(value.trim());
    if (number == null) {
      return 'Please enter a valid number for $fieldName.';
    }
    if (number <= 0 && (minValue == null || minValue <= 0)) {
      // Check against 0 if no specific min value or min value is also <=0
      return 'Please enter a positive value for $fieldName.';
    }
    if (minValue != null && number < minValue) {
      return '$fieldName must be at least $minValue.';
    }
    if (maxValue != null && number > maxValue) {
      return '$fieldName cannot exceed $maxValue.';
    }
    // Example specific range validation (can be adapted)
    // if (fieldName == 'age' && number < 12) { return 'Age must be 12 or older.'; }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Access theme properties and screen dimensions
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Background is managed by the parent screen or global theme.

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.07, // Slightly adjusted padding
          vertical: screenHeight * 0.02),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          // Ensures content is scrollable on smaller screens
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: screenHeight * 0.03), // Adjusted top spacing
              // --- Page Title (from OnboardingQuestion) ---
              Text(
                widget.question.text, // e.g., "Tell us a bit about yourself"
                textAlign: TextAlign.center,
                // Uses theme's headlineMedium style
                style: textTheme.headlineMedium
                    ?.copyWith(color: colorScheme.onSurface),
              ),
              SizedBox(
                  height: screenHeight * 0.04), // Adjusted spacing after title

              // --- Input Fields (Using refactored _buildNumberTextField) ---
              _buildNumberTextField(
                controller: _ageController,
                labelText: "Age (years)",
                icon: Icons.cake_outlined,
                allowDecimal: false,
                validator: (value) => _validateNumber(value,
                    fieldName: 'age', minValue: 10, maxValue: 100),
              ),
              SizedBox(height: screenHeight * 0.025),

              _buildNumberTextField(
                controller: _heightController,
                labelText: "Height (meters, e.g., 1.75)",
                icon: Icons
                    .height_outlined, // Using outlined icon for consistency
                allowDecimal: true,
                validator: (value) => _validateNumber(value,
                    allowDecimal: true,
                    fieldName: 'height',
                    minValue: 0.5,
                    maxValue: 2.5),
              ),
              SizedBox(height: screenHeight * 0.025),

              _buildNumberTextField(
                controller: _weightController,
                labelText: "Current Weight (kg, e.g., 70.5)",
                icon: Icons.monitor_weight_outlined,
                allowDecimal: true,
                validator: (value) => _validateNumber(value,
                    allowDecimal: true,
                    fieldName: 'current weight',
                    minValue: 20,
                    maxValue: 300),
              ),
              SizedBox(height: screenHeight * 0.025),

              _buildNumberTextField(
                  controller: _targetWeightController,
                  labelText:
                      "Target Weight (kg, optional)", // Clarify optional if it is
                  icon: Icons.flag_outlined,
                  allowDecimal: true,
                  // Make target weight validation optional if the field itself is optional
                  validator: (value) {
                    if (value == null || value.trim().isEmpty)
                      return null; // Allow empty if optional
                    return _validateNumber(value,
                        allowDecimal: true,
                        fieldName: 'target weight',
                        minValue: 20,
                        maxValue: 300);
                  }),
              SizedBox(height: screenHeight * 0.05),

              // --- Next Button ---
              ElevatedButton(
                onPressed: _submitStats,
                // To use the app's primary button theme, remove the specific style here.
                // If a distinct style (like green) is intended for this screen's "Next" button:
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      colorScheme.primary, // Example: Use primary theme color
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                      vertical: 14), // Consistent padding
                  textStyle: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold), // Consistent text style
                ).merge(Theme.of(context)
                    .elevatedButtonTheme
                    .style), // Merge for disabled state, shape etc.
                child: const Text("NEXT"),
              ),
              SizedBox(height: screenHeight * 0.03), // Bottom spacing
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build styled numeric TextFormField
  Widget _buildNumberTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required FormFieldValidator<String> validator,
    bool allowDecimal = false,
  }) {
    final inputDecorationTheme = Theme.of(context).inputDecorationTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType:
          TextInputType.numberWithOptions(decimal: allowDecimal, signed: false),
      inputFormatters: allowDecimal
          // Allows numbers with up to 2 decimal places
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))]
          : [FilteringTextInputFormatter.digitsOnly],
      // Text input style comes from the global theme (e.g., TextTheme.titleMedium or subtitle1)
      decoration: InputDecoration(
        // Applies styles from the global InputDecorationTheme,
        // but allows overrides here if needed (e.g., specific labelText, icon).
        labelText: labelText,
        // Label style comes from 'inputDecorationTheme.labelStyle'.
        prefixIcon: Icon(icon,
            color: inputDecorationTheme.prefixIconColor ??
                colorScheme.onSurfaceVariant),
        // Other styles (filled, fillColor, borders, errorStyle, etc.)
        // come directly from 'inputDecorationTheme' defined in AppTheme.
      ),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}

// lib/screens/onboarding/views/stats_input_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For InputFormatters
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/models/onboarding_question.dart'; // For OnboardingQuestion
import 'package:gymgenius/screens/onboarding/bloc/onboarding_bloc.dart'; // For OnboardingBloc

// StatsInputView: A widget specifically for collecting physical statistics
// (age, height, weight, target weight) during onboarding.
class StatsInputView extends StatefulWidget {
  final OnboardingQuestion
      question; // The question object (id should be "physical_stats")
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
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  // Text editing controllers for each stat input field
  final _ageController = TextEditingController();
  final _heightController = TextEditingController(); // For height in meters
  final _weightController = TextEditingController(); // For weight in kg
  final _targetWeightController =
      TextEditingController(); // For target weight in kg

  @override
  void initState() {
    super.initState();
    // Load any existing stats from the BLoC after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadInitialStats();
      }
    });
  }

  // Loads existing stats from the OnboardingBloc's state.
  void _loadInitialStats() {
    final bloc = context.read<OnboardingBloc>();
    // The ID for physical stats question is expected to be "physical_stats".
    final existingAnswer = bloc.state.answers[widget.question.id];

    if (existingAnswer is Map<String, dynamic>) {
      setState(() {
        _ageController.text = existingAnswer['age']?.toString() ?? '';
        _heightController.text =
            existingAnswer['height_m']?.toString() ?? ''; // Uses 'height_m' key
        _weightController.text = existingAnswer['weight_kg']?.toString() ?? '';
        _targetWeightController.text =
            existingAnswer['target_weight_kg']?.toString() ??
                ''; // Uses 'target_weight_kg' key
      });
    }
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources.
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  // Validates the form and submits the stats data to the OnboardingBloc.
  void _submitStats() {
    if (_formKey.currentState?.validate() ?? false) {
      // Validate all form fields
      final statsData = {
        'age': int.tryParse(_ageController.text.trim()),
        'height_m': double.tryParse(
            _heightController.text.trim()), // Key for Firestore/OnboardingData
        'weight_kg': double.tryParse(_weightController.text.trim()),
        'target_weight_kg': _targetWeightController.text.trim().isEmpty
            ? null // Store null if empty for optional field
            : double.tryParse(_targetWeightController.text.trim()),
      };

      // Remove keys with null values if they are truly optional and should not be stored if empty.
      // 'target_weight_kg' is handled by storing null if empty.
      // Age, height, weight are typically required by their validators if not empty.
      // statsData.removeWhere((key, value) => value == null); // Be cautious if some fields are meant to be explicitly null

      context.read<OnboardingBloc>().add(
            UpdateAnswer(
              questionId: widget.question.id, // This should be "physical_stats"
              answerValue: statsData,
            ),
          );
      widget.onNext(); // Proceed to the next onboarding step
    }
  }

  // Generic validator for number fields.
  String? _validateNumber(
    String? value, {
    bool allowDecimal = false,
    required String fieldName,
    double? minValue,
    double? maxValue,
    bool isOptional = false, // Flag for optional fields
  }) {
    if (value == null || value.trim().isEmpty) {
      return isOptional
          ? null
          : 'Please enter your $fieldName.'; // Skip validation if optional and empty
    }
    final number = allowDecimal
        ? double.tryParse(value.trim())
        : int.tryParse(value.trim());
    if (number == null) {
      return 'Please enter a valid number for $fieldName.';
    }
    // For non-optional fields, or optional fields that have a value entered.
    if (number <= 0 && (minValue == null || minValue <= 0)) {
      // This check might be too strict for some stats (e.g., target weight could be less than current if losing weight)
      // Consider if positive value is always required. For age, height, weight, it usually is.
      // This check is fine for age, height, current weight.
      if (fieldName != 'target weight') {
        // Target weight can be different
        return 'Please enter a positive value for $fieldName.';
      }
    }
    if (minValue != null && number < minValue) {
      return '$fieldName must be at least $minValue.';
    }
    if (maxValue != null && number > maxValue) {
      return '$fieldName cannot exceed $maxValue.';
    }
    return null; // Validation passed
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.07, vertical: screenHeight * 0.02),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          // To prevent overflow if keyboard is large
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: screenHeight * 0.03),
              // Question text (e.g., "Tell us a bit about yourself")
              Text(
                widget.question.text,
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium
                    ?.copyWith(color: colorScheme.onSurface),
              ),
              SizedBox(height: screenHeight * 0.04),

              // Age input field
              _buildNumberTextField(
                controller: _ageController,
                labelText: "Age (years)",
                hintText: "e.g., 25",
                icon: Icons.cake_outlined,
                allowDecimal: false,
                validator: (value) => _validateNumber(value,
                    fieldName: 'age', minValue: 10, maxValue: 100),
              ),
              SizedBox(height: screenHeight * 0.025),

              // Height input field (in meters)
              _buildNumberTextField(
                controller: _heightController,
                labelText: "Height (meters)",
                hintText: "e.g., 1.75",
                icon: Icons.height_outlined,
                allowDecimal: true,
                validator: (value) => _validateNumber(value,
                    allowDecimal: true,
                    fieldName: 'height',
                    minValue: 0.5,
                    maxValue: 2.5),
              ),
              SizedBox(height: screenHeight * 0.025),

              // Current Weight input field (in kg)
              _buildNumberTextField(
                controller: _weightController,
                labelText: "Current Weight (kg)",
                hintText: "e.g., 70.5",
                icon: Icons.monitor_weight_outlined,
                allowDecimal: true,
                validator: (value) => _validateNumber(value,
                    allowDecimal: true,
                    fieldName: 'current weight',
                    minValue: 20,
                    maxValue: 300),
              ),
              SizedBox(height: screenHeight * 0.025),

              // Target Weight input field (in kg, optional)
              _buildNumberTextField(
                  controller: _targetWeightController,
                  labelText: "Target Weight (kg, optional)",
                  hintText: "e.g., 65",
                  icon: Icons.flag_outlined,
                  allowDecimal: true,
                  validator: (value) => _validateNumber(
                        value,
                        allowDecimal: true,
                        fieldName: 'target weight',
                        minValue: 20,
                        maxValue: 300,
                        isOptional: true, // Mark as optional for validation
                      )),
              SizedBox(height: screenHeight * 0.05),

              // "Next" button to submit stats
              ElevatedButton(
                onPressed: _submitStats,
                // Style is inherited from ElevatedButtonThemeData
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("NEXT"),
              ),
              SizedBox(height: screenHeight * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build consistently styled number input TextFormFields.
  Widget _buildNumberTextField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
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
      // Input formatters to restrict input to numbers (and optionally a decimal point)
      inputFormatters: allowDecimal
          ? [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
            ] // Allows numbers and up to 2 decimal places
          : [FilteringTextInputFormatter.digitsOnly], // Allows only digits
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        // Use hintStyle from theme, or a fallback if not defined
        hintStyle: inputDecorationTheme.hintStyle ??
            TextStyle(
                color: colorScheme.onSurfaceVariant
                    .withAlpha((153).round())), // Approx 60% opacity
        prefixIcon: Icon(icon,
            color: inputDecorationTheme.prefixIconColor ??
                colorScheme.onSurfaceVariant),
      ),
      validator: validator,
      autovalidateMode: AutovalidateMode
          .onUserInteraction, // Validate as user types or loses focus
    );
  }
}

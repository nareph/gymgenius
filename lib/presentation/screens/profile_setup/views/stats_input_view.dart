// lib/presentation/screens/profile_setup/views/stats_input_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/presentation/blocs/profile_setup/profile_setup_bloc.dart';
import 'package:gymgenius/presentation/question/profile_questions.dart';

class StatsInputView extends StatefulWidget {
  final ProfileQuestion question;
  final VoidCallback onNext;

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
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _targetWeightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadInitialStats();
    });
  }

  void _loadInitialStats() {
    final bloc = context.read<ProfileSetupBloc>();
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
      final statsData = {
        'age': int.tryParse(_ageController.text.trim()),
        'height_m': double.tryParse(_heightController.text.trim()),
        'weight_kg': double.tryParse(_weightController.text.trim()),
        'target_weight_kg': _targetWeightController.text.trim().isEmpty
            ? null
            : double.tryParse(_targetWeightController.text.trim()),
      };
      context.read<ProfileSetupBloc>().add(
            UpdateAnswer(
              questionId: widget.question.id,
              answerValue: statsData,
            ),
          );
      widget.onNext();
    }
  }

  String? _validateNumber(
    String? value, {
    bool allowDecimal = false,
    required String fieldName,
    double? minValue,
    double? maxValue,
    bool isOptional = false,
  }) {
    if (value == null || value.trim().isEmpty) {
      return isOptional ? null : 'Please enter your $fieldName.';
    }
    final number = allowDecimal
        ? double.tryParse(value.trim())
        : int.tryParse(value.trim());
    if (number == null) {
      return 'Please enter a valid number for $fieldName.';
    }
    if (number <= 0 &&
        (minValue == null || minValue <= 0) &&
        fieldName != 'target weight') {
      return 'Please enter a positive value for $fieldName.';
    }
    if (minValue != null && number < minValue) {
      return '$fieldName must be at least $minValue.';
    }
    if (maxValue != null && number > maxValue) {
      return '$fieldName cannot exceed $maxValue.';
    }
    return null;
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: screenHeight * 0.03),
              Text(
                widget.question.text,
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
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
                  isOptional: true,
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              ElevatedButton(
                onPressed: _submitStats,
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
      inputFormatters: allowDecimal
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))]
          : [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: inputDecorationTheme.hintStyle ??
            TextStyle(color: colorScheme.onSurfaceVariant.withAlpha(153)),
        prefixIcon: Icon(icon,
            color: inputDecorationTheme.prefixIconColor ??
                colorScheme.onSurfaceVariant),
      ),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}

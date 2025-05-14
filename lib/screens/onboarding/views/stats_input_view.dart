// lib/screens/onboarding/views/stats_input_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For InputFormatters
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/models/onboarding_question.dart'; // For OnboardingQuestion
import 'package:gymgenius/screens/onboarding/bloc/onboarding_bloc.dart'; // For OnboardingBloc

class StatsInputView extends StatefulWidget {
  final OnboardingQuestion question;
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
  final _heightController = TextEditingController(); // Pour la taille en mètres
  final _weightController = TextEditingController(); // Pour le poids en kg
  final _targetWeightController =
      TextEditingController(); // Pour le poids cible en kg

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadInitialStats();
      }
    });
  }

  void _loadInitialStats() {
    final bloc = context.read<OnboardingBloc>();
    // L'id de la question pour les stats est "physical_stats"
    final existingAnswer = bloc.state.answers[widget.question.id];

    if (existingAnswer is Map<String, dynamic>) {
      setState(() {
        _ageController.text = existingAnswer['age']?.toString() ?? '';
        _heightController.text =
            existingAnswer['height_m']?.toString() ?? ''; // Utilise height_m
        _weightController.text = existingAnswer['weight_kg']?.toString() ?? '';
        _targetWeightController.text =
            existingAnswer['target_weight_kg']?.toString() ??
                ''; // Utilise target_weight_kg
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
        'age': int.tryParse(_ageController.text.trim()), // Garder tryParse
        'height_m':
            double.tryParse(_heightController.text.trim()), // Clé: height_m
        'weight_kg': double.tryParse(_weightController.text.trim()),
        'target_weight_kg': double.tryParse(
            _targetWeightController.text.trim()), // Clé: target_weight_kg
      };
      // Enlever les valeurs null du map avant de les envoyer au BLoC,
      // pour que fromMap dans PhysicalStats ne reçoive pas de clé avec valeur null
      // si l'utilisateur n'a rien entré pour un champ optionnel (comme target_weight_kg).
      statsData.removeWhere((key, value) =>
          value == null &&
          (key ==
              'target_weight_kg')); // Supprimer target_weight_kg si null et optionnel
      // Pour les autres, la validation devrait empêcher null.

      context.read<OnboardingBloc>().add(
            UpdateAnswer(
              questionId: widget.question.id, // "physical_stats"
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
    bool isOptional = false, // Nouveau paramètre pour les champs optionnels
  }) {
    if (value == null || value.trim().isEmpty) {
      return isOptional
          ? null
          : 'Please enter your $fieldName.'; // Ne pas valider si optionnel et vide
    }
    final number = allowDecimal
        ? double.tryParse(value.trim())
        : int.tryParse(value.trim());
    if (number == null) {
      return 'Please enter a valid number for $fieldName.';
    }
    // Ne pas valider la positivité si le champ est optionnel et que la valeur est 0 (souvent issue d'un tryParse sur une chaîne vide)
    // Cependant, si une valeur est entrée, elle doit être positive (ou dans la plage min/max)
    if (number <= 0 && !isOptional && (minValue == null || minValue <= 0)) {
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
                widget.question.text, // e.g., "Tell us a bit about yourself"
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium
                    ?.copyWith(color: colorScheme.onSurface),
              ),
              SizedBox(height: screenHeight * 0.04),
              _buildNumberTextField(
                controller: _ageController,
                labelText: "Age (years)",
                hintText: "e.g., 25", // Ajout du hintText
                icon: Icons.cake_outlined,
                allowDecimal: false,
                validator: (value) => _validateNumber(value,
                    fieldName: 'age', minValue: 10, maxValue: 100),
              ),
              SizedBox(height: screenHeight * 0.025),
              _buildNumberTextField(
                controller: _heightController,
                labelText: "Height (meters)", // Label mis à jour
                hintText: "e.g., 1.75", // Ajout du hintText
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
                labelText: "Current Weight (kg)", // Label mis à jour
                hintText: "e.g., 70.5", // Ajout du hintText
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
                  hintText: "e.g., 65", // Ajout du hintText
                  icon: Icons.flag_outlined,
                  allowDecimal: true,
                  validator: (value) => _validateNumber(
                        value, // Valider seulement si non vide
                        allowDecimal: true,
                        fieldName: 'target weight',
                        minValue: 20,
                        maxValue: 300,
                        isOptional:
                            true, // Marquer comme optionnel pour la validation
                      )),
              SizedBox(height: screenHeight * 0.05),
              ElevatedButton(
                onPressed: _submitStats,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ).merge(Theme.of(context).elevatedButtonTheme.style),
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
    String? hintText, // Nouveau paramètre pour le hintText
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
            TextStyle(
                color: colorScheme.onSurfaceVariant
                    .withAlpha((0.6 * 255).round())),
        prefixIcon: Icon(icon,
            color: inputDecorationTheme.prefixIconColor ??
                colorScheme.onSurfaceVariant),
      ),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}

// lib/screens/onboarding/views/stats_input_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Pour les InputFormatters
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/models/onboarding_question.dart';
import 'package:gymgenius/screens/onboarding/bloc/onboarding_bloc.dart';

class StatsInputView extends StatefulWidget {
  final OnboardingQuestion question; // Reçoit la question pour l'ID et le titre
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

  // Garder la logique de dispose, submit et validation
  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  void _submitStats() {
    if (_formKey.currentState!.validate()) {
      final statsData = {
        'age': int.tryParse(_ageController.text.trim()) ?? 0,
        'height_m': double.tryParse(_heightController.text.trim()) ?? 0.0,
        'weight_kg': double.tryParse(_weightController.text.trim()) ?? 0.0,
        'target_weight_kg':
            double.tryParse(_targetWeightController.text.trim()) ?? 0.0,
      };
      context.read<OnboardingBloc>().add(
            UpdateAnswer(
                questionId: widget.question.id, answerValue: statsData),
          );
      widget.onNext();
    }
  }

  String? _validateNumber(String? value,
      {bool allowDecimal = false, String fieldName = 'field'}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your $fieldName';
    }
    final number = allowDecimal
        ? double.tryParse(value.trim())
        : int.tryParse(value.trim());
    if (number == null) {
      return 'Please enter a valid number';
    }
    if (number <= 0) {
      return 'Please enter a positive value';
    }
    // Add specific range validation if needed (e.g., age > 12)
    // if (fieldName == 'age' && number < 12) { return 'Age must be 12 or older'; }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Accès au thème et aux dimensions
    final textTheme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Retiré le Container de fond, il est géré par l'écran parent ou le thème
    // return Container( ... decoration ... )

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.08, vertical: screenHeight * 0.02),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: screenHeight * 0.05),
              // --- Titre de la Page ---
              Text(
                widget.question.text,
                textAlign: TextAlign.center,
                // Utilise le style du thème
                style: textTheme.headlineMedium,
              ),
              SizedBox(height: screenHeight * 0.06),

              // --- Champs de Saisie (Utilise _buildNumberTextField refactoré) ---
              _buildNumberTextField(
                context: context, // Passe le contexte
                controller: _ageController,
                labelText: "Age (years)",
                icon: Icons.cake_outlined,
                allowDecimal: false,
                validator: (value) => _validateNumber(value, fieldName: 'age'),
              ),
              SizedBox(height: screenHeight * 0.02),

              _buildNumberTextField(
                context: context,
                controller: _heightController,
                labelText: "Height (meters, e.g., 1.75)",
                icon: Icons.height,
                allowDecimal: true,
                validator: (value) => _validateNumber(value,
                    allowDecimal: true, fieldName: 'height'),
              ),
              SizedBox(height: screenHeight * 0.02),

              _buildNumberTextField(
                context: context,
                controller: _weightController,
                labelText: "Current Weight (kgs, e.g., 70.5)",
                icon: Icons.monitor_weight_outlined,
                allowDecimal: true,
                validator: (value) => _validateNumber(value,
                    allowDecimal: true, fieldName: 'current weight'),
              ),
              SizedBox(height: screenHeight * 0.02),

              _buildNumberTextField(
                context: context,
                controller: _targetWeightController,
                labelText: "Target Weight (kgs)",
                icon: Icons.flag_outlined,
                allowDecimal: true,
                validator: (value) => _validateNumber(value,
                    allowDecimal: true, fieldName: 'target weight'),
              ),
              SizedBox(height: screenHeight * 0.05),

              // --- Bouton Next ---
              ElevatedButton(
                onPressed: _submitStats,
                // Style spécifique VERT pour ce bouton "Next"
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  // Garde le style de texte cohérent avec les autres boutons principaux
                  textStyle: textTheme.labelLarge,
                ).merge(Theme.of(context)
                    .elevatedButtonTheme
                    .style), // Fusionne avec le thème
                child: const Text("Next"),
              ),
              SizedBox(height: screenHeight * 0.05), // Espace en bas
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget pour créer les champs de texte numériques
  // Maintenant utilise InputDecorationTheme du contexte
  Widget _buildNumberTextField({
    required BuildContext context, // Ajout du contexte
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required FormFieldValidator<String> validator,
    bool allowDecimal = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType:
          TextInputType.numberWithOptions(decimal: allowDecimal, signed: false),
      inputFormatters: allowDecimal
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
          : [FilteringTextInputFormatter.digitsOnly],
      // Le style du texte saisi vient du thème global (TextTheme.bodyLarge ou subtitle1 selon version)
      // style: const TextStyle(color: Colors.white), // <-- SUPPRIMÉ
      decoration: InputDecoration(
        // Applique les styles du thème mais permet de surcharger ici si besoin
        // Ex: on garde le labelText et l'icône spécifiques à ce champ
        labelText: labelText,
        // Le style du label vient de 'inputDecorationTheme.labelStyle'
        // labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)), // <-- SUPPRIMÉ
        prefixIcon: Icon(
            icon /*, color: inputDecorationTheme.prefixIconColor */), // La couleur vient du thème
        // Les styles (filled, fillColor, borders, errorStyle etc.) viennent directement
        // de 'inputDecorationTheme' défini dans AppTheme.
      ),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}

// lib/screens/tabs/profile_tab_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// Assurez-vous d'importer votre modèle de question d'onboarding et la liste des questions
// Adaptez le chemin d'importation selon la structure de votre projet
import 'package:gymgenius/models/onboarding_question.dart'; // Exemple de chemin
import 'package:intl/intl.dart';
// final List<OnboardingQuestion> defaultOnboardingQuestions = []; // Si défini ailleurs, importez-le
// Si defaultOnboardingQuestions is defined in another file, ensure it's imported. For example:
// import 'package:gymgenius/data/onboarding_questions_data.dart';

class ProfileTabScreen extends StatefulWidget {
  final User user;
  const ProfileTabScreen({super.key, required this.user});

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isEditingAll = false;
  bool _isSavingAll = false;

  Map<String, dynamic> _currentEditValues = {};
  Map<String, dynamic> _originalPreferences = {};
  Map<String, TextEditingController> _numericInputControllers = {};

  // Vous devez avoir accès à 'defaultOnboardingQuestions' ici.
  // Assurez-vous que defaultOnboardingQuestions est défini et accessible.
  // S'il est dans un autre fichier, importez ce fichier.
  // Exemple:
  // import 'package:gymgenius/data/onboarding_questions_data.dart';
  // Si defaultOnboardingQuestions n'est pas initialisé, vous aurez des erreurs.
  // Pour cet exemple, je suppose qu'il est disponible globalement ou importé.
  // Si vous ne l'avez pas, vous pouvez définir une liste vide temporairement
  // ou vous assurer qu'elle est correctement chargée.
  // Exemple (s'il n'est pas défini ailleurs):
  // static const List<OnboardingQuestion> defaultOnboardingQuestions = [ /* ... vos questions ... */ ];

  OnboardingQuestion? _getQuestionById(String id) {
    try {
      // Assurez-vous que defaultOnboardingQuestions est accessible ici.
      // Si ce n'est pas le cas, vous aurez une erreur.
      // Exemple:
      // final List<OnboardingQuestion> questions = AppData.defaultOnboardingQuestions;
      // return questions.firstWhere((q) => q.id == id);
      return defaultOnboardingQuestions.firstWhere((q) => q.id == id);
    } catch (e) {
      if (id == 'physical_stats') {
        // Fallback pour physical_stats s'il n'est pas dans la liste principale
        return const OnboardingQuestion(
            id: 'physical_stats',
            text:
                'Physical Stats', // Ensure text is not empty if you rely on it
            type: QuestionType.numericInput);
      }
      print("Warning: OnboardingQuestion with ID '$id' not found. Error: $e");
      return null;
    }
  }

  @override
  void dispose() {
    _numericInputControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _initializeEditingState(Map<String, dynamic> userPreferences) {
    _originalPreferences = Map<String, dynamic>.from(userPreferences);
    _currentEditValues = Map<String, dynamic>.from(userPreferences);

    _numericInputControllers.forEach((_, controller) => controller.dispose());
    _numericInputControllers.clear();

    userPreferences.forEach((key, value) {
      final question = _getQuestionById(key);
      if (question != null && question.type == QuestionType.numericInput) {
        if (key == 'physical_stats' && value is Map) {
          _currentEditValues[key] =
              Map<String, dynamic>.from(value); // Assurer une copie modifiable
          (value).forEach((subKey, subValue) {
            final controllerKey = '${key}_$subKey'; // ex: physical_stats_age
            String textValue = subValue?.toString() ?? '';
            _numericInputControllers[controllerKey] =
                TextEditingController(text: textValue);
          });
        } else if (key != 'physical_stats') {
          // Autres numericInput (non-map)
          String textValue = value?.toString() ?? '';
          _numericInputControllers[key] =
              TextEditingController(text: textValue);
        }
      }
    });
  }

  Widget _buildPreferenceItem({
    required String itemKey,
    required dynamic currentValue,
    required OnboardingQuestion question,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    // Utiliser le texte de la question, ou un titre spécifique pour physical_stats
    String title = (question.id == "physical_stats" && question.text.isEmpty)
        ? "Physical Stats" // This will not be capitalized by the extension if it's already capitalized
        : question.text;

    if (!_isEditingAll) {
      String displayValue;
      if (question.type == QuestionType.singleChoice) {
        final selectedOption = question.options.firstWhere(
            (opt) => opt.value == currentValue,
            orElse: () => AnswerOption(
                value: '', text: currentValue?.toString() ?? 'N/A'));
        displayValue = selectedOption.text;
      } else if (question.type == QuestionType.multipleChoice) {
        if (currentValue is List && currentValue.isNotEmpty) {
          displayValue = (currentValue).map((val) {
            return question.options
                .firstWhere((opt) => opt.value == val,
                    orElse: () => AnswerOption(value: '', text: val.toString()))
                .text;
          }).join(', ');
        } else {
          displayValue = 'N/A';
        }
      } else if (question.type == QuestionType.numericInput &&
          itemKey == 'physical_stats') {
        if (currentValue is Map) {
          displayValue = (currentValue).entries.map((e) =>
              // Uses the extension here
              "${e.key.replaceAll('_', ' ')}: ${e.value ?? 'N/A'}").join(' | ');
        } else {
          displayValue = currentValue?.toString() ?? 'N/A';
        }
      } else {
        displayValue = currentValue?.toString() ?? 'N/A';
      }
      return ListTile(
        dense: true,
        leading: Icon(_getIconForOnboardingKey(itemKey),
            color: colorScheme.primary, size: 20),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        subtitle: Text(displayValue,
            style:
                TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      );
    } else {
      Widget editingWidget;
      switch (question.type) {
        case QuestionType.singleChoice:
          editingWidget = DropdownButtonFormField<String>(
            decoration: InputDecoration(
                labelText: title,
                isDense: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            value: _currentEditValues[itemKey]?.toString(),
            items: question.options
                .map((option) => DropdownMenuItem<String>(
                    value: option.value,
                    child: Text(option.text,
                        style: const TextStyle(fontSize: 14))))
                .toList(),
            onChanged: (newValue) =>
                setState(() => _currentEditValues[itemKey] = newValue),
            isExpanded: true,
          );
          break;
        case QuestionType.multipleChoice:
          List<String> selectedValues =
              List<String>.from(_currentEditValues[itemKey] ?? []);
          editingWidget = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.only(bottom: 4.0, top: 8.0),
                  child: Text(title,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant))),
              Wrap(
                spacing: 8.0,
                runSpacing: 0.0,
                children: question.options
                    .map((option) => ChoiceChip(
                          label: Text(option.text,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: selectedValues.contains(option.value)
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurface)),
                          selected: selectedValues.contains(option.value),
                          onSelected: (isSelected) => setState(() {
                            isSelected
                                ? selectedValues.add(option.value)
                                : selectedValues.remove(option.value);
                            _currentEditValues[itemKey] = selectedValues;
                          }),
                          selectedColor: colorScheme.primary,
                          backgroundColor: colorScheme.surfaceContainerHighest
                              .withOpacity(0.5),
                          checkmarkColor: colorScheme.onPrimary,
                          labelPadding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 0),
                        ))
                    .toList(),
              ),
            ],
          );
          break;
        case QuestionType.numericInput:
          if (itemKey == 'physical_stats') {
            Map<String, dynamic> statsMap =
                Map<String, dynamic>.from(_currentEditValues[itemKey] ?? {});
            // Assurez-vous que les clés correspondent à celles dans vos données Firestore
            final List<String> statSubKeys =
                (currentValue as Map<dynamic, dynamic>?)
                        ?.keys
                        .map((e) => e.toString())
                        .toList() ??
                    [
                      'age',
                      'weight_kg',
                      'height_cm'
                    ]; // Provide default keys if necessary

            editingWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                    child: Text(title,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurfaceVariant))),
                ...statSubKeys.map((statKey) {
                  final controllerKey = '${itemKey}_$statKey';
                  TextEditingController? statController =
                      _numericInputControllers[controllerKey];
                  if (statController == null) {
                    String initialText = statsMap[statKey]?.toString() ?? '';
                    statController = TextEditingController(text: initialText);
                    _numericInputControllers[controllerKey] = statController;
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: TextField(
                      controller: statController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                          // Uses the extension here
                          labelText: statKey.replaceAll('_', ' '),
                          isDense: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8))),
                      onChanged: (newValue) {
                        // Ensure _currentEditValues[itemKey] is a map
                        if (_currentEditValues[itemKey] is! Map) {
                          _currentEditValues[itemKey] = <String, dynamic>{};
                        }
                        (_currentEditValues[itemKey]
                                as Map<String, dynamic>)[statKey] =
                            num.tryParse(newValue);

                        // The following line was updating statsMap which is a local copy.
                        // It's better to update _currentEditValues directly or ensure statsMap is
                        // assigned back to _currentEditValues[itemKey] if it's deeply nested.
                        // For simplicity, directly updating _currentEditValues:
                        // (_currentEditValues[itemKey] as Map<String,dynamic>)[statKey] = num.tryParse(newValue);
                        // Or if you prefer to use statsMap:
                        // statsMap[statKey] = num.tryParse(newValue);
                        // _currentEditValues[itemKey] = statsMap; // This line was missing or implicit.
                        // The original code `_currentEditValues[itemKey] = statsMap;` below is correct.
                      },
                    ),
                  );
                }).toList(),
              ],
            );
          } else {
            // Autres numericInput simples
            TextEditingController? controller =
                _numericInputControllers[itemKey];
            if (controller == null) {
              String initialText =
                  _currentEditValues[itemKey]?.toString() ?? '';
              controller = TextEditingController(text: initialText);
              _numericInputControllers[itemKey] = controller;
            }
            editingWidget = TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                  labelText: title,
                  isDense: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8))),
              onChanged: (newValue) =>
                  _currentEditValues[itemKey] = num.tryParse(newValue),
            );
          }
          break;
        default:
          editingWidget = Text("Unsupported edit type for '$itemKey'");
      }
      return Card(
        elevation: 0.5,
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: colorScheme.outline.withOpacity(0.3))),
        child:
            Padding(padding: const EdgeInsets.all(10.0), child: editingWidget),
      );
    }
  }

  void _toggleEditAllMode({bool cancel = false}) {
    setState(() {
      _isEditingAll = !_isEditingAll;
      if (!_isEditingAll && cancel) {
        _initializeEditingState(_originalPreferences);
      } else if (_isEditingAll) {
        _initializeEditingState(
            Map<String, dynamic>.from(_originalPreferences));
      }
    });
  }

  Future<void> _saveAllPreferences() async {
    if (!mounted) return;
    setState(() => _isSavingAll = true);

    Map<String, dynamic> preferencesToSave = {};
    _currentEditValues.forEach((key, value) {
      final question = _getQuestionById(key);
      if (question != null && question.type == QuestionType.numericInput) {
        if (key == 'physical_stats' && value is Map) {
          Map<String, dynamic> statsMapToSave = {};
          (value).forEach((statKey, statValue) {
            // statValue here is from _currentEditValues
            final controllerKey = '${key}_$statKey';
            final controller = _numericInputControllers[controllerKey];
            if (controller != null && controller.text.isNotEmpty) {
              statsMapToSave[statKey] = num.tryParse(controller.text);
              // If parsing fails, num.tryParse returns null. Decide if you want to keep original or set to null.
              // If you want to keep original if parsing fails and text is not empty:
              // statsMapToSave[statKey] = num.tryParse(controller.text) ?? (_originalPreferences[key]?[statKey] ?? statValue);
            } else if (controller != null && controller.text.isEmpty) {
              statsMapToSave[statKey] = null;
            } else {
              // Fallback if controller doesn't exist (should not happen with proper initialization)
              // or if you want to use the value from _currentEditValues directly (e.g., if not using controllers for some reason)
              statsMapToSave[statKey] =
                  statValue; // This is already a num or null from onChanged
            }
          });
          preferencesToSave[key] = statsMapToSave;
        } else if (key != 'physical_stats') {
          final controller = _numericInputControllers[key];
          if (controller != null && controller.text.isNotEmpty) {
            preferencesToSave[key] = num.tryParse(controller.text);
            // Same consideration for num.tryParse returning null
            // preferencesToSave[key] = num.tryParse(controller.text) ?? _originalPreferences[key];
          } else if (controller != null && controller.text.isEmpty) {
            preferencesToSave[key] = null;
          } else {
            preferencesToSave[key] = value; // Value from _currentEditValues
          }
        }
      } else {
        preferencesToSave[key] = value;
      }
    });

    try {
      await _firestore
          .collection('users')
          .doc(widget.user.uid)
          .update(preferencesToSave);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Preferences updated successfully!"),
          backgroundColor: Colors.green));
      setState(() {
        _isEditingAll = false;
        // Update _originalPreferences with the newly saved values
        _originalPreferences = Map<String, dynamic>.from(_currentEditValues);
      });
    } catch (e) {
      if (!mounted) return;
      print("Error saving preferences: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to update preferences: ${e.toString()}"),
          backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSavingAll = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('users').doc(widget.user.uid).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            _originalPreferences.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Text("Error: ${snapshot.error}",
                  style: TextStyle(color: colorScheme.error)));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("User profile not found."));
        }

        Map<String, dynamic> userDataFromFirestore =
            snapshot.data!.data() as Map<String, dynamic>;
        Map<String, dynamic> userPreferences = {};

        // Ensure defaultOnboardingQuestions is available
        // If it's null or empty, this map might be empty or cause issues
        List<String> onboardingQuestionIds =
            defaultOnboardingQuestions.map((q) => q.id).toList();

        userDataFromFirestore.forEach((key, value) {
          if (onboardingQuestionIds.contains(key) || key == 'physical_stats') {
            userPreferences[key] = value;
          }
        });

        // Initialize editing state if not already editing or if data has changed
        if (!_isEditingAll) {
          // A more robust check for data changes might be needed if deep comparison is required
          // For now, this re-initializes if the fetched data is different from the last original data.
          // Consider using a deep equality check if values can be complex objects that change internally.
          bool dataChanged = _originalPreferences.isEmpty ||
              !_areMapsEqual(_originalPreferences, userPreferences);

          if (dataChanged) {
            _initializeEditingState(userPreferences);
          }
        }

        String userEmail = widget.user.email ??
            userDataFromFirestore['email'] ??
            'No email provided';
        Timestamp? createdAtTimestamp =
            userDataFromFirestore['createdAt'] as Timestamp?;
        String memberSince = createdAtTimestamp != null
            ? DateFormat.yMMMMd().format(createdAtTimestamp.toDate())
            : 'N/A';

        List<MapEntry<String, dynamic>> preferencesToDisplay = [];
        userPreferences.forEach((key, value) {
          final question = _getQuestionById(key);
          if (question != null) {
            preferencesToDisplay.add(MapEntry(key, value));
          }
        });
        preferencesToDisplay.sort((a, b) {
          int indexA =
              defaultOnboardingQuestions.indexWhere((q) => q.id == a.key);
          int indexB =
              defaultOnboardingQuestions.indexWhere((q) => q.id == b.key);
          // Handle cases where a key might not be in defaultOnboardingQuestions (shouldn't happen if _getQuestionById is strict)
          if (indexA == -1) return 1;
          if (indexB == -1) return -1;
          return indexA.compareTo(indexB);
        });

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            Center(
              child: Column(children: [
                CircleAvatar(
                    radius: 50,
                    backgroundColor: colorScheme.secondaryContainer,
                    child: Icon(Icons.person,
                        size: 60, color: colorScheme.onSecondaryContainer)),
                const SizedBox(height: 12),
                Text(
                    widget.user.displayName ??
                        widget.user.email?.split('@')[0] ??
                        'User Profile',
                    style: textTheme.headlineSmall),
                Text(userEmail,
                    style: textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant)),
              ]),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Column(children: [
                ListTile(
                    leading:
                        Icon(Icons.email_outlined, color: colorScheme.primary),
                    title: const Text("Email",
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(userEmail,
                        style: TextStyle(color: colorScheme.onSurfaceVariant))),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                    leading: Icon(Icons.calendar_today_outlined,
                        color: colorScheme.primary),
                    title: const Text("Member Since",
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(memberSince,
                        style: TextStyle(color: colorScheme.onSurfaceVariant))),
              ]),
            ),
            if (preferencesToDisplay.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Your Preferences",
                      style: textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  if (!_isEditingAll && !_isSavingAll)
                    TextButton.icon(
                        icon: Icon(Icons.edit_outlined,
                            size: 20, color: colorScheme.primary),
                        label: Text("Edit",
                            style: TextStyle(color: colorScheme.primary)),
                        onPressed: _toggleEditAllMode,
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4))),
                ],
              ),
              const SizedBox(height: 12),
              if (_isSavingAll)
                const Center(
                    child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 30.0),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text("Saving preferences...")
                            ]))),
              if (!_isSavingAll)
                _isEditingAll
                    ? Column(
                        children: preferencesToDisplay.map((entry) {
                          final question = _getQuestionById(entry.key);
                          if (question == null)
                            return const SizedBox.shrink(); // Should not happen
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: _buildPreferenceItem(
                                itemKey: entry.key,
                                currentValue: entry.value,
                                question: question),
                          );
                        }).toList(),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: preferencesToDisplay.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              MediaQuery.of(context).size.width > 600 ? 2 : 1,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio:
                              (MediaQuery.of(context).size.width > 600
                                  ? 3.5
                                  : 4.5),
                        ),
                        itemBuilder: (context, index) {
                          final entry = preferencesToDisplay[index];
                          final question = _getQuestionById(entry.key);
                          if (question == null)
                            return const SizedBox.shrink(); // Should not happen
                          return _buildPreferenceItem(
                              itemKey: entry.key,
                              currentValue: entry.value,
                              question: question);
                        },
                      ),
              if (_isEditingAll && !_isSavingAll) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                        onPressed: () => _toggleEditAllMode(cancel: true),
                        child: const Text("Cancel"),
                        style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colorScheme.outline))),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                        icon: const Icon(Icons.save_alt_outlined, size: 18),
                        label: const Text("Save Changes"),
                        onPressed: _saveAllPreferences,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary)),
                  ],
                ),
              ],
            ],
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: TextButton.icon(
                icon: Icon(Icons.logout, color: colorScheme.error),
                label: Text("Sign Out",
                    style: TextStyle(color: colorScheme.error)),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper function for comparing maps (simple equality, not deep)
  bool _areMapsEqual(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    if (map1.length != map2.length) return false;
    for (var key in map1.keys) {
      if (!map2.containsKey(key) ||
          map1[key].toString() != map2[key].toString()) {
        // Note: .toString() comparison is a simplification. For robust deep comparison,
        // you might need a more sophisticated approach, e.g., from package:collection/equality.dart
        return false;
      }
    }
    return true;
  }

  IconData _getIconForOnboardingKey(String key) {
    switch (key) {
      case 'goal':
        return Icons.flag_outlined;
      case 'gender':
        return Icons.wc_outlined;
      case 'physical_stats':
        return Icons.monitor_weight_outlined;
      case 'experience':
        return Icons.insights_outlined;
      case 'frequency':
        return Icons.repeat_on_outlined;
      case 'workout_days':
        return Icons.event_available_outlined;
      case 'equipment':
        return Icons.fitness_center_outlined;
      case 'focus_areas':
        return Icons.center_focus_strong_outlined;
      default:
        return Icons.tune_outlined;
    }
  }
}

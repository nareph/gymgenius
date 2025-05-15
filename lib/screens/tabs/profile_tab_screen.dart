// lib/screens/tabs/profile_tab_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymgenius/models/onboarding_question.dart';
import 'package:intl/intl.dart';

extension StringCasingExtension on String {
  String toCapitalizedDisplay() {
    if (isEmpty) return this;
    return replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty
            ? ''
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}

const List<({String key, String unit, String label, String hint})>
    statSubKeyEntries = [
  (key: 'age', unit: 'years', label: 'Age', hint: 'e.g., 25'),
  (key: 'height_m', unit: 'm', label: 'Height', hint: 'e.g., 1.75'),
  (key: 'weight_kg', unit: 'kg', label: 'Weight', hint: 'e.g., 70.5'),
  (
    key: 'target_weight_kg',
    unit: 'kg',
    label: 'Target Weight',
    hint: 'e.g., 65 (optional)'
  ),
];

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
  bool _dataLoadedFromFirestore = false;

  Map<String, dynamic> _convertMapToMapStringDynamic(Map sourceMap) {
    final Map<String, dynamic> result = {};
    sourceMap.forEach((key, value) {
      final String stringKey = key.toString();
      if (value is Map) {
        result[stringKey] = _convertMapToMapStringDynamic(value);
      } else if (value is List) {
        result[stringKey] = _convertListWithNestedConversion(value);
      } else {
        result[stringKey] = value;
      }
    });
    return result;
  }

  List<dynamic> _convertListWithNestedConversion(List sourceList) {
    return sourceList.map((item) {
      if (item is Map) {
        return _convertMapToMapStringDynamic(item);
      } else if (item is List) {
        return _convertListWithNestedConversion(item);
      }
      return item;
    }).toList();
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: colorScheme.onError)),
        backgroundColor: colorScheme.error,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _numericInputControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _primeEditingStateWithData(Map<String, dynamic> sourceData) {
    _currentEditValues = {}; // Réinitialiser pour éviter les anciennes valeurs
    _numericInputControllers.forEach((_, controller) => controller.dispose());
    _numericInputControllers.clear();

    for (var question in defaultOnboardingQuestions) {
      dynamic valueFromSource = sourceData[question.id];

      if (question.id == 'physical_stats' &&
          question.type == QuestionType.numericInput) {
        Map<String, dynamic> statsMap;
        if (valueFromSource is Map<String, dynamic>) {
          statsMap = Map<String, dynamic>.from(valueFromSource);
        } else if (valueFromSource is Map) {
          statsMap = _convertMapToMapStringDynamic(valueFromSource);
        } else {
          statsMap =
              {}; // S'assurer que c'est une map vide si null ou type incorrect
        }
        _currentEditValues[question.id] =
            statsMap; // Stocker la map (peut-être vide)
        for (var subKeyEntry in statSubKeyEntries) {
          final controllerKey = '${question.id}_${subKeyEntry.key}';
          _numericInputControllers[controllerKey] = TextEditingController(
              text: statsMap[subKeyEntry.key]?.toString() ?? '');
        }
      } else if (question.type == QuestionType.numericInput) {
        // Pour d'autres entrées numériques (pas utilisé actuellement mais pour le futur)
        _currentEditValues[question.id] = valueFromSource;
        _numericInputControllers[question.id] =
            TextEditingController(text: valueFromSource?.toString() ?? '');
      } else if (question.type == QuestionType.multipleChoice) {
        if (valueFromSource is List) {
          _currentEditValues[question.id] =
              List<String>.from(valueFromSource.map((e) => e.toString()));
        } else if (valueFromSource is String && valueFromSource.isNotEmpty) {
          // Au cas où une seule valeur string serait stockée
          _currentEditValues[question.id] = [valueFromSource];
        } else {
          _currentEditValues[question.id] =
              <String>[]; // Liste vide si null ou type incorrect
        }
      } else {
        // singleChoice
        _currentEditValues[question.id] =
            valueFromSource?.toString(); // Assurer que c'est une String ou null
      }
    }
  }

  Widget _buildPreferenceItem({
    required String itemKey,
    required dynamic
        currentValueForWidget, // Peut être null, String, List<String>, ou Map
    required OnboardingQuestion question,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final String displayTitle = question.text;
    final inputDecorationTheme = Theme.of(context).inputDecorationTheme;

    if (!_isEditingAll) {
      // --- AFFICHAGE EN LECTURE SEULE ---
      String displayValue;
      if (currentValueForWidget == null ||
          (currentValueForWidget is List && currentValueForWidget.isEmpty) ||
          (itemKey == 'physical_stats' &&
              (currentValueForWidget is Map &&
                  currentValueForWidget.values
                      .every((v) => v == null || v.toString().isEmpty))) ||
          (currentValueForWidget is Map &&
              currentValueForWidget.isEmpty &&
              itemKey != 'physical_stats')) {
        displayValue = 'Not set';
      } else if (question.type == QuestionType.singleChoice) {
        final selectedOption = question.options.firstWhere(
            (opt) => opt.value == currentValueForWidget,
            orElse: () => AnswerOption(
                value: '',
                text: currentValueForWidget?.toString() ?? 'Not set'));
        displayValue = selectedOption.text;
      } else if (question.type == QuestionType.multipleChoice &&
          currentValueForWidget is List) {
        displayValue = currentValueForWidget.map((val) {
          return question.options
              .firstWhere((opt) => opt.value == val,
                  orElse: () => AnswerOption(value: '', text: val.toString()))
              .text;
        }).join(', ');
        if (displayValue.isEmpty) displayValue = 'Not set';
      } else if (question.id == 'physical_stats' &&
          question.type == QuestionType.numericInput &&
          currentValueForWidget is Map) {
        Map<String, dynamic> statsViewMap =
            _convertMapToMapStringDynamic(currentValueForWidget);
        displayValue = statSubKeyEntries
            .map((subKeyEntry) {
              final value = statsViewMap[subKeyEntry.key];
              if (value != null && value.toString().isNotEmpty) {
                return "${subKeyEntry.label.toCapitalizedDisplay()}: $value${subKeyEntry.unit.isNotEmpty ? ' ${subKeyEntry.unit}' : ''}";
              }
              return null;
            })
            .where((s) => s != null)
            .join('  |  ');
        if (displayValue.isEmpty) displayValue = 'Not set';
      } else {
        displayValue = currentValueForWidget?.toString() ?? 'Not set';
      }
      return ListTile(
        dense: true,
        leading: Icon(_getIconForOnboardingKey(itemKey),
            color: colorScheme.primary, size: 22),
        title: Text(displayTitle,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis),
        subtitle: Text(displayValue,
            style: textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
            overflow: TextOverflow.ellipsis,
            maxLines: 3),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      );
    } else {
      // --- MODE ÉDITION ---
      Widget editingWidget;
      switch (question.type) {
        case QuestionType.singleChoice:
          editingWidget = DropdownButtonFormField<String>(
            key: ValueKey(
                '${itemKey}_dropdown_edit_${_currentEditValues[itemKey]}'), // Clé pour reconstruire si la valeur change
            decoration: InputDecoration(
                labelText: displayTitle,
                isDense: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            value: _currentEditValues[itemKey]?.toString(),
            items: question.options
                .map((option) => DropdownMenuItem<String>(
                    value: option.value,
                    child: Text(option.text, style: textTheme.bodyMedium)))
                .toList(),
            onChanged: (newValue) {
              if (mounted) {
                setState(() => _currentEditValues[itemKey] = newValue);
              }
            },
            isExpanded: true,
          );
          break;
        case QuestionType.multipleChoice:
          List<String> selectedValues = List<String>.from(
              _currentEditValues[itemKey] as List<dynamic>? ?? <String>[]);
          editingWidget = Column(
            key: ValueKey('${itemKey}_multichoice_edit'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.only(bottom: 6.0, top: 8.0),
                  child: Text(displayTitle,
                      style: textTheme.labelLarge
                          ?.copyWith(color: colorScheme.onSurfaceVariant))),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: question.options
                    .map((option) => ChoiceChip(
                          label: Text(option.text,
                              style: textTheme.labelMedium?.copyWith(
                                  color: selectedValues.contains(option.value)
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurfaceVariant)),
                          selected: selectedValues.contains(option.value),
                          onSelected: (isSelected) {
                            if (mounted) {
                              setState(() {
                                if (isSelected) {
                                  selectedValues.add(option.value);
                                } else {
                                  selectedValues.remove(option.value);
                                }
                                _currentEditValues[itemKey] = selectedValues;
                              });
                            }
                          },
                          selectedColor: colorScheme.primary,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          checkmarkColor: colorScheme.onPrimary,
                          labelPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                        ))
                    .toList(),
              ),
            ],
          );
          break;
        case QuestionType.numericInput:
          if (question.id == 'physical_stats') {
            editingWidget = Column(
              key: ValueKey('${itemKey}_numericgroup_edit'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                    child: Text(displayTitle,
                        style: textTheme.labelLarge
                            ?.copyWith(color: colorScheme.onSurfaceVariant))),
                ...statSubKeyEntries.map((subKeyEntry) {
                  final statKey = subKeyEntry.key;
                  final controllerKey = '${itemKey}_$statKey';

                  TextEditingController statController =
                      _numericInputControllers.putIfAbsent(controllerKey, () {
                    final Map<String, dynamic>? currentStatsMap =
                        _currentEditValues[itemKey] is Map
                            ? _currentEditValues[itemKey]
                                as Map<String, dynamic>?
                            : null;
                    return TextEditingController(
                        text: currentStatsMap?[statKey]?.toString() ?? '');
                  });

                  final Map<String, dynamic>? statsDataForController =
                      _currentEditValues[itemKey] is Map
                          ? _currentEditValues[itemKey] as Map<String, dynamic>?
                          : null;
                  final currentValueInMap =
                      statsDataForController?[statKey]?.toString() ?? '';

                  if (statController.text != currentValueInMap) {
                    // S'assurer que le contrôleur est synchro
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && statController.text != currentValueInMap) {
                        statController.text = currentValueInMap;
                        statController.selection = TextSelection.fromPosition(
                            TextPosition(offset: statController.text.length));
                      }
                    });
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: TextFormField(
                      key: ValueKey(controllerKey),
                      controller: statController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                          labelText:
                              "${subKeyEntry.label.toCapitalizedDisplay()}${subKeyEntry.unit.isNotEmpty ? ' (${subKeyEntry.unit})' : ''}",
                          hintText: subKeyEntry.hint,
                          hintStyle: inputDecorationTheme.hintStyle ??
                              TextStyle(
                                  color: colorScheme.onSurfaceVariant
                                      .withAlpha((0.6 * 255).round())),
                          isDense: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8))),
                      onChanged: (newValue) {
                        final Map<String, dynamic> currentStats =
                            Map<String, dynamic>.from(
                                (_currentEditValues[itemKey]
                                        as Map<dynamic, dynamic>?) ??
                                    <String, dynamic>{});
                        currentStats[statKey] = newValue.trim().isEmpty
                            ? null
                            : num.tryParse(newValue.trim());
                        _currentEditValues[itemKey] = currentStats;
                      },
                    ),
                  );
                }).toList(),
              ],
            );
          } else {
            // Autres numeric inputs (pas utilisé actuellement)
            TextEditingController controller =
                _numericInputControllers.putIfAbsent(
                    itemKey,
                    () => TextEditingController(
                        text: _currentEditValues[itemKey]?.toString() ?? ''));
            final currentValueInMap =
                _currentEditValues[itemKey]?.toString() ?? '';
            if (controller.text != currentValueInMap) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && controller.text != currentValueInMap) {
                  controller.text = currentValueInMap;
                  controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: controller.text.length));
                }
              });
            }
            editingWidget = TextFormField(
              key: ValueKey(
                  '${itemKey}_numeric_edit_${_currentEditValues[itemKey]}'),
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                  labelText: displayTitle,
                  hintStyle: inputDecorationTheme.hintStyle ??
                      TextStyle(
                          color: colorScheme.onSurfaceVariant
                              .withAlpha((0.6 * 255).round())),
                  isDense: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8))),
              onChanged: (newValue) {
                _currentEditValues[itemKey] = newValue.trim().isEmpty
                    ? null
                    : num.tryParse(newValue.trim());
              },
            );
          }
          break;
      }
      return Card(
        elevation: 1,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
                color:
                    colorScheme.outlineVariant.withAlpha((0.5 * 255).round()))),
        child:
            Padding(padding: const EdgeInsets.all(12.0), child: editingWidget),
      );
    }
  }

  void _toggleEditAllMode({bool cancel = false}) {
    if (!mounted) return;
    setState(() {
      final bool enteringEditMode = !_isEditingAll;
      _isEditingAll = !_isEditingAll;
      if (enteringEditMode) {
        // En entrant en mode édition, on initialise _currentEditValues avec les données originales
        _primeEditingStateWithData(
            _convertMapToMapStringDynamic(Map.from(_originalPreferences)));
      } else if (cancel) {
        // Si on annule, on réinitialise _currentEditValues (implicitement fait par le prochain build si _isEditingAll est false)
        // et on s'assure que l'UI reflète _originalPreferences.
        // Pas besoin de re-appeler _primeEditingStateWithData ici si on quitte le mode édition.
      }
    });
  }

  Future<void> _saveAllPreferences() async {
    if (!mounted) return;
    setState(() => _isSavingAll = true);

    Map<String, dynamic> preferencesToSave = {};
    // Initialiser avec null pour toutes les clés pour effacer les anciennes valeurs si elles ne sont plus définies
    for (var question in defaultOnboardingQuestions) {
      preferencesToSave[question.id] = null;
    }

    _currentEditValues.forEach((key, value) {
      final question = defaultOnboardingQuestions.firstWhere((q) => q.id == key,
          orElse: () => const OnboardingQuestion(
              id: "unknown", text: "", type: QuestionType.singleChoice));
      if (question.id == "unknown") return;

      if (key == 'physical_stats' && value is Map) {
        Map<String, dynamic> statsMapToSave = {};
        final Map<String, dynamic>? currentPhysicalStats =
            value as Map<String, dynamic>?;
        bool hasAnyStatValue = false;
        for (var subKeyEntry in statSubKeyEntries) {
          final dynamic statValue = currentPhysicalStats?[subKeyEntry.key];
          if (statValue is String && statValue.trim().isNotEmpty) {
            statsMapToSave[subKeyEntry.key] = num.tryParse(statValue.trim());
            if (statsMapToSave[subKeyEntry.key] != null) hasAnyStatValue = true;
          } else if (statValue is num) {
            statsMapToSave[subKeyEntry.key] = statValue;
            hasAnyStatValue = true;
          } else {
            statsMapToSave[subKeyEntry.key] = null;
          }
        }
        preferencesToSave[key] = hasAnyStatValue ? statsMapToSave : null;
      } else if (question.type == QuestionType.numericInput) {
        final dynamic numValue = value;
        if (numValue is String && numValue.trim().isNotEmpty) {
          preferencesToSave[key] = num.tryParse(numValue.trim());
        } else if (numValue is num) {
          preferencesToSave[key] = numValue;
        } else {
          preferencesToSave[key] = null;
        }
      } else if (value is List && value.isEmpty) {
        preferencesToSave[key] = null;
      } else if (value != null && value.toString().isNotEmpty) {
        // Pour singleChoice et multipleChoice non vides
        preferencesToSave[key] = value;
      } else {
        preferencesToSave[key] = null; // Explicitement null pour les autres cas
      }
    });

    // Assurer que 'completed' est présent et vrai
    preferencesToSave['completed'] = true;

    try {
      final Map<String, dynamic> dataToSetInFirestore = {
        'onboardingData': preferencesToSave,
        'onboardingCompleted': true, // Drapeau de haut niveau
        'profileLastUpdatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(widget.user.uid).set(
            dataToSetInFirestore,
            SetOptions(
                merge:
                    true), // Utiliser merge:true pour ne pas écraser d'autres champs user non liés à l'onboarding
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Preferences updated successfully!"),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ));
      // Mettre à jour _originalPreferences pour refléter les données sauvegardées
      _originalPreferences =
          _convertMapToMapStringDynamic(Map.from(preferencesToSave));
      _isEditingAll = false;
    } catch (e) {
      if (!mounted) return;
      print("ProfileTabScreen: Error saving preferences: $e");
      _showErrorSnackBar("Failed to update preferences. Please try again.");
    } finally {
      if (mounted) setState(() => _isSavingAll = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
      key: ValueKey('profile_data_loader_$_dataLoadedFromFirestore'),
      future: _dataLoadedFromFirestore &&
              _isEditingAll // Ne pas re-fetch si on est en mode édition et que les données ont déjà été chargées
          ? Future.value(
              null) // Retourne une future déjà complétée pour ne pas recharger
          : _firestore
              .collection('users')
              .doc(widget.user.uid)
              .get()
              .then((doc) {
              if (doc.exists && doc.data() != null) {
                return doc;
              }
              return null;
            }).catchError((error) {
              print("ProfileTabScreen: Error fetching user document: $error");
              if (mounted) {
                _showErrorSnackBar("Could not load profile data.");
              }
              return null;
            }),
      builder: (BuildContext context,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !_dataLoadedFromFirestore) {
          return const Center(child: CircularProgressIndicator());
        }

        Map<String, dynamic> loadedOnboardingDataFromFirestore = {};
        Map<String, dynamic>? userDataFromFirestore;

        // Charger les données seulement si elles ne sont pas déjà chargées OU si snapshot contient de nouvelles données
        if (snapshot.hasData && snapshot.data != null) {
          userDataFromFirestore = snapshot.data!.data();
          if (userDataFromFirestore != null) {
            final rawOnboardingData = userDataFromFirestore['onboardingData'];
            if (rawOnboardingData is Map) {
              loadedOnboardingDataFromFirestore =
                  _convertMapToMapStringDynamic(rawOnboardingData);
            }
            if (!_dataLoadedFromFirestore) {
              // Premier chargement
              _originalPreferences =
                  Map.from(loadedOnboardingDataFromFirestore);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  if (!_isEditingAll)
                    _primeEditingStateWithData(Map.from(_originalPreferences));
                  setState(() {
                    _dataLoadedFromFirestore = true;
                  });
                }
              });
            }
          }
        } else if (snapshot.connectionState == ConnectionState.done &&
            !_dataLoadedFromFirestore &&
            snapshot.data == null) {
          // Le document n'existe pas ou est vide, mais le future est terminé
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _originalPreferences = {}; // Pas de données
              if (!_isEditingAll) _primeEditingStateWithData({});
              setState(() {
                _dataLoadedFromFirestore = true;
              });
            }
          });
        } else if (snapshot.hasError && !_dataLoadedFromFirestore) {
          return Center(
              child: Padding(
            padding: const EdgeInsets.all(20.0),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.error_outline, color: colorScheme.error, size: 48),
              const SizedBox(height: 16),
              Text("Error loading your profile.",
                  style:
                      textTheme.titleMedium?.copyWith(color: colorScheme.error),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text("Please check your connection and try again.",
                  style: textTheme.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
                onPressed: () => setState(() {
                  _dataLoadedFromFirestore = false;
                }),
              )
            ]),
          ));
        }

        // Si _dataLoadedFromFirestore n'est toujours pas vrai, on est en attente ou erreur gérée
        if (!_dataLoadedFromFirestore) {
          return const Center(
              child:
                  CircularProgressIndicator(key: Key("profile_initial_wait")));
        }

        String userEmail = widget.user.email ??
            userDataFromFirestore?['email'] as String? ??
            'N/A';
        Timestamp? createdAtTimestamp =
            userDataFromFirestore?['createdAt'] as Timestamp? ??
                userDataFromFirestore?['profileCreatedAt'] as Timestamp?;
        String memberSince = createdAtTimestamp != null
            ? DateFormat.yMMMMd().format(createdAtTimestamp.toDate())
            : 'N/A';
        String displayName = userDataFromFirestore?['displayName'] as String? ??
            widget.user.displayName ??
            userEmail.split('@')[0];

        final Map<String, dynamic> sourceMapForUI =
            _isEditingAll ? _currentEditValues : _originalPreferences;
        List<Widget> preferenceWidgets = [];

        for (var question in defaultOnboardingQuestions) {
          preferenceWidgets.add(_buildPreferenceItem(
              itemKey: question.id,
              currentValueForWidget: sourceMapForUI[question.id],
              question: question));
        }

        bool noPreferencesSetCurrentlyDisplayed = sourceMapForUI.values.every(
            (v) =>
                v == null ||
                (v is List && v.isEmpty) ||
                (v is Map &&
                    v.values.every((statVal) =>
                        statVal == null || statVal.toString().isEmpty)));

        if (noPreferencesSetCurrentlyDisplayed &&
            !_isEditingAll &&
            !_isSavingAll &&
            _dataLoadedFromFirestore) {
          return ListView(padding: const EdgeInsets.all(16.0), children: [
            _buildUserInfoSection(context, displayName, userEmail, memberSince),
            const SizedBox(height: 24),
            Center(
              child: Column(children: [
                Icon(Icons.fact_check_outlined,
                    size: 48,
                    color: colorScheme.primary.withAlpha((0.8 * 255).round())),
                const SizedBox(height: 12),
                Text("Set Your Preferences",
                    style: textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                      "Complete your fitness profile to get personalized AI workout plans tailored just for you.",
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                    icon: const Icon(Icons.edit_note_outlined),
                    label: const Text("Set Preferences Now"),
                    onPressed: () => _toggleEditAllMode(cancel: false),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary))
              ]),
            ),
            const SizedBox(height: 30),
            _buildSignOutButton(context),
          ]);
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (mounted && !_isEditingAll) {
              setState(() {
                _dataLoadedFromFirestore = false;
              });
            }
          },
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              _buildUserInfoSection(
                  context, displayName, userEmail, memberSince),
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
                            size: 18, color: colorScheme.primary),
                        label: Text("Edit All",
                            style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600)),
                        onPressed: () => _toggleEditAllMode(cancel: false),
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6))),
                ],
              ),
              const SizedBox(height: 10),
              if (_isSavingAll)
                const Center(
                    child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text("Saving your preferences...")
                        ]))),
              if (!_isSavingAll)
                _isEditingAll
                    ? Column(children: preferenceWidgets)
                    : GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount:
                            MediaQuery.of(context).size.width > 600 ? 2 : 1,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio:
                            (MediaQuery.of(context).size.width > 600
                                ? 4.5
                                : 5.5),
                        children: preferenceWidgets
                            .map((widget) => widget is ListTile
                                ? Card(
                                    elevation: 0.8,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(
                                            color: colorScheme.outlineVariant
                                                .withAlpha(
                                                    (0.3 * 255).round()))),
                                    child: widget)
                                : widget)
                            .toList(),
                      ),
              if (_isEditingAll && !_isSavingAll) ...[
                const SizedBox(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  OutlinedButton(
                      onPressed: () => _toggleEditAllMode(cancel: true),
                      child: const Text("Cancel"),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.onSurface,
                          side: BorderSide(color: colorScheme.outline),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10))),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                      icon: const Icon(Icons.save_alt_outlined, size: 20),
                      label: const Text("Save Changes"),
                      onPressed: _saveAllPreferences,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10))),
                ]),
              ],
              const SizedBox(height: 30),
              _buildSignOutButton(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserInfoSection(BuildContext context, String displayName,
      String email, String memberSince) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(children: [
        CircleAvatar(
            radius: 45,
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(Icons.person_outline,
                size: 50, color: colorScheme.onPrimaryContainer)),
        const SizedBox(height: 12),
        Text(displayName,
            style:
                textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        Text(email,
            style: textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant)),
        if (memberSince != 'N/A')
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text("Member since $memberSince",
                style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant
                        .withAlpha((0.7 * 255).round()))),
          ),
      ]),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: TextButton.icon(
          icon: Icon(Icons.logout, color: colorScheme.error, size: 20),
          label: Text("Sign Out",
              style: TextStyle(
                  color: colorScheme.error,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          onPressed: () async {
            final confirmSignOut = await showDialog<bool>(
              context: context,
              builder: (BuildContext dialogContext) => AlertDialog(
                title: const Text('Confirm Sign Out'),
                content: const Text('Are you sure you want to sign out?'),
                actions: <Widget>[
                  TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(dialogContext).pop(false)),
                  TextButton(
                    child: Text('Sign Out',
                        style: TextStyle(
                            color: Theme.of(dialogContext).colorScheme.error)),
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                  ),
                ],
              ),
            );
            if (confirmSignOut == true) {
              try {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.of(context, rootNavigator: true)
                      .pushNamedAndRemoveUntil(
                          '/home', (Route<dynamic> route) => false);
                }
              } catch (e) {
                print("Error during sign out or navigation: $e");
                if (mounted) {
                  _showErrorSnackBar("Sign out failed. Please try again.");
                }
              }
            }
          },
          style: TextButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
        ),
      ),
    );
  }

  bool _areMapsEqual(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    if (map1.length != map2.length) return false;
    for (var key in map1.keys) {
      if (!map2.containsKey(key)) return false;
      final val1 = map1[key];
      final val2 = map2[key];
      if (val1 is List && val2 is List) {
        if (val1.length != val2.length) return false;
        List<dynamic> sortedVal1 = List.from(val1);
        List<dynamic> sortedVal2 = List.from(val2);
        try {
          // Tenter de trier, mais continuer si ce n'est pas comparable directement
          sortedVal1.sort((a, b) => a.toString().compareTo(b.toString()));
          sortedVal2.sort((a, b) => a.toString().compareTo(b.toString()));
        } catch (e) {/* Ignorer si le tri échoue */}
        for (int i = 0; i < sortedVal1.length; i++) {
          if (sortedVal1[i].toString() != sortedVal2[i].toString()) {
            return false;
          }
        }
      } else if (val1 is Map<String, dynamic> && val2 is Map<String, dynamic>) {
        if (!_areMapsEqual(val1, val2)) return false;
      } else if (val1 is Map && val2 is Map) {
        // Fallback pour Map<dynamic, dynamic>
        if (!_areMapsEqual(_convertMapToMapStringDynamic(val1),
            _convertMapToMapStringDynamic(val2))) return false;
      } else if (val1?.toString() != val2?.toString()) {
        return false;
      }
    }
    return true;
  }

  IconData _getIconForOnboardingKey(String key) {
    switch (key) {
      case 'goal':
        return Icons.emoji_events_outlined;
      case 'gender':
        return Icons.wc_outlined;
      case 'physical_stats':
        return Icons.accessibility_new_outlined;
      case 'experience':
        return Icons.bar_chart_outlined;
      case 'frequency':
        return Icons.event_repeat_outlined;
      case 'session_duration_minutes':
        return Icons.timer_outlined; // <<--- AJOUTÉ
      case 'workout_days':
        return Icons.calendar_today_outlined;
      case 'equipment':
        return Icons.fitness_center_outlined;
      case 'focus_areas':
        return Icons.center_focus_strong_outlined;
      default:
        return Icons.help_outline; // Icône par défaut
    }
  }
}

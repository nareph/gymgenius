// lib/screens/tabs/profile_tab_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymgenius/models/onboarding_question.dart'; // For OnboardingQuestion and defaultOnboardingQuestions
import 'package:intl/intl.dart'; // For date formatting

// Extension for consistent string capitalization
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

// Defines the sub-keys and units for physical statistics for consistent handling.
const List<({String key, String unit, String label})> statSubKeyEntries = [
  (key: 'age', unit: 'years', label: 'Age'),
  (key: 'weight_kg', unit: 'kg', label: 'Weight'),
  (key: 'height_cm', unit: 'cm', label: 'Height'),
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

  // Helper to recursively convert a Map to Map<String, dynamic>
  Map<String, dynamic> _convertMapToMapStringDynamic(Map sourceMap) {
    final Map<String, dynamic> result = {};
    sourceMap.forEach((key, value) {
      final String stringKey = key.toString(); // Ensures keys are strings

      if (value is Map) {
        result[stringKey] =
            _convertMapToMapStringDynamic(value); // Recurse for nested maps
      } else if (value is List) {
        result[stringKey] =
            _convertListWithNestedConversion(value); // Handle lists
      } else {
        result[stringKey] = value;
      }
    });
    return result;
  }

  // Helper to recursively convert items in a List (if they are Maps or Lists)
  List<dynamic> _convertListWithNestedConversion(List sourceList) {
    return sourceList.map((item) {
      if (item is Map) {
        return _convertMapToMapStringDynamic(item); // Convert maps in lists
      } else if (item is List) {
        return _convertListWithNestedConversion(
            item); // Recurse for lists in lists
      }
      return item;
    }).toList();
  }

  OnboardingQuestion? _getQuestionById(String id) {
    try {
      return defaultOnboardingQuestions.firstWhere((q) => q.id == id);
    } catch (e) {
      print(
          "ProfileTabScreen: CRITICAL - OnboardingQuestion with ID '$id' not found. Error: $e");
      return null;
    }
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
    _currentEditValues = {};

    _numericInputControllers.forEach((_, controller) => controller.dispose());
    _numericInputControllers.clear();

    for (var question in defaultOnboardingQuestions) {
      dynamic valueFromSource = sourceData[question.id];

      if (question.id == 'physical_stats' &&
          question.type == QuestionType.numericInput) {
        Map<String, dynamic> statsMap;
        if (valueFromSource is Map<String, dynamic>) {
          statsMap = Map<String, dynamic>.from(valueFromSource); // Deep copy
        } else if (valueFromSource is Map) {
          // Fallback (should be rare if sourceData is converted)
          statsMap = _convertMapToMapStringDynamic(valueFromSource);
        } else {
          statsMap = {}; // Default empty
        }
        _currentEditValues[question.id] = statsMap;

        for (var subKeyEntry in statSubKeyEntries) {
          final controllerKey = '${question.id}_${subKeyEntry.key}';
          _numericInputControllers[controllerKey] = TextEditingController(
              text: statsMap[subKeyEntry.key]?.toString() ?? '');
        }
      } else if (question.type == QuestionType.numericInput) {
        _currentEditValues[question.id] = valueFromSource;
        _numericInputControllers[question.id] =
            TextEditingController(text: valueFromSource?.toString() ?? '');
      } else if (question.type == QuestionType.multipleChoice) {
        if (valueFromSource is List) {
          _currentEditValues[question.id] =
              List<String>.from(valueFromSource.map((e) => e.toString()));
        } else {
          _currentEditValues[question.id] = <String>[];
        }
      } else {
        _currentEditValues[question.id] = valueFromSource;
      }
    }
    if (mounted && _isEditingAll) {
      setState(() {});
    }
  }

  Widget _buildPreferenceItem({
    required String itemKey,
    required dynamic currentValueForWidget,
    required OnboardingQuestion question,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final String displayTitle = question.text.toCapitalizedDisplay();

    if (!_isEditingAll) {
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
                value: '', text: currentValueForWidget.toString()));
        displayValue = selectedOption.text;
      } else if (question.type == QuestionType.multipleChoice) {
        displayValue = (currentValueForWidget as List<dynamic>).map((val) {
          return question.options
              .firstWhere((opt) => opt.value == val,
                  orElse: () => AnswerOption(value: '', text: val.toString()))
              .text;
        }).join(', ');
      } else if (question.id == 'physical_stats' &&
          question.type == QuestionType.numericInput) {
        Map<String, dynamic> statsViewMap = {};
        if (currentValueForWidget is Map<String, dynamic>) {
          statsViewMap = currentValueForWidget;
        } else if (currentValueForWidget is Map) {
          // This case should be rare if data is sanitized upstream
          statsViewMap = _convertMapToMapStringDynamic(currentValueForWidget);
        }

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
        displayValue = currentValueForWidget.toString();
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
      // --- EDIT MODE ---
      Widget editingWidget;
      switch (question.type) {
        case QuestionType.singleChoice:
          editingWidget = DropdownButtonFormField<String>(
            key: ValueKey(
                '${itemKey}_dropdown_edit_${_currentEditValues[itemKey]}'),
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
            onChanged: (newValue) =>
                setState(() => _currentEditValues[itemKey] = newValue),
            isExpanded: true,
          );
          break;

        case QuestionType.multipleChoice:
          List<String> selectedValues = List<String>.from(
              _currentEditValues[itemKey] as List<dynamic>? ?? []);
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
                          onSelected: (isSelected) => setState(() {
                            isSelected
                                ? selectedValues.add(option.value)
                                : selectedValues.remove(option.value);
                            _currentEditValues[itemKey] = selectedValues;
                          }),
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
                        _currentEditValues[itemKey] as Map<String, dynamic>?;
                    return TextEditingController(
                        text: currentStatsMap?[statKey]?.toString() ?? '');
                  });

                  final Map<String, dynamic>? statsDataForController =
                      _currentEditValues[itemKey] as Map<String, dynamic>?;
                  final currentValueInMap =
                      statsDataForController?[statKey]?.toString() ?? '';

                  if (statController.text != currentValueInMap) {
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
                          isDense: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8))),
                      onChanged: (newValue) {
                        final Map<String, dynamic> currentStats =
                            (_currentEditValues[itemKey]
                                    as Map<String, dynamic>?) ??
                                <String, dynamic>{};
                        currentStats[statKey] = newValue.trim().isEmpty
                            ? null
                            : num.tryParse(newValue.trim());
                        _currentEditValues[itemKey] =
                            currentStats; // This ensures it's a Map<String, dynamic>
                      },
                    ),
                  );
                }).toList(),
              ],
            );
          } else {
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
              key: ValueKey('${itemKey}_numeric_edit'),
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                  labelText: displayTitle,
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
        default:
          editingWidget = Text("Unsupported edit type for '$itemKey'",
              style: TextStyle(color: colorScheme.error));
      }
      return Card(
        elevation: 1,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side:
                BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5))),
        child:
            Padding(padding: const EdgeInsets.all(12.0), child: editingWidget),
      );
    }
  }

  void _toggleEditAllMode({bool cancel = false}) {
    setState(() {
      final bool enteringEditMode = !_isEditingAll;
      _isEditingAll = !_isEditingAll;

      if (enteringEditMode) {
        _primeEditingStateWithData(
            _convertMapToMapStringDynamic(Map.from(_originalPreferences)));
      } else if (cancel) {
        _primeEditingStateWithData(
            _convertMapToMapStringDynamic(Map.from(_originalPreferences)));
      }
    });
  }

  Future<void> _saveAllPreferences() async {
    if (!mounted) return;
    setState(() => _isSavingAll = true);

    Map<String, dynamic> preferencesToSave = {};
    for (var question in defaultOnboardingQuestions) {
      final key = question.id;
      dynamic valueToSave;

      if (question.id == 'physical_stats' &&
          question.type == QuestionType.numericInput) {
        Map<String, dynamic> statsMapToSave = {};
        final Map<String, dynamic>? currentPhysicalStats =
            _currentEditValues[key]
                as Map<String, dynamic>?; // Use the typed map
        for (var subKeyEntry in statSubKeyEntries) {
          // Get value from _currentEditValues (which holds parsed numbers or null), not directly from controller text for saving
          final dynamic statValue = currentPhysicalStats?[subKeyEntry.key];
          statsMapToSave[subKeyEntry.key] =
              statValue; // This is already num? or null
        }
        valueToSave = statsMapToSave;
      } else if (question.type == QuestionType.numericInput) {
        // Value already parsed and stored in _currentEditValues
        valueToSave = _currentEditValues[key];
      } else {
        valueToSave = _currentEditValues[key];
      }
      preferencesToSave[key] = valueToSave;
    }

    try {
      await _firestore.collection('users').doc(widget.user.uid).set(
        {'onboardingData': preferencesToSave},
        SetOptions(merge: true),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Preferences updated successfully!"),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ));

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
      future:
          _firestore.collection('users').doc(widget.user.uid).get().then((doc) {
        if (doc.exists && doc.data() != null) {
          return doc;
        }
        return null;
      }).catchError((error) {
        print(
            "ProfileTabScreen: Error fetching user document in FutureBuilder: $error");
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

        if (snapshot.hasData && snapshot.data != null) {
          userDataFromFirestore = snapshot.data!.data();
          if (userDataFromFirestore != null) {
            final rawOnboardingData = userDataFromFirestore['onboardingData'];
            if (rawOnboardingData is Map) {
              loadedOnboardingDataFromFirestore =
                  _convertMapToMapStringDynamic(rawOnboardingData);
            } else {
              loadedOnboardingDataFromFirestore = {};
            }
          }
        } else if (snapshot.hasError && !_dataLoadedFromFirestore) {
          print(
              "ProfileTabScreen: FutureBuilder snapshot has error: ${snapshot.error}");
          return Center(
              child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Error loading your profile. Please check your connection and try again.",
              style: textTheme.bodyLarge?.copyWith(color: colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ));
        }

        if (!_isEditingAll) {
          if (!_dataLoadedFromFirestore ||
              !_areMapsEqual(
                  _originalPreferences, loadedOnboardingDataFromFirestore)) {
            _originalPreferences = _convertMapToMapStringDynamic(
                Map.from(loadedOnboardingDataFromFirestore));
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_isEditingAll) {
                _primeEditingStateWithData(_convertMapToMapStringDynamic(
                    Map.from(_originalPreferences)));
              }
            });
            if (!_dataLoadedFromFirestore) _dataLoadedFromFirestore = true;
          }
        } else {
          if (!_dataLoadedFromFirestore) _dataLoadedFromFirestore = true;
        }

        String userEmail = widget.user.email ??
            userDataFromFirestore?['email'] as String? ??
            'N/A';
        Timestamp? createdAtTimestamp =
            userDataFromFirestore?['createdAt'] as Timestamp?;
        String memberSince = createdAtTimestamp != null
            ? DateFormat.yMMMMd().format(createdAtTimestamp.toDate())
            : 'N/A';
        String displayName = userDataFromFirestore?['displayName'] as String? ??
            widget.user.displayName ??
            userEmail.split('@')[0];

        final Map<String, dynamic> sourceMapForCurrentUI =
            _isEditingAll ? _currentEditValues : _originalPreferences;

        List<Widget> preferenceWidgets = [];
        for (var question in defaultOnboardingQuestions) {
          if (_isEditingAll && !_currentEditValues.containsKey(question.id)) {
            if (question.type == QuestionType.multipleChoice) {
              _currentEditValues[question.id] = <String>[];
            } else if (question.id == 'physical_stats') {
              _currentEditValues[question.id] = <String, dynamic>{
                for (var subKeyEntry in statSubKeyEntries) subKeyEntry.key: null
              };
            } else {
              _currentEditValues[question.id] = null;
            }
          }
          preferenceWidgets.add(_buildPreferenceItem(
            itemKey: question.id,
            currentValueForWidget: sourceMapForCurrentUI[question.id],
            question: question,
          ));
        }

        if (preferenceWidgets.whereType<ListTile>().isEmpty &&
            sourceMapForCurrentUI.values.every((v) =>
                v == null ||
                (v is List && v.isEmpty) ||
                (v is Map && v.isEmpty)) &&
            !_isEditingAll &&
            !_isSavingAll) {
          return ListView(padding: const EdgeInsets.all(16.0), children: [
            _buildUserInfoSection(context, displayName, userEmail, memberSince),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Icon(Icons.fact_check_outlined,
                      size: 48, color: colorScheme.primary.withOpacity(0.8)),
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
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildSignOutButton(context),
          ]);
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _dataLoadedFromFirestore = false;
            });
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
                                                .withOpacity(0.3))),
                                    child: widget)
                                : widget)
                            .toList(),
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
                          foregroundColor: colorScheme.onSurface,
                          side: BorderSide(color: colorScheme.outline),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        )),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                        icon: const Icon(Icons.save_alt_outlined, size: 20),
                        label: const Text("Save Changes"),
                        onPressed: _saveAllPreferences,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        )),
                  ],
                ),
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
                    color: colorScheme.onSurfaceVariant.withOpacity(0.7))),
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
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                  ),
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
              await FirebaseAuth.instance.signOut();
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
        List<dynamic> sortedVal1 = List.from(val1)..sort();
        List<dynamic> sortedVal2 = List.from(val2)..sort();
        for (int i = 0; i < sortedVal1.length; i++) {
          if (sortedVal1[i].toString() != sortedVal2[i].toString())
            return false;
        }
      } else if (val1 is Map<String, dynamic> && val2 is Map<String, dynamic>) {
        if (!_areMapsEqual(val1, val2)) return false;
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
      case 'workout_days':
        return Icons.calendar_today_outlined;
      case 'equipment':
        return Icons.fitness_center_outlined;
      case 'focus_areas':
        return Icons.center_focus_strong_outlined;
      default:
        return Icons.checklist_rtl_outlined;
    }
  }
}

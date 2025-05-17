// lib/screens/tabs/profile_tab_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymgenius/models/onboarding_question.dart'; // For defaultOnboardingQuestions
import 'package:gymgenius/services/logger_service.dart';
import 'package:intl/intl.dart'; // For date formatting

// Extension for easy string capitalization for display purposes.
extension StringCasingExtension on String {
  String toCapitalizedDisplay() {
    if (isEmpty) return this;
    return replaceAll('_', ' ') // Replace underscores with spaces
        .split(' ') // Split into words
        .map((word) => word.isEmpty
            ? ''
            : word[0].toUpperCase() +
                word.substring(1).toLowerCase()) // Capitalize each word
        .join(' '); // Join back with spaces
  }
}

// Configuration for physical stat sub-keys, used for generating numeric input fields.
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

// ProfileTabScreen: Displays and allows editing of the user's profile information,
// primarily their onboarding preferences.
class ProfileTabScreen extends StatefulWidget {
  final User user; // The currently authenticated user.
  const ProfileTabScreen({super.key, required this.user});

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isEditingAll = false; // Tracks if the profile is in edit mode.
  bool _isSavingAll = false; // Tracks if data is currently being saved.

  // Stores the values currently being edited by the user.
  Map<String, dynamic> _currentEditValues = {};
  // Stores the original preference values fetched from Firestore. Used for comparison and reverting.
  Map<String, dynamic> _originalPreferences = {};
  // Manages TextEditingControllers for numeric input fields, keyed by question/sub-question ID.
  final Map<String, TextEditingController> _numericInputControllers = {};
  // Flag to track if initial data has been loaded from Firestore.
  bool _dataLoadedFromFirestore = false;

  // Recursively converts a Map (potentially with nested Maps/Lists from Firestore)
  // to a Map<String, dynamic> suitable for internal use.
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

  // Recursively converts a List (potentially with nested Maps/Lists from Firestore)
  // to a List<dynamic> with nested structures also converted.
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

  // Displays an error message using a SnackBar.
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
    // Initial data fetch will be handled by the FutureBuilder in the build method.
    Log.debug("ProfileTabScreen initialized for user ${widget.user.uid}");
  }

  @override
  void dispose() {
    // Dispose all TextEditingControllers to prevent memory leaks.
    _numericInputControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  // Initializes or resets the _currentEditValues and _numericInputControllers
  // based on the provided sourceData (typically _originalPreferences).
  // This is called when entering edit mode or canceling edits.
  void _primeEditingStateWithData(Map<String, dynamic> sourceData) {
    _currentEditValues = {};
    _numericInputControllers.forEach(
        (_, controller) => controller.dispose()); // Dispose old controllers
    _numericInputControllers.clear();

    for (var question in defaultOnboardingQuestions) {
      dynamic valueFromSource = sourceData[question.id];

      if (question.id == 'physical_stats' &&
          question.type == QuestionType.numericInput) {
        Map<String, dynamic> statsMap;
        if (valueFromSource is Map<String, dynamic>) {
          statsMap = Map<String, dynamic>.from(valueFromSource);
        } else if (valueFromSource is Map) {
          // Handle Map<dynamic, dynamic> from Firestore
          statsMap = _convertMapToMapStringDynamic(valueFromSource);
        } else {
          statsMap = {};
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
        } else if (valueFromSource is String && valueFromSource.isNotEmpty) {
          _currentEditValues[question.id] = [valueFromSource];
        } else {
          _currentEditValues[question.id] = <String>[];
        }
      } else {
        // singleChoice
        _currentEditValues[question.id] = valueFromSource?.toString();
      }
    }
  }

  // Builds the UI for displaying or editing a single preference item.
  Widget _buildPreferenceItem({
    required String itemKey,
    required dynamic currentValueForWidget,
    required OnboardingQuestion question,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final String displayTitle = question.text;
    final inputDecorationTheme = Theme.of(context).inputDecorationTheme;

    if (!_isEditingAll) {
      // --- READ-ONLY DISPLAY MODE ---
      String displayValue;
      // Determine display value based on type and current value
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
      // --- EDITING MODE ---
      Widget editingWidget;
      switch (question.type) {
        case QuestionType.singleChoice:
          String? currentValueInEdit = _currentEditValues[itemKey]?.toString();
          if (currentValueInEdit != null &&
              !question.options.any((opt) => opt.value == currentValueInEdit)) {
            Log.warning(
                "ProfileTabScreen Warning: Valuer $currentValueInEdit for question $question.id not found in options. Setting Dropdown value to null.");

            currentValueInEdit = null;
          }
          editingWidget = DropdownButtonFormField<String>(
            key: ValueKey('${itemKey}_dropdown_edit_$currentValueInEdit'),
            decoration: InputDecoration(
                labelText: displayTitle,
                isDense: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            value: currentValueInEdit,
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
            hint: currentValueInEdit == null
                ? Text("Select...",
                    style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant.withAlpha(153)))
                : null, // Approx 60% opacity
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
                                      .withAlpha(153)), // Approx 60% opacity
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
                }),
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
                              .withAlpha(153)), // Approx 60% opacity
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
                color: colorScheme.outlineVariant
                    .withAlpha(128))), // Approx 50% opacity
        child:
            Padding(padding: const EdgeInsets.all(12.0), child: editingWidget),
      );
    }
  }

  // Toggles the edit mode for all preferences.
  void _toggleEditAllMode({bool cancel = false}) {
    if (!mounted) return;
    setState(() {
      final bool enteringEditMode = !_isEditingAll;
      _isEditingAll = !_isEditingAll;
      if (enteringEditMode) {
        // When entering edit mode, prime the edit values with current original preferences.
        _primeEditingStateWithData(
            _convertMapToMapStringDynamic(Map.from(_originalPreferences)));
      } else if (cancel) {
        // If canceling, _primeEditingStateWithData is not strictly needed here as the next build
        // in read-only mode will use _originalPreferences.
        // However, resetting controllers might be good if they were changed.
        _primeEditingStateWithData(
            _convertMapToMapStringDynamic(Map.from(_originalPreferences)));
      }
      // If exiting edit mode to save, _currentEditValues holds the pending changes.
    });
  }

  // Saves all currently edited preferences to Firestore.
  Future<void> _saveAllPreferences() async {
    if (!mounted) return;
    setState(() => _isSavingAll = true);

    Map<String, dynamic> preferencesToSave = {};
    // Initialize all known preference keys to null.
    // This ensures that if a user clears a field, it's saved as null (or an empty list for multi-choice).
    for (var question in defaultOnboardingQuestions) {
      if (question.type == QuestionType.multipleChoice) {
        preferencesToSave[question.id] =
            []; // Default to empty list for multi-select
      } else {
        preferencesToSave[question.id] = null;
      }
    }
    _currentEditValues.forEach((key, value) {
      final question = defaultOnboardingQuestions.firstWhere((q) => q.id == key,
          orElse: () => const OnboardingQuestion(
              id: "unknown", text: "", type: QuestionType.singleChoice));
      if (question.id == "unknown") {
        return; // Should not happen if _currentEditValues is primed correctly
      }

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
        // Store the physical_stats map only if it contains at least one non-null value.
        preferencesToSave[key] = hasAnyStatValue ? statsMapToSave : null;
      } else if (question.type == QuestionType.numericInput) {
        final dynamic numValue = value;
        if (numValue is String && numValue.trim().isNotEmpty) {
          preferencesToSave[key] = num.tryParse(numValue.trim());
        } else if (numValue is num) {
          preferencesToSave[key] = numValue;
        } else {
          preferencesToSave[key] =
              null; // Store null if empty or not a valid number
        }
      } else if (value is List && value.isEmpty) {
        preferencesToSave[key] =
            null; // Store null for empty multi-select lists
      } else if (value != null && (value is String ? value.isNotEmpty : true)) {
        preferencesToSave[key] = value;
      } else {
        preferencesToSave[key] =
            null; // Ensure other empty/null values are explicitly null
      }
    });

    // Ensure the 'completed' flag is set correctly within the onboardingData map.
    preferencesToSave['completed'] =
        true; // Profile edits imply onboarding is considered complete/interacted with.

    try {
      final Map<String, dynamic> dataToSetInFirestore = {
        'onboardingData': preferencesToSave,
        'onboardingCompleted': true, // Top-level flag for AuthWrapper
        'profileLastUpdatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(widget.user.uid).set(
            dataToSetInFirestore,
            SetOptions(merge: true),
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Preferences updated successfully!"),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ));
      // Update _originalPreferences to reflect the newly saved data.
      _originalPreferences =
          _convertMapToMapStringDynamic(Map.from(preferencesToSave));
      _isEditingAll = false; // Exit edit mode
      Log.info("Preferences updated successfully for user ${widget.user.uid}");
    } catch (e, stack) {
      if (!mounted) return;
      Log.error("Error saving preferences for user ${widget.user.uid}",
          error: e, stackTrace: stack);

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
      future: _dataLoadedFromFirestore && _isEditingAll
          ? Future.value(null)
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
              Log.error(
                  "ProfileTabScreen: Error fetching user document for ${widget.user.uid}",
                  error: error);
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

        if (snapshot.hasData && snapshot.data != null) {
          userDataFromFirestore = snapshot.data!.data();
          if (userDataFromFirestore != null) {
            final rawOnboardingData = userDataFromFirestore['onboardingData'];
            if (rawOnboardingData is Map) {
              loadedOnboardingDataFromFirestore =
                  _convertMapToMapStringDynamic(rawOnboardingData);
            }
            if (!_dataLoadedFromFirestore) {
              _originalPreferences =
                  Map.from(loadedOnboardingDataFromFirestore);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  if (!_isEditingAll) {
                    _primeEditingStateWithData(Map.from(_originalPreferences));
                  }
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
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _originalPreferences = {};
              if (!_isEditingAll) _primeEditingStateWithData({});
              setState(() {
                _dataLoadedFromFirestore = true;
              });
            }
          });
        } else if (snapshot.hasError && !_dataLoadedFromFirestore) {
          Log.error("Failed to load profile data for ${widget.user.uid}");
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
              child: Card(
                // Added Card for better visual grouping
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(children: [
                    Icon(Icons.fact_check_outlined,
                        size: 56,
                        color: colorScheme.primary), // Slightly larger icon
                    const SizedBox(height: 16),
                    Text("Set Your Preferences",
                        style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight
                                .bold)), // headlineSmall for more emphasis
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                          "Complete your fitness profile to get personalized AI workout plans tailored just for you.",
                          style: textTheme
                              .bodyLarge, // bodyLarge for better readability
                          textAlign: TextAlign.center),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                        icon: const Icon(Icons.edit_note_outlined),
                        label: const Text("Set Preferences Now"),
                        onPressed: () => _toggleEditAllMode(cancel: false),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12) // More padding
                            ))
                  ]),
                ),
              ),
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
                            size: 20,
                            color: colorScheme.primary), // Slightly larger icon
                        label: Text("Edit All",
                            style: textTheme.labelLarge?.copyWith(
                                color: colorScheme.primary,
                                fontWeight:
                                    FontWeight.bold)), // Using labelLarge
                        onPressed: () => _toggleEditAllMode(cancel: false),
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8))), // Adjusted padding
                ],
              ),
              const SizedBox(height: 12), // Increased spacing

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
                    ? Column(
                        children:
                            preferenceWidgets) // In edit mode, preferences are in a Column of Cards
                    : GridView.count(
                        // In read-only mode, use a Grid for better layout
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: MediaQuery.of(context).size.width > 700
                            ? 2
                            : 1, // Responsive columns
                        crossAxisSpacing: 12, // Increased spacing
                        mainAxisSpacing: 12, // Increased spacing
                        childAspectRatio:
                            (MediaQuery.of(context).size.width > 700
                                ? 4.8
                                : 5.8), // Adjusted aspect ratio
                        children: preferenceWidgets
                            .map((widget) => widget
                                        is ListTile // Ensure only ListTiles (which are inside Cards in edit mode) are wrapped in another Card
                                    ? Card(
                                        elevation:
                                            1, // Consistent elevation for read-only cards
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            side: BorderSide(
                                                color: colorScheme
                                                    .outlineVariant
                                                    .withAlpha(
                                                        77))), // Approx 30% opacity
                                        child: widget)
                                    : widget // If it's already a Card (from edit mode), don't wrap again
                                )
                            .toList(),
                      ),

              if (_isEditingAll && !_isSavingAll) ...[
                const SizedBox(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  OutlinedButton(
                      onPressed: () => _toggleEditAllMode(cancel: true),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.onSurface,
                          side: BorderSide(color: colorScheme.outline),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12)),
                      child: const Text("Cancel")), // Consistent padding
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                      icon: const Icon(Icons.save_alt_outlined, size: 20),
                      label: const Text("Save Changes"),
                      onPressed: _saveAllPreferences,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12))), // Consistent padding
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
            child: Icon(Icons.person_outline_rounded,
                size: 50,
                color: colorScheme.onPrimaryContainer)), // Rounded icon
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
                        .withAlpha((178).round()))), // ~70% opacity
          ),
      ]),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: TextButton.icon(
          icon: Icon(Icons.logout_rounded,
              color: Theme.of(context).colorScheme.error, size: 20),
          label: Text("Sign Out",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
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
                Log.debug("User ${widget.user.uid} signed out successfully");
                if (mounted) {
                  Navigator.of(context, rootNavigator: true)
                      .pushNamedAndRemoveUntil(
                          '/home', (Route<dynamic> route) => false);
                }
              } catch (e, stack) {
                Log.error("Error during sign out for user ${widget.user.uid}",
                    error: e, stackTrace: stack);
                if (mounted) {
                  _showErrorSnackBar("Sign out failed. Please try again.");
                }
              }
            }
          },
        ),
      ),
    );
  }

/*   bool _areMapsEqual(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    if (map1.length != map2.length) return false;
    for (var key in map1.keys) {
      if (!map2.containsKey(key)) return false;
      final val1 = map1[key];
      final val2 = map2[key];
      if (val1 is List && val2 is List) {
        if (val1.length != val2.length) return false;
        // For lists, create a mutable copy, sort, then compare element by element for content equality
        List<String> sortedVal1 =
            List<String>.from(val1.map((e) => e.toString()))..sort();
        List<String> sortedVal2 =
            List<String>.from(val2.map((e) => e.toString()))..sort();
        for (int i = 0; i < sortedVal1.length; i++) {
          if (sortedVal1[i] != sortedVal2[i]) {
            return false;
          }
        }
      } else if (val1 is Map<String, dynamic> && val2 is Map<String, dynamic>) {
        if (!_areMapsEqual(val1, val2)) return false;
      } else if (val1 is Map && val2 is Map) {
        if (!_areMapsEqual(_convertMapToMapStringDynamic(val1),
            _convertMapToMapStringDynamic(val2))) {
          return false;
        }
      } else if (val1?.toString() != val2?.toString()) {
        return false;
      }
    }
    return true;
  } */

  IconData _getIconForOnboardingKey(String key) {
    switch (key) {
      case 'goal':
        return Icons.flag_outlined; // Changed icon
      case 'gender':
        return Icons.wc_outlined;
      case 'physical_stats':
        return Icons.accessibility_new_outlined;
      case 'experience':
        return Icons.insights_outlined; // Changed icon
      case 'frequency':
        return Icons.event_repeat_outlined;
      case 'session_duration_minutes':
        return Icons.timer_outlined;
      case 'workout_days':
        return Icons.date_range_outlined; // Changed icon
      case 'equipment':
        return Icons.fitness_center_outlined;
      case 'focus_areas':
        return Icons.filter_center_focus_outlined; // Changed icon
      default:
        return Icons.help_outline_rounded; // Rounded default icon
    }
  }
}

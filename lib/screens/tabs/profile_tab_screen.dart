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
    // No initial data load here, FutureBuilder handles it
  }

  @override
  void dispose() {
    _numericInputControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _primeEditingStateWithData(Map<String, dynamic> sourceData) {
    _currentEditValues = {}; // Start fresh

    // Dispose existing controllers before creating new ones
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
        } else if (valueFromSource is String) {
          // Handle if accidentally saved as single string
          _currentEditValues[question.id] = [valueFromSource];
        } else {
          _currentEditValues[question.id] = <String>[];
        }
      } else {
        _currentEditValues[question.id] = valueFromSource;
      }
    }
    // No setState here as this is called during build phases or state transitions
    // where setState might already be pending or would cause issues.
    // The calling context (e.g., _toggleEditAllMode) should handle setState if needed.
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

                  // Ensure controller exists and is updated if necessary
                  // This part needs careful handling to avoid issues during build
                  TextEditingController statController =
                      _numericInputControllers.putIfAbsent(controllerKey, () {
                    final Map<String, dynamic>? currentStatsMap =
                        _currentEditValues[itemKey] as Map<String, dynamic>?;
                    return TextEditingController(
                        text: currentStatsMap?[statKey]?.toString() ?? '');
                  });
                  // Update controller if value changed elsewhere (less common in direct edit mode)
                  final Map<String, dynamic>? statsDataForController =
                      _currentEditValues[itemKey] as Map<String, dynamic>?;
                  final currentValueInMap =
                      statsDataForController?[statKey]?.toString() ?? '';
                  if (statController.text != currentValueInMap) {
                    // Schedule update after build to avoid conflicts
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
                      key: ValueKey(controllerKey), // Use a stable key
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
                            Map<String, dynamic>.from(_currentEditValues[
                                    itemKey] as Map<dynamic, dynamic>? ??
                                <String, dynamic>{}); // Ensure it's a new map

                        currentStats[statKey] = newValue.trim().isEmpty
                            ? null
                            : num.tryParse(newValue.trim());
                        // No setState here, _currentEditValues is updated directly.
                        // The parent widget's setState (e.g., when saving) will trigger rebuild.
                        _currentEditValues[itemKey] = currentStats;
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

            // Update controller if value changed elsewhere
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
                  '${itemKey}_numeric_edit_${_currentEditValues[itemKey]}'), // Add value to key for recreation if needed
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
            side: BorderSide(
                color: colorScheme.outlineVariant
                    .withAlpha((255 * 0.5).round()))), // FIXED withOpacity
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
        // When entering edit mode, prime with a DEEP COPY of original preferences
        _primeEditingStateWithData(
            _convertMapToMapStringDynamic(Map.from(_originalPreferences)));
      } else if (cancel) {
        // When cancelling, revert _currentEditValues (implicitly handled by _primeEditingStateWithData)
        // and ensure original preferences are re-applied to view if needed.
        // _primeEditingStateWithData is called by FutureBuilder when not editing,
        // so explicit call here might be redundant if data hasn't changed from server.
        // For safety, we can re-prime.
        _primeEditingStateWithData(
            _convertMapToMapStringDynamic(Map.from(_originalPreferences)));
      }
      // If saving, _saveAllPreferences will handle setting _isEditingAll = false
      // and updating _originalPreferences.
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
            _currentEditValues[key] as Map<String, dynamic>?;
        for (var subKeyEntry in statSubKeyEntries) {
          final dynamic statValue = currentPhysicalStats?[subKeyEntry.key];
          statsMapToSave[subKeyEntry.key] = statValue;
        }
        valueToSave = statsMapToSave;
      } else if (question.type == QuestionType.numericInput) {
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

      // Update original preferences with a DEEP COPY of the saved data
      _originalPreferences =
          _convertMapToMapStringDynamic(Map.from(preferencesToSave));
      _isEditingAll = false; // Exit edit mode
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
        return null; // Return null if doc doesn't exist or data is null
      }).catchError((error) {
        print(
            "ProfileTabScreen: Error fetching user document in FutureBuilder: $error");
        // Potentially show an error to the user or retry
        if (mounted) {
          _showErrorSnackBar(
              "Could not load profile data. Please check connection.");
        }
        return null; // Return null on error to handle in builder
      }),
      builder: (BuildContext context,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>?> snapshot) {
        // Handle initial loading state more explicitly
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
          }
        } else if (snapshot.hasError && !_dataLoadedFromFirestore) {
          // Error state already handled by catchError in future, but can add UI here
          print(
              "ProfileTabScreen: FutureBuilder snapshot has error: ${snapshot.error}");
          return Center(
              child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: colorScheme.error, size: 48),
                const SizedBox(height: 16),
                Text(
                  "Error loading your profile.",
                  style:
                      textTheme.titleMedium?.copyWith(color: colorScheme.error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Please check your connection and try again.",
                  style: textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text("Retry"),
                  onPressed: () {
                    if (mounted) {
                      setState(() {
                        _dataLoadedFromFirestore =
                            false; // Reset flag to allow FutureBuilder to refetch
                      });
                    }
                  },
                )
              ],
            ),
          ));
        }

        // This block ensures that _originalPreferences and _currentEditValues are primed correctly
        // especially when not in edit mode or when data is first loaded.
        if (!_isEditingAll) {
          // If not editing, _originalPreferences should reflect the latest from Firestore.
          // Only update if the new data is different to prevent unnecessary rebuilds/re-priming.
          if (!_dataLoadedFromFirestore ||
              !_areMapsEqual(
                  _originalPreferences, loadedOnboardingDataFromFirestore)) {
            _originalPreferences = _convertMapToMapStringDynamic(
                Map.from(loadedOnboardingDataFromFirestore));
            // Prime _currentEditValues as well, for when we switch to edit mode.
            // This happens in a post frame callback to avoid calling setState during build.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_isEditingAll) {
                // Double check _isEditingAll in callback
                _primeEditingStateWithData(_convertMapToMapStringDynamic(
                    Map.from(_originalPreferences)));
                if (!_dataLoadedFromFirestore) {
                  // Set _dataLoadedFromFirestore true after first successful load and prime
                  // to prevent continuous re-priming if FutureBuilder rebuilds frequently
                  // without actual data changes.
                  _dataLoadedFromFirestore = true;
                  if (mounted)
                    setState(
                        () {}); // Trigger a rebuild to use the newly primed data.
                }
              }
            });
          }
        } else {
          // If already editing, _currentEditValues holds the user's ongoing changes.
          // We don't want to overwrite them with fresh data from Firestore automatically.
          // However, if _dataLoadedFromFirestore is false, it means this is the first load
          // *while* _isEditingAll is true (e.g. screen was left in edit mode, app restarted).
          // In this rare case, we might want to prime _currentEditValues.
          if (!_dataLoadedFromFirestore) {
            _primeEditingStateWithData(_convertMapToMapStringDynamic(
                Map.from(loadedOnboardingDataFromFirestore)));
            _originalPreferences = _convertMapToMapStringDynamic(Map.from(
                loadedOnboardingDataFromFirestore)); // also update original
            _dataLoadedFromFirestore = true;
            // Potentially call setState if mounted to reflect, though this scenario is tricky
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() {});
            });
          }
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
          // Ensure _currentEditValues has an entry for each question when editing,
          // especially if data is missing from Firestore for that key.
          if (_isEditingAll && !_currentEditValues.containsKey(question.id)) {
            if (question.type == QuestionType.multipleChoice) {
              _currentEditValues[question.id] = <String>[];
            } else if (question.id == 'physical_stats') {
              _currentEditValues[question.id] = <String, dynamic>{
                for (var subKeyEntry in statSubKeyEntries) subKeyEntry.key: null
              };
              // Prime controllers for physical_stats if entering edit mode with no previous data
              for (var subKeyEntry in statSubKeyEntries) {
                final controllerKey = '${question.id}_${subKeyEntry.key}';
                if (!_numericInputControllers.containsKey(controllerKey)) {
                  _numericInputControllers[controllerKey] =
                      TextEditingController(text: '');
                }
              }
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
            !_isSavingAll &&
            _dataLoadedFromFirestore) {
          // Only show this if data has been loaded
          return ListView(padding: const EdgeInsets.all(16.0), children: [
            _buildUserInfoSection(context, displayName, userEmail, memberSince),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Icon(Icons.fact_check_outlined,
                      size: 48,
                      color: colorScheme.primary
                          .withAlpha((255 * 0.8).round())), // FIXED withOpacity
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
            if (mounted) {
              setState(() {
                _dataLoadedFromFirestore =
                    false; // Reset flag to allow FutureBuilder to refetch
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
                                                .withAlpha((255 * 0.3)
                                                    .round()))), // FIXED withOpacity
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
                    color: colorScheme.onSurfaceVariant
                        .withAlpha((255 * 0.7).round()))), // FIXED withOpacity
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
              try {
                await FirebaseAuth.instance.signOut();
                // Force navigation to /home after sign-out is complete
                // Ensure this context is still valid.
                if (mounted) {
                  // Use pushNamedAndRemoveUntil to clear the stack and go to /home
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/home', // Your route for the home/login screen
                    (Route<dynamic> route) =>
                        false, // Removes all previous routes
                  );
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
        // Create copies for sorting to avoid modifying original lists
        List<dynamic> sortedVal1 = List.from(val1);
        List<dynamic> sortedVal2 = List.from(val2);

        // Robust sorting: convert items to string for comparison if types might differ
        try {
          sortedVal1.sort((a, b) => a.toString().compareTo(b.toString()));
          sortedVal2.sort((a, b) => a.toString().compareTo(b.toString()));
        } catch (e) {
          // If items are not comparable (e.g., complex objects without toString),
          // this naive list comparison might fail. For simple lists of strings/numbers it's fine.
          print(
              "Warning: Could not sort lists for comparison in _areMapsEqual: $e");
          // Fallback to direct element-by-element comparison if sorting fails,
          // though order dependency is then a factor.
          // For now, we proceed with the sorted comparison assumption.
        }

        for (int i = 0; i < sortedVal1.length; i++) {
          if (sortedVal1[i].toString() != sortedVal2[i].toString()) {
            return false;
          }
        }
      } else if (val1 is Map<String, dynamic> && val2 is Map<String, dynamic>) {
        if (!_areMapsEqual(val1, val2)) return false;
      } else if (val1 is Map && val2 is Map) {
        // Handle Map<Object?, Object?>
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

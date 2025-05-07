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

// Définition des sous-clés et unités pour les statistiques physiques
const List<({String key, String unit})> statSubKeyEntries = [
  (key: 'age', unit: 'years'),
  (key: 'weight_kg', unit: 'kg'),
  (key: 'height_cm', unit: 'cm'),
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

  OnboardingQuestion? _getQuestionById(String id) {
    try {
      return defaultOnboardingQuestions.firstWhere((q) => q.id == id);
    } catch (e) {
      print(
          "ProfileTab: CRITICAL - OnboardingQuestion with ID '$id' not found. Error: $e");
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

  void _primeEditingStateWithData(Map<String, dynamic> dataToEditFrom) {
    _currentEditValues = {};

    _numericInputControllers.forEach((_, controller) => controller.dispose());
    _numericInputControllers.clear();

    for (var question in defaultOnboardingQuestions) {
      dynamic valueFromSource = dataToEditFrom[question.id];

      if (question.id == 'physical_stats' &&
          question.type == QuestionType.numericInput) {
        Map<String, dynamic> statsMap = {};
        if (valueFromSource is Map) {
          statsMap = Map<String, dynamic>.from(valueFromSource);
        }
        _currentEditValues[question.id] = statsMap;

        for (var subKeyEntry in statSubKeyEntries) {
          final controllerKey = '${question.id}_${subKeyEntry.key}';
          _numericInputControllers[controllerKey] = TextEditingController(
              text: statsMap[subKeyEntry.key]?.toString() ?? '');
        }
      } else if (question.type == QuestionType.numericInput) {
        _currentEditValues[question.id] = valueFromSource;
        // _numericInputControllers[question.id] = TextEditingController(text: valueFromSource?.toString() ?? '');
      } else if (question.type == QuestionType.multipleChoice) {
        _currentEditValues[question.id] =
            List<String>.from(valueFromSource as List<dynamic>? ?? <String>[]);
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
    final String displayTitle = question.text.toCapitalizedDisplay();

    if (!_isEditingAll) {
      String displayValue;
      if (currentValueForWidget == null ||
              (currentValueForWidget is List &&
                  currentValueForWidget.isEmpty) ||
              (currentValueForWidget is Map &&
                  currentValueForWidget.isEmpty &&
                  itemKey !=
                      'physical_stats') || // physical_stats peut être un map vide initialement
              (itemKey == 'physical_stats' &&
                  (currentValueForWidget as Map).values.every((v) =>
                      v == null)) // Si toutes les valeurs de stats sont null
          ) {
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
        final stats = currentValueForWidget as Map<String, dynamic>? ?? {};
        displayValue = statSubKeyEntries
            .map((subKeyEntry) {
              final subKey = subKeyEntry.key;
              final unit = subKeyEntry.unit;
              final value = stats[subKey];
              if (value != null) {
                return "${subKey.toCapitalizedDisplay()}: $value${unit.isNotEmpty ? ' $unit' : ''}";
              }
              return null;
            })
            .where((s) => s != null)
            .join(' | ');
        if (displayValue.isEmpty) displayValue = 'Not set';
      } else {
        displayValue = currentValueForWidget.toString();
        // Si vous aviez un champ 'unit' sur OnboardingQuestion pour les numericInput simples :
        // if (question.type == QuestionType.numericInput && question.unit != null && question.unit!.isNotEmpty) {
        //   displayValue += ' ${question.unit}';
        // }
      }
      return ListTile(
        dense: true,
        leading: Icon(_getIconForOnboardingKey(itemKey),
            color: colorScheme.primary, size: 20),
        title: Text(displayTitle,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            overflow: TextOverflow.ellipsis),
        subtitle: Text(displayValue,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
            overflow: TextOverflow.ellipsis,
            maxLines: 2),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      );
    } else {
      // --- MODE ÉDITION ---
      Widget editingWidget;
      switch (question.type) {
        case QuestionType.singleChoice:
          editingWidget = DropdownButtonFormField<String>(
            key: ValueKey('${itemKey}_dropdown_edit'),
            decoration: InputDecoration(
                labelText: displayTitle,
                isDense: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            value: currentValueForWidget?.toString(),
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
              List<String>.from(currentValueForWidget as List<dynamic>? ?? []);
          editingWidget = Column(
            key: ValueKey('${itemKey}_multichoice_edit'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.only(bottom: 4.0, top: 8.0),
                  child: Text(displayTitle,
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
          if (question.id == 'physical_stats') {
            editingWidget = Column(
              key: ValueKey('${itemKey}_numericgroup_edit'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                    child: Text(displayTitle,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurfaceVariant))),
                ...statSubKeyEntries.map((subKeyEntry) {
                  final statKey = subKeyEntry.key;
                  final unit = subKeyEntry.unit;
                  final controllerKey = '${itemKey}_$statKey';

                  TextEditingController statController =
                      _numericInputControllers.putIfAbsent(controllerKey, () {
                    final currentStatsMap =
                        _currentEditValues[itemKey] as Map<String, dynamic>? ??
                            {};
                    return TextEditingController(
                        text: currentStatsMap[statKey]?.toString() ?? '');
                  });
                  final String currentValueInMap = (_currentEditValues[itemKey]
                              as Map<String, dynamic>?)?[statKey]
                          ?.toString() ??
                      '';
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
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: TextField(
                      key: ValueKey(controllerKey),
                      controller: statController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                          labelText: statKey.toCapitalizedDisplay() +
                              (unit.isNotEmpty
                                  ? ' ($unit)'
                                  : ''), // AJOUT DE L'UNITÉ
                          isDense: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8))),
                      onChanged: (newValue) {
                        final currentStats = _currentEditValues[itemKey]
                                as Map<String, dynamic>? ??
                            <String, dynamic>{};
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
            // Pour d'autres numericInput simples
            TextEditingController controller =
                _numericInputControllers.putIfAbsent(
                    itemKey,
                    () => TextEditingController(
                        text: currentValueForWidget?.toString() ?? ''));
            final String currentValueInMap =
                currentValueForWidget?.toString() ?? '';
            if (controller.text != currentValueInMap) {
              controller.text = currentValueInMap;
            }
            editingWidget = TextField(
              key: ValueKey(itemKey),
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                  labelText: displayTitle,
                  isDense: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          8))), // Ajoutez question.unit ici si nécessaire
              onChanged: (newValue) {
                _currentEditValues[itemKey] = newValue.trim().isEmpty
                    ? null
                    : num.tryParse(newValue.trim());
              },
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
      final bool enteringEditMode = !_isEditingAll;
      _isEditingAll = !_isEditingAll;

      if (enteringEditMode) {
        _primeEditingStateWithData(
            Map<String, dynamic>.from(_originalPreferences));
      } else if (cancel) {
        _primeEditingStateWithData(
            Map<String, dynamic>.from(_originalPreferences));
      }
    });
  }

  Future<void> _saveAllPreferences() async {
    if (!mounted) return;
    setState(() => _isSavingAll = true);

    Map<String, dynamic> preferencesToSave = {};
    _currentEditValues.forEach((key, valueInCurrentEditValues) {
      final question = _getQuestionById(key);
      if (question != null &&
          question.id == 'physical_stats' &&
          question.type == QuestionType.numericInput) {
        Map<String, dynamic> statsMapToSave = {};
        for (var subKeyEntry in statSubKeyEntries) {
          // Utiliser statSubKeyEntries pour l'ordre et les clés
          final statKey = subKeyEntry.key;
          final controllerKey = '${key}_$statKey';
          final controller = _numericInputControllers[controllerKey];
          if (controller != null) {
            statsMapToSave[statKey] = controller.text.trim().isEmpty
                ? null
                : num.tryParse(controller.text.trim());
          } else {
            statsMapToSave[statKey] =
                (valueInCurrentEditValues as Map<String, dynamic>?)?[statKey];
          }
        }
        preferencesToSave[key] = statsMapToSave;
      } else if (question != null &&
          question.type == QuestionType.numericInput) {
        final controller = _numericInputControllers[key];
        if (controller != null) {
          preferencesToSave[key] = controller.text.trim().isEmpty
              ? null
              : num.tryParse(controller.text.trim());
        } else {
          preferencesToSave[key] = valueInCurrentEditValues;
        }
      } else {
        preferencesToSave[key] = valueInCurrentEditValues;
      }
    });

    try {
      await _firestore.collection('users').doc(widget.user.uid).set(
        {'onboardingData': preferencesToSave},
        SetOptions(merge: true),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Preferences updated successfully!"),
          backgroundColor: Colors.green));

      _originalPreferences = Map<String, dynamic>.from(preferencesToSave);
      _isEditingAll = false;
      _primeEditingStateWithData(
          Map<String, dynamic>.from(_originalPreferences));
    } catch (e) {
      if (!mounted) return;
      print("Error saving preferences: $e");
      _showErrorSnackBar("Failed to update preferences: ${e.toString()}");
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
          return doc as DocumentSnapshot<Map<String, dynamic>>;
        }
        return null;
      }).catchError((error) {
        print(
            "ProfileTab: Error fetching user document in FutureBuilder: $error");
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
          userDataFromFirestore = snapshot.data!.data()!;
          loadedOnboardingDataFromFirestore =
              (userDataFromFirestore['onboardingData']
                      as Map<String, dynamic>?) ??
                  {};
        } else if (snapshot.hasError) {
          print("ProfileTab: FutureBuilder has error: ${snapshot.error}");
          if (_originalPreferences.isNotEmpty && _dataLoadedFromFirestore) {
            loadedOnboardingDataFromFirestore = _originalPreferences;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted)
                _showErrorSnackBar(
                    "Could not refresh. Displaying last known data.");
            });
          } else {
            return Center(
                child: Text("Error loading profile: Please try again later.",
                    style: TextStyle(color: colorScheme.error)));
          }
        }

        if (!_isEditingAll) {
          if (!_dataLoadedFromFirestore ||
              !_areMapsEqual(
                  _originalPreferences, loadedOnboardingDataFromFirestore)) {
            _originalPreferences =
                Map<String, dynamic>.from(loadedOnboardingDataFromFirestore);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _primeEditingStateWithData(
                    Map<String, dynamic>.from(_originalPreferences));
              }
            });
            _dataLoadedFromFirestore = true;
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
            userEmail.split('@')[0] ??
            "User";

        List<MapEntry<String, dynamic>> preferencesToDisplay = [];
        final sourceMapForCurrentUI =
            _isEditingAll ? _currentEditValues : _originalPreferences;

        for (var question in defaultOnboardingQuestions) {
          dynamic currentValue = sourceMapForCurrentUI[question.id];
          if (_isEditingAll &&
              !sourceMapForCurrentUI.containsKey(question.id)) {
            if (question.type == QuestionType.multipleChoice)
              currentValue = <String>[];
            else if (question.id == 'physical_stats')
              currentValue = <String, dynamic>{
                'age': null,
                'weight_kg': null,
                'height_cm': null
              };
            else
              currentValue = null;
          }
          if (_isEditingAll ||
              (currentValue != null &&
                  (!(currentValue is List && currentValue.isEmpty)) &&
                  (!(currentValue is Map && currentValue.isEmpty)))) {
            preferencesToDisplay.add(MapEntry(question.id, currentValue));
          }
        }

        if (preferencesToDisplay.isEmpty &&
            !_isEditingAll &&
            !_isSavingAll &&
            loadedOnboardingDataFromFirestore.isEmpty) {
          return ListView(padding: const EdgeInsets.all(16.0), children: [
            _buildUserInfoSection(context, displayName, userEmail, memberSince),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Icon(Icons.playlist_add_check_circle_outlined,
                      size: 40, color: colorScheme.primary),
                  const SizedBox(height: 8),
                  Text("Set Your Preferences", style: textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                      "Complete your preferences to get personalized routines.",
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                      onPressed: () => _toggleEditAllMode(cancel: false),
                      child: const Text("Set Preferences Now"))
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildSignOutButton(context),
          ]);
        }

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            _buildUserInfoSection(context, displayName, userEmail, memberSince),
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
                      onPressed: () => _toggleEditAllMode(cancel: false),
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
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Saving preferences...")
                      ]))),
            if (!_isSavingAll)
              _isEditingAll
                  ? Column(
                      children: preferencesToDisplay.map((entry) {
                        final question = _getQuestionById(entry.key);
                        if (question == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: _buildPreferenceItem(
                              itemKey: entry.key,
                              currentValueForWidget:
                                  _currentEditValues[entry.key],
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
                                ? 4.2
                                : 5.2),
                      ),
                      itemBuilder: (context, index) {
                        final entry = preferencesToDisplay[index];
                        final question = _getQuestionById(entry.key);
                        if (question == null) return const SizedBox.shrink();
                        return Card(
                            elevation: 0.5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                    color:
                                        colorScheme.outline.withOpacity(0.3))),
                            child: _buildPreferenceItem(
                                itemKey: entry.key,
                                currentValueForWidget:
                                    _originalPreferences[entry.key],
                                question: question));
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
            const SizedBox(height: 30),
            _buildSignOutButton(context),
          ],
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
            radius: 50,
            backgroundColor: colorScheme.secondaryContainer,
            child: Icon(Icons.person_outline,
                size: 60, color: colorScheme.onSecondaryContainer)),
        const SizedBox(height: 12),
        Text(displayName,
            style:
                textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        Text(email,
            style: textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant)),
        if (memberSince != 'N/A')
          Text("Member since $memberSince",
              style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.8))),
      ]),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: TextButton.icon(
          icon: Icon(Icons.logout, color: colorScheme.error),
          label: Text("Sign Out",
              style: TextStyle(color: colorScheme.error, fontSize: 16)),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
          },
          style: TextButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
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
          if (sortedVal1[i] != sortedVal2[i]) return false;
        }
      } else if (val1 is Map && val2 is Map) {
        if (!_areMapsEqual(
            val1 as Map<String, dynamic>, val2 as Map<String, dynamic>))
          return false;
      } else if (val1?.toString() != val2?.toString()) {
        // Comparaison stringifiée pour les scalaires
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
        return Icons.accessibility_new_outlined;
      case 'experience':
        return Icons.stacked_line_chart_outlined;
      case 'frequency':
        return Icons.event_repeat_outlined;
      case 'workout_days':
        return Icons.date_range_outlined;
      case 'equipment':
        return Icons.fitness_center_outlined;
      case 'focus_areas':
        return Icons.my_location_outlined;
      default:
        return Icons.settings_suggest_outlined;
    }
  }
}

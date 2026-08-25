import 'package:flutter/material.dart';
import 'package:gymgenius/domain/entities/food_item.dart';
import 'package:gymgenius/domain/entities/logged_food_portion.dart';
import 'package:gymgenius/domain/enums/meal_type.dart';
import 'package:gymgenius/domain/value_objects/macro_targets.dart';
import 'package:gymgenius/engines/nutrition_engine/builders/meal_log_builder.dart';
import 'package:gymgenius/engines/nutrition_engine/food_knowledge_base/models/meal_template.dart';
import 'package:gymgenius/presentation/viewmodels/nutrition_viewmodel.dart';

/// Bottom sheet to log a meal — three tiers: pick a saved database
/// meal, compose from individual foods, or enter macros manually.
/// (A fourth tier, logging today's suggested meals as-is, lives
/// directly on NutritionScreen's "Suggested meals" list.)
Future<void> showLogMealSheet({
  required BuildContext context,
  required NutritionViewModel vm,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => _LogMealSheet(vm: vm),
  );
}

class _LogMealSheet extends StatefulWidget {
  final NutritionViewModel vm;

  const _LogMealSheet({required this.vm});

  @override
  State<_LogMealSheet> createState() => _LogMealSheetState();
}

class _LogMealSheetState extends State<_LogMealSheet> {
  int _tab = 0; // 0 = Database, 1 = Compose, 2 = Manual
  final _nameController = TextEditingController(text: 'Custom meal');
  MealType _mealType = MealType.lunch;
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final List<_PortionDraft> _portions = [];
  final _builder = const MealLogBuilder();

  // --- Database tab state ---
  final _searchController = TextEditingController();
  MealType? _typeFilter;
  MealTemplate? _selectedTemplate;
  MealType _selectedTemplateMealType = MealType.lunch;

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Log a meal',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('My meals')),
              ButtonSegment(value: 1, label: Text('Compose')),
              ButtonSegment(value: 2, label: Text('Manual')),
            ],
            selected: {_tab},
            onSelectionChanged: (s) => setState(() => _tab = s.first),
          ),
          const SizedBox(height: 16),
          if (_tab == 0)
            ..._databaseFields(theme)
          else if (_tab == 1)
            ..._composeFields(theme)
          else
            ..._manualFields(theme),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _save,
            child: const Text('Save log'),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // Tier 2: Database meal (My meals)
  // ------------------------------------------------------------------

  List<Widget> _databaseFields(ThemeData theme) {
    if (_selectedTemplate != null) {
      return [_selectedTemplateCard(theme)];
    }

    final query = _searchController.text.trim().toLowerCase();
    final templates = widget.vm.availableMealTemplates.where((t) {
      final matchesQuery =
          query.isEmpty || t.name.toLowerCase().contains(query);
      final matchesType =
          _typeFilter == null || t.tags.contains(_typeFilter!.value);
      return matchesQuery && matchesType;
    }).toList();

    return [
      TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Search meals...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: 36,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _typeChip(null, 'All'),
            ...MealType.values.map((t) => _typeChip(t, t.displayName)),
          ],
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: 280,
        child: templates.isEmpty
            ? const Center(child: Text('No meals found'))
            : ListView.builder(
                itemCount: templates.length,
                itemBuilder: (context, i) => _templateTile(templates[i]),
              ),
      ),
    ];
  }

  Widget _typeChip(MealType? type, String label) {
    final selected = _typeFilter == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _typeFilter = type),
      ),
    );
  }

  Widget _templateTile(MealTemplate template) {
    final macros = template.baseMacros;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(template.name),
        subtitle: Text(
          '${macros.calories} kcal · '
          'P${macros.proteinG} C${macros.carbsG} F${macros.fatG}',
        ),
        onTap: () => setState(() => _selectedTemplate = template),
      ),
    );
  }

  Widget _selectedTemplateCard(ThemeData theme) {
    final template = _selectedTemplate!;
    final macros = template.baseMacros;
    return Card(
      color: theme.colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    template.name,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _selectedTemplate = null),
                ),
              ],
            ),
            Text(
              '${macros.calories} kcal · '
              'P${macros.proteinG} C${macros.carbsG} F${macros.fatG}',
            ),
            const SizedBox(height: 4),
            Text(
              template.ingredientNames.join(' · '),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<MealType>(
              initialValue: _selectedTemplateMealType,
              decoration: const InputDecoration(
                labelText: 'Log as',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: MealType.values
                  .map(
                    (t) =>
                        DropdownMenuItem(value: t, child: Text(t.displayName)),
                  )
                  .toList(),
              onChanged: (v) => setState(
                () => _selectedTemplateMealType = v ?? MealType.lunch,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // Tier 3: Compose
  // ------------------------------------------------------------------

  List<Widget> _composeFields(ThemeData theme) {
    final preview = _portions.isEmpty
        ? null
        : _builder.computeMacrosFromPortions(
            _portions
                .where((p) => p.food != null && p.grams > 0)
                .map(
                  (p) => LoggedFoodPortion(
                    foodId: p.food!.id,
                    foodName: p.food!.name,
                    grams: p.grams,
                  ),
                )
                .toList(),
            widget.vm.availableFoods,
          );

    return [
      TextField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: 'Meal name',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<MealType>(
        initialValue: _mealType,
        decoration: const InputDecoration(
          labelText: 'Meal type',
          border: OutlineInputBorder(),
        ),
        items: MealType.values
            .map(
              (t) => DropdownMenuItem(
                value: t,
                child: Text(t.displayName),
              ),
            )
            .toList(),
        onChanged: (v) => setState(() => _mealType = v ?? MealType.lunch),
      ),
      const SizedBox(height: 12),
      ..._portions.map((draft) => _portionRow(draft)),
      TextButton.icon(
        onPressed: _addPortion,
        icon: const Icon(Icons.add),
        label: const Text('Add food'),
      ),
      if (preview != null)
        Text(
          'Preview: ${preview.calories} kcal · '
          'P${preview.proteinG} C${preview.carbsG} F${preview.fatG}',
          style: theme.textTheme.bodyMedium,
        ),
    ];
  }

  // ------------------------------------------------------------------
  // Tier 4: Manual
  // ------------------------------------------------------------------

  List<Widget> _manualFields(ThemeData theme) {
    return [
      TextField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: 'Meal name',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<MealType>(
        initialValue: _mealType,
        decoration: const InputDecoration(
          labelText: 'Meal type',
          border: OutlineInputBorder(),
        ),
        items: MealType.values
            .map(
              (t) => DropdownMenuItem(
                value: t,
                child: Text(t.displayName),
              ),
            )
            .toList(),
        onChanged: (v) => setState(() => _mealType = v ?? MealType.lunch),
      ),
      const SizedBox(height: 12),
      _macroField(_caloriesController, 'Calories (kcal)'),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(child: _macroField(_proteinController, 'Protein (g)')),
          const SizedBox(width: 8),
          Expanded(child: _macroField(_carbsController, 'Carbs (g)')),
          const SizedBox(width: 8),
          Expanded(child: _macroField(_fatController, 'Fat (g)')),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        'Approximate values are fine — logging beats skipping.',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    ];
  }

  Widget _macroField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _portionRow(_PortionDraft draft) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<FoodItem>(
              initialValue: draft.food,
              decoration: const InputDecoration(
                labelText: 'Food',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: widget.vm.availableFoods
                  .map(
                    (f) => DropdownMenuItem(
                      value: f,
                      child: Text(f.name, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (f) => setState(() => draft.food = f),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: draft.gramsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'g',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _portions.remove(draft)),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  void _addPortion() {
    setState(() {
      _portions.add(
        _PortionDraft(
          food: widget.vm.availableFoods.isNotEmpty
              ? widget.vm.availableFoods.first
              : null,
        ),
      );
    });
  }

  Future<void> _save() async {
    if (_tab == 0) {
      final template = _selectedTemplate;
      if (template == null) return;
      await widget.vm.logDatabaseMeal(
        template: template,
        mealType: _selectedTemplateMealType,
      );
    } else if (_tab == 1) {
      final portions = _portions
          .where((p) => p.food != null && p.grams > 0)
          .map(
            (p) => LoggedFoodPortion(
              foodId: p.food!.id,
              foodName: p.food!.name,
              grams: p.grams,
            ),
          )
          .toList();
      if (portions.isEmpty) return;
      await widget.vm.logComposedMeal(
        name: _nameController.text,
        mealType: _mealType,
        portions: portions,
      );
    } else {
      final calories = int.tryParse(_caloriesController.text.trim()) ?? 0;
      if (calories <= 0) return;
      await widget.vm.logManualMeal(
        name: _nameController.text,
        mealType: _mealType,
        macros: MacroTargets(
          calories: calories,
          proteinG: int.tryParse(_proteinController.text.trim()) ?? 0,
          carbsG: int.tryParse(_carbsController.text.trim()) ?? 0,
          fatG: int.tryParse(_fatController.text.trim()) ?? 0,
        ),
      );
    }
    if (mounted) Navigator.of(context).pop();
  }
}

class _PortionDraft {
  FoodItem? food;
  final TextEditingController gramsController = TextEditingController();

  _PortionDraft({this.food});

  double get grams => double.tryParse(gramsController.text.trim()) ?? 0;
}

import 'package:flutter/material.dart';
import 'package:gymgenius/di/injection.dart';
import 'package:gymgenius/domain/entities/meal.dart';
import 'package:gymgenius/domain/entities/nutrition_log.dart';
import 'package:gymgenius/domain/entities/nutrition_plan.dart';
import 'package:gymgenius/domain/enums/meal_type.dart';
import 'package:gymgenius/domain/enums/nutrition_log_source.dart';
import 'package:gymgenius/domain/enums/nutrition_status.dart';
import 'package:gymgenius/presentation/viewmodels/nutrition_viewmodel.dart';
import 'package:gymgenius/presentation/widgets/nutrition/log_meal_sheet.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Nutrition detail screen with four-tier meal logging.
class NutritionScreen extends StatelessWidget {
  final NutritionPlan plan;

  const NutritionScreen({
    super.key,
    required this.plan,
  });

  static Route<void> route(NutritionPlan plan) {
    return MaterialPageRoute<void>(
      builder: (_) => NutritionScreen(plan: plan),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final vm = NutritionViewModel(
          plan: plan,
          userRepository: getIt(),
          healthRepository: getIt(),
          nutritionRepository: getIt(),
          nutritionEngine: getIt(),
        );
        Future.microtask(vm.load);
        return vm;
      },
      child: const _NutritionView(),
    );
  }
}

class _NutritionView extends StatelessWidget {
  const _NutritionView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NutritionViewModel>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final dateLabel = DateFormat.yMMMEd().format(vm.plan.date);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition'),
      ),
      floatingActionButton: vm.state == NutritionUiState.ready
          ? FloatingActionButton.extended(
              onPressed: () => showLogMealSheet(context: context, vm: vm),
              icon: const Icon(Icons.add),
              label: const Text('Log meal'),
            )
          : null,
      body: switch (vm.state) {
        NutritionUiState.loading ||
        NutritionUiState.initial =>
          const Center(child: CircularProgressIndicator()),
        NutritionUiState.error => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(vm.errorMessage ?? 'Unable to load nutrition'),
            ),
          ),
        NutritionUiState.ready => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                dateLabel,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                vm.plan.isTrainingDay ? 'Training day plan' : 'Rest day plan',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${vm.plan.country} · ${vm.plan.status.displayName}',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              _LoggedProgressCard(vm: vm),
              const SizedBox(height: 24),
              if (vm.logs.isNotEmpty) ...[
                Text(
                  'Logged today',
                  style: textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ...vm.logs.map((log) => _LoggedMealTile(log: log, vm: vm)),
                const SizedBox(height: 24),
              ],
              Text(
                'Suggested meals',
                style:
                    textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ...vm.plan.meals.map(
                (meal) => _SuggestedMealTile(meal: meal, vm: vm),
              ),
              if (vm.plan.reasons.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Why these targets',
                  style: textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ...vm.plan.reasons.map(
                  (reason) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            reason,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Hydration: ${((vm.plan.targets.waterMl ?? 0) / 1000).toStringAsFixed(1)} L',
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 80),
            ],
          ),
      },
    );
  }
}

class _LoggedProgressCard extends StatelessWidget {
  final NutritionViewModel vm;

  const _LoggedProgressCard({required this.vm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final targets = vm.plan.targets;
    final logged = vm.loggedTotals;
    final progress = targets.calories > 0
        ? (logged.calories / targets.calories).clamp(0.0, 1.2)
        : 0.0;

    return Card(
      color: colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Logged ${logged.calories} / ${targets.calories} kcal',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress > 1 ? 1 : progress,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _MacroChip(
                  label: 'Protein',
                  logged: logged.proteinG,
                  target: targets.proteinG,
                ),
                const SizedBox(width: 8),
                _MacroChip(
                  label: 'Carbs',
                  logged: logged.carbsG,
                  target: targets.carbsG,
                ),
                const SizedBox(width: 8),
                _MacroChip(
                  label: 'Fat',
                  logged: logged.fatG,
                  target: targets.fatG,
                ),
              ],
            ),
            if (vm.logs.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Adherence: ${(vm.adherenceScore * 100).round()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final int logged;
  final int target;

  const _MacroChip({
    required this.label,
    required this.logged,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              '$logged / ${target}g',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _LoggedMealTile extends StatelessWidget {
  final NutritionLog log;
  final NutritionViewModel vm;

  const _LoggedMealTile({required this.log, required this.vm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final time = DateFormat.Hm().format(log.loggedAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading:
            Icon(_sourceIcon(log.source), color: theme.colorScheme.primary),
        title: Text(log.name),
        subtitle: Text(
          '${log.mealType.displayName} · $time · '
          '${log.macros.calories} kcal · ${log.source.displayName}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => vm.deleteLog(log.id),
        ),
      ),
    );
  }

  IconData _sourceIcon(NutritionLogSource source) {
    switch (source) {
      case NutritionLogSource.template:
        return Icons.check_circle_outline;
      case NutritionLogSource.database:
        return Icons.restaurant_menu;
      case NutritionLogSource.composed:
        return Icons.tune;
      case NutritionLogSource.manual:
        return Icons.edit_note;
    }
  }
}

class _SuggestedMealTile extends StatelessWidget {
  final Meal meal;
  final NutritionViewModel vm;

  const _SuggestedMealTile({required this.meal, required this.vm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final logged = vm.isMealLogged(meal);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        leading: Icon(_iconFor(meal.type), color: colorScheme.primary),
        title: Text(
          meal.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${meal.type.displayName} · ${meal.macros.calories} kcal · '
          'P${meal.macros.proteinG} C${meal.macros.carbsG} F${meal.macros.fatG}',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (meal.timingNote != null)
                  Text(
                    meal.timingNote!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: 8),
                Text('Ingredients', style: theme.textTheme.labelLarge),
                const SizedBox(height: 4),
                Text(meal.ingredients.join(' · ')),
                if (meal.reason != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    meal.reason!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: logged ? null : () => vm.logSuggestedMeal(meal),
                  icon: Icon(logged ? Icons.check : Icons.restaurant),
                  label: Text(logged ? 'Logged' : 'Log as eaten'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.wb_sunny_outlined;
      case MealType.lunch:
        return Icons.lunch_dining_outlined;
      case MealType.dinner:
        return Icons.dinner_dining_outlined;
      case MealType.snack:
        return Icons.apple;
      case MealType.preWorkout:
        return Icons.bolt_outlined;
      case MealType.postWorkout:
        return Icons.sports_gymnastics;
    }
  }
}

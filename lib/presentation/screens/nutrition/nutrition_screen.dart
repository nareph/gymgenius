import 'package:flutter/material.dart';
import 'package:gymgenius/domain/entities/meal.dart';
import 'package:gymgenius/domain/entities/nutrition_plan.dart';
import 'package:gymgenius/domain/enums/meal_type.dart';
import 'package:gymgenius/domain/enums/nutrition_status.dart';
import 'package:intl/intl.dart';

/// Read-only nutrition detail screen. Consumes [NutritionPlan] from DailyPlan.
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final targets = plan.targets;
    final dateLabel = DateFormat.yMMMEd().format(plan.date);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition'),
      ),
      body: ListView(
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
            plan.isTrainingDay ? 'Training day plan' : 'Rest day plan',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${plan.country} · ${plan.status.displayName}',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          _TargetsCard(plan: plan),
          const SizedBox(height: 24),
          Text(
            'Meals',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...plan.meals.map((meal) => _MealTile(meal: meal)),
          if (plan.reasons.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Why these targets',
              style:
                  textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...plan.reasons.map(
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
            'Hydration: ${((targets.waterMl ?? 0) / 1000).toStringAsFixed(1)} L',
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _TargetsCard extends StatelessWidget {
  final NutritionPlan plan;

  const _TargetsCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = plan.targets;

    return Card(
      color: colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${t.calories} kcal',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Maintenance ≈ ${plan.maintenanceCalories.round()} kcal',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _MacroChip(label: 'Protein', value: '${t.proteinG}g'),
                const SizedBox(width: 8),
                _MacroChip(label: 'Carbs', value: '${t.carbsG}g'),
                const SizedBox(width: 8),
                _MacroChip(label: 'Fat', value: '${t.fatG}g'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;

  const _MacroChip({required this.label, required this.value});

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
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _MealTile extends StatelessWidget {
  final Meal meal;

  const _MealTile({required this.meal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Text(
                  'Ingredients',
                  style: theme.textTheme.labelLarge,
                ),
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

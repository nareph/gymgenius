import 'package:flutter/material.dart';
import 'package:gymgenius/domain/entities/nutrition_plan.dart';
import 'package:gymgenius/domain/enums/nutrition_status.dart';
import 'package:gymgenius/presentation/screens/nutrition/nutrition_screen.dart';

/// Compact Home summary of today's nutrition targets.
class NutritionSummaryCard extends StatelessWidget {
  final NutritionPlan plan;

  const NutritionSummaryCard({
    super.key,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final targets = plan.targets;

    return Card(
      color: colorScheme.secondaryContainer.withValues(alpha: 0.55),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            NutritionScreen.route(plan),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                Icons.restaurant_menu_rounded,
                color: colorScheme.onSecondaryContainer,
                size: 30,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Nutrition',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${targets.calories} kcal  •  '
                      'P ${targets.proteinG}g  '
                      'C ${targets.carbsG}g  '
                      'F ${targets.fatG}g',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSecondaryContainer
                            .withValues(alpha: 0.85),
                      ),
                    ),
                    Text(
                      '${plan.mealCount} meals · ${plan.status.displayName}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSecondaryContainer
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSecondaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

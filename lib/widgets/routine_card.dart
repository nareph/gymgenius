// lib/widgets/routine_card.dart
import 'package:flutter/material.dart';
import 'package:gymgenius/models/routine.dart'; // For RoutineExercise and WeeklyRoutine
import 'package:gymgenius/screens/daily_workout_detail_screen.dart'; // To navigate to

class RoutineCard extends StatelessWidget {
  final String dayKey;
  final List<RoutineExercise> exercises;
  final bool isToday;
  final WeeklyRoutine parentRoutine;

  const RoutineCard({
    super.key,
    required this.dayKey,
    required this.exercises,
    required this.parentRoutine,
    this.isToday = false,
  });

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  void _navigateToDetail(BuildContext context) {
    // Seulement naviguer si ce n'est pas un jour de repos
    if (exercises.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DailyWorkoutDetailScreen(
            dayTitle: "${_capitalize(dayKey)} Workout Details",
            exercises: exercises,
            routineIdForLog: parentRoutine.id,
            dayKeyForLog: dayKey.toLowerCase(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isRestDay = exercises.isEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: isRestDay
          ? 1.0
          : (isToday ? 4.0 : 1.5), // Moins d'élévation pour les jours de repos
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: isToday &&
                !isRestDay // Bordure primaire seulement si c'est aujourd'hui ET un jour d'entraînement
            ? BorderSide(color: theme.colorScheme.primary, width: 1.5)
            : (isRestDay
                ? BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                    width: 0.5)
                : BorderSide.none), // Bordure subtile pour les jours de repos
      ),
      color: isRestDay
          ? theme.colorScheme.surfaceContainerLowest
          : null, // Couleur de fond différente pour les jours de repos
      child: InkWell(
        // Désactiver l'effet d'encre et le onTap pour les jours de repos si souhaité,
        // ou le garder pour une interaction future (mais _navigateToDetail le gère déjà)
        onTap: isRestDay ? null : () => _navigateToDetail(context),
        splashColor: isRestDay ? Colors.transparent : null,
        highlightColor: isRestDay ? Colors.transparent : null,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      _capitalize(dayKey),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isToday && !isRestDay
                            ? theme.colorScheme.primary
                            : (isRestDay
                                ? theme.colorScheme.onSurfaceVariant
                                : null),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Affiche une icône flèche SEULEMENT si ce n'est PAS un jour de repos
                  if (!isRestDay)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: isToday
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.7),
                    )
                  else // Optionnel: vous pouvez ajouter un petit indicateur pour le repos ici, ou rien du tout.
                    // Le texte "Rest Day" sera affiché plus bas.
                    // Pour garder le layout similaire, on peut mettre un SizedBox vide de la même taille
                    // que l'icône, ou simplement laisser la Row gérer l'espace.
                    // Ou un petit chip discret:
                    Chip(
                      label: Text(
                        "REST",
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.bold),
                      ),
                      backgroundColor:
                          theme.colorScheme.secondaryContainer.withOpacity(0.7),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (!isRestDay) ...[
                // Affiche les exercices seulement si ce n'est PAS un jour de repos
                ...exercises.take(3).map((ex) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        "• ${ex.name} (${ex.sets}x${ex.reps})",
                        style: theme.textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )),
                if (exercises.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      "...and ${exercises.length - 3} more.",
                      style: theme.textTheme.bodySmall
                          ?.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ),
              ] else // Affiche un message pour le jour de repos
                Text(
                  "Take this day to recover and recharge!",
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

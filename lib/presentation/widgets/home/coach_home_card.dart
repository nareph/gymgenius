import 'package:flutter/material.dart';
import 'package:gymgenius/engines/ai_coach/models/coach_response.dart';
import 'package:gymgenius/engines/decision_engine/models/daily_plan.dart';
import 'package:gymgenius/presentation/screens/coach/coach_screen.dart';

/// Home card showing today's AI Coach message.
class CoachHomeCard extends StatelessWidget {
  final CoachResponse? response;
  final bool isLoading;
  final VoidCallback? onRetry;
  final DailyPlan? dailyPlan;

  const CoachHomeCard({
    super.key,
    required this.response,
    this.isLoading = false,
    this.onRetry,
    this.dailyPlan,
  });

  void _open(BuildContext context) {
    Navigator.of(context).push(CoachScreen.route(dailyPlan: dailyPlan));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 14),
              Text('Preparing today\'s coaching...'),
            ],
          ),
        ),
      );
    }

    if (response == null) {
      return Card(
        child: ListTile(
          leading: Icon(Icons.smart_toy_outlined, color: colorScheme.primary),
          title: const Text('AI Coach'),
          subtitle: const Text('Coaching unavailable — tap to open'),
          trailing: onRetry != null
              ? IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: onRetry,
                )
              : const Icon(Icons.chevron_right_rounded),
          onTap: () => _open(context),
        ),
      );
    }

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _open(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.smart_toy_outlined,
                  color: colorScheme.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Coach',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      response!.message,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (response!.usedFallback)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Local coaching',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.outline,
                                  ),
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

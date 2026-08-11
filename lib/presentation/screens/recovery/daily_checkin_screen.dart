import 'package:flutter/material.dart';
import 'package:gymgenius/domain/entities/daily_checkin.dart';
import 'package:gymgenius/domain/enums/energy_level.dart';
import 'package:gymgenius/domain/enums/soreness_level.dart';

/// Guided daily check-in screen.
///
/// Triggered automatically on app launch if no check-in exists for today.
/// Returns a [DailyCheckIn] when the user submits.
class DailyCheckInScreen extends StatefulWidget {
  final String userId;

  const DailyCheckInScreen({super.key, required this.userId});

  static Route<DailyCheckIn?> route(String userId) {
    return MaterialPageRoute(
      builder: (_) => DailyCheckInScreen(userId: userId),
      fullscreenDialog: true,
    );
  }

  @override
  State<DailyCheckInScreen> createState() => _DailyCheckInScreenState();
}

class _DailyCheckInScreenState extends State<DailyCheckInScreen> {
  double _sleepHours = 7.0;
  SorenessLevel _soreness = SorenessLevel.none;
  EnergyLevel _energy = EnergyLevel.moderate;
  int _mood = 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Morning Check-in'),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            'Good morning! How are you feeling today?',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),

          // ── Sleep ──────────────────────────────────────────────────
          _SectionTitle(icon: Icons.bedtime_rounded, label: 'Sleep'),
          const SizedBox(height: 4),
          Text(
            '${_sleepHours.toStringAsFixed(1)} hours',
            style: tt.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.primary,
            ),
          ),
          Slider(
            min: 0,
            max: 12,
            divisions: 24,
            value: _sleepHours,
            label: '${_sleepHours.toStringAsFixed(1)} h',
            onChanged: (v) => setState(() => _sleepHours = v),
          ),
          const SizedBox(height: 20),

          // ── Soreness ───────────────────────────────────────────────
          _SectionTitle(icon: Icons.fitness_center_rounded, label: 'Muscle Soreness'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: SorenessLevel.values.map((level) {
              final selected = _soreness == level;
              return ChoiceChip(
                label: Text(level.displayName),
                selected: selected,
                selectedColor: cs.primaryContainer,
                onSelected: (_) => setState(() => _soreness = level),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // ── Energy ─────────────────────────────────────────────────
          _SectionTitle(icon: Icons.bolt_rounded, label: 'Energy Level'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: EnergyLevel.values.map((level) {
              final selected = _energy == level;
              return ChoiceChip(
                label: Text(level.displayName),
                selected: selected,
                selectedColor: cs.primaryContainer,
                onSelected: (_) => setState(() => _energy = level),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // ── Mood ───────────────────────────────────────────────────
          _SectionTitle(icon: Icons.sentiment_satisfied_rounded, label: 'Mood'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (i) {
              final value = i + 1;
              final selected = _mood == value;
              return GestureDetector(
                onTap: () => setState(() => _mood = value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: selected
                        ? cs.primaryContainer
                        : cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: selected
                        ? Border.all(color: cs.primary, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      _moodEmoji(value),
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 36),

          // ── Submit ─────────────────────────────────────────────────
          FilledButton.icon(
            icon: const Icon(Icons.check_rounded),
            label: const Text('Done — Show My Plan'),
            onPressed: _submitting ? null : _submit,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text(
              'Skip for now',
              style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5)),
            ),
          ),
        ],
      ),
    );
  }

  bool _submitting = false;

  void _submit() {
    if (_submitting) return;
    setState(() => _submitting = true);

    final checkIn = DailyCheckIn(
      userId: widget.userId,
      date: DateTime.now(),
      sleepHours: _sleepHours,
      sorenessLevel: _soreness,
      energyLevel: _energy,
      mood: _mood,
    );
    Navigator.of(context).pop(checkIn);
  }

  String _moodEmoji(int value) {
    switch (value) {
      case 1:
        return '😞';
      case 2:
        return '😕';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      default:
        return '😄';
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionTitle({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: cs.primary),
        const SizedBox(width: 8),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

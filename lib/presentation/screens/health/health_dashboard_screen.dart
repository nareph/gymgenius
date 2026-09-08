import 'package:flutter/material.dart';
import 'package:gymgenius/di/injection.dart';
import 'package:gymgenius/domain/entities/habit.dart';
import 'package:gymgenius/domain/enums/blood_pressure_category.dart';
import 'package:gymgenius/domain/enums/energy_level.dart';
import 'package:gymgenius/domain/enums/glucose_category.dart';
import 'package:gymgenius/domain/enums/glucose_context.dart';
import 'package:gymgenius/domain/enums/habit_frequency.dart';
import 'package:gymgenius/domain/enums/stress_level.dart';
import 'package:gymgenius/presentation/viewmodels/health_platform_viewmodel.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HealthDashboardScreen extends StatelessWidget {
  const HealthDashboardScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute(builder: (_) => const HealthDashboardScreen());
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final vm = getIt<HealthPlatformViewModel>();
        Future.microtask(vm.load);
        return vm;
      },
      child: const _HealthDashboardView(),
    );
  }
}

class _HealthDashboardView extends StatelessWidget {
  const _HealthDashboardView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HealthPlatformViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Health Platform')),
      body: switch (vm.state) {
        HealthPlatformUiState.loading ||
        HealthPlatformUiState.initial =>
          const Center(child: CircularProgressIndicator()),
        HealthPlatformUiState.error => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(vm.errorMessage ?? 'Something went wrong'),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: vm.load, child: const Text('Retry')),
                ],
              ),
            ),
          ),
        HealthPlatformUiState.ready => RefreshIndicator(
            onRefresh: vm.load,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Informational tracking only — not a medical diagnosis.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                _HydrationCard(vm: vm),
                _BloodPressureCard(vm: vm),
                _BloodGlucoseCard(vm: vm),
                _WellnessCard(vm: vm),
                _HabitsCard(vm: vm),
                if (vm.snapshot?.lifestyle != null) ...[
                  const SizedBox(height: 8),
                  Text('Lifestyle tips',
                      style: Theme.of(context).textTheme.titleMedium),
                  ...vm.snapshot!.lifestyle!.recommendations.take(4).map(
                        (r) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.tips_and_updates_outlined),
                          title: Text(r),
                        ),
                      ),
                ],
              ],
            ),
          ),
      },
    );
  }
}

class _HydrationCard extends StatelessWidget {
  final HealthPlatformViewModel vm;
  const _HydrationCard({required this.vm});

  @override
  Widget build(BuildContext context) {
    final s = vm.snapshot;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hydration', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '${s?.hydrationTotalMl ?? 0} / ${s?.hydrationTargetMl ?? 2000} ml '
              '(${s?.hydrationPercent ?? 0}%)',
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: ((s?.hydrationPercent ?? 0) / 100).clamp(0.0, 1.0),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final ml in [200, 250, 500])
                  ActionChip(
                    label: Text('+$ml ml'),
                    onPressed: () => vm.addHydration(ml),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BloodPressureCard extends StatelessWidget {
  final HealthPlatformViewModel vm;
  const _BloodPressureCard({required this.vm});

  @override
  Widget build(BuildContext context) {
    final latest = vm.snapshot?.latestBloodPressure;
    final category = vm.snapshot?.bloodPressureCategory;
    return Card(
      child: ListTile(
        title: const Text('Blood pressure'),
        subtitle: Text(
          latest == null
              ? 'No readings yet'
              : '${latest.systolic}/${latest.diastolic} mmHg'
                  '${category != null ? ' · ${category.displayName}' : ''}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _showBpDialog(context),
        ),
      ),
    );
  }

  Future<void> _showBpDialog(BuildContext context) async {
    final sys = TextEditingController(text: '120');
    final dia = TextEditingController(text: '80');
    final hr = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log blood pressure'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: sys,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Systolic'),
            ),
            TextField(
              controller: dia,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Diastolic'),
            ),
            TextField(
              controller: hr,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Heart rate (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await vm.addBloodPressure(
        systolic: int.tryParse(sys.text) ?? 120,
        diastolic: int.tryParse(dia.text) ?? 80,
        heartRateBpm: int.tryParse(hr.text),
      );
    }
  }
}

class _BloodGlucoseCard extends StatelessWidget {
  final HealthPlatformViewModel vm;
  const _BloodGlucoseCard({required this.vm});

  @override
  Widget build(BuildContext context) {
    final latest = vm.snapshot?.latestBloodGlucose;
    final category = vm.snapshot?.glucoseCategory;
    return Card(
      child: ListTile(
        title: const Text('Blood glucose'),
        subtitle: Text(
          latest == null
              ? 'No readings yet'
              : '${latest.valueMmolL.toStringAsFixed(1)} mmol/L'
                  ' (${latest.valueMgDl.toStringAsFixed(0)} mg/dL)'
                  '${category != null ? ' · ${category.displayName}' : ''}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _showGlucoseDialog(context),
        ),
      ),
    );
  }

  Future<void> _showGlucoseDialog(BuildContext context) async {
    final value = TextEditingController(text: '5.5');
    var ctxType = GlucoseContext.fasting;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setState) => AlertDialog(
          title: const Text('Log blood glucose'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: value,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'mmol/L'),
              ),
              DropdownButtonFormField<GlucoseContext>(
                initialValue: ctxType,
                items: GlucoseContext.values
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.displayName),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => ctxType = v);
                },
                decoration: const InputDecoration(labelText: 'Context'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogCtx, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (ok == true && context.mounted) {
      await vm.addBloodGlucose(
        valueMmolL: double.tryParse(value.text) ?? 5.5,
        context: ctxType,
      );
    }
  }
}

class _WellnessCard extends StatelessWidget {
  final HealthPlatformViewModel vm;
  const _WellnessCard({required this.vm});

  @override
  Widget build(BuildContext context) {
    final today = vm.snapshot?.todayWellness;
    return Card(
      child: ListTile(
        title: const Text('Mental wellness'),
        subtitle: Text(
          today == null
              ? 'No check-in today'
              : 'Mood ${today.mood}/5 · Stress ${today.stress.displayName}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _showWellnessDialog(context),
        ),
      ),
    );
  }

  Future<void> _showWellnessDialog(BuildContext context) async {
    var mood = 3;
    var stress = StressLevel.moderate;
    var energy = EnergyLevel.moderate;
    final notes = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setState) => AlertDialog(
          title: const Text('Wellness check-in'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Mood: $mood'),
                Slider(
                  value: mood.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: '$mood',
                  onChanged: (v) => setState(() => mood = v.round()),
                ),
                DropdownButtonFormField<StressLevel>(
                  initialValue: stress,
                  items: StressLevel.values
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.displayName),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => stress = v);
                  },
                  decoration: const InputDecoration(labelText: 'Stress'),
                ),
                DropdownButtonFormField<EnergyLevel>(
                  initialValue: energy,
                  items: EnergyLevel.values
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.displayName),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => energy = v);
                  },
                  decoration: const InputDecoration(labelText: 'Energy'),
                ),
                TextField(
                  controller: notes,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogCtx, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (ok == true && context.mounted) {
      await vm.saveWellness(
        mood: mood,
        stress: stress,
        energy: energy,
        notes: notes.text.trim().isEmpty ? null : notes.text.trim(),
      );
    }
  }
}

class _HabitsCard extends StatelessWidget {
  final HealthPlatformViewModel vm;
  const _HabitsCard({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Habits (${vm.snapshot?.habitsCompletedToday ?? 0}/'
                    '${vm.snapshot?.activeHabitsCount ?? 0})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showCreateHabit(context),
                ),
              ],
            ),
            if (vm.habits.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text('No habits yet'),
              )
            else
              ...vm.habits.map(
                (h) => ListTile(
                  dense: true,
                  title: Text(h.name),
                  subtitle: Text(
                    h.tracksValue
                        ? '${h.frequency.displayName} · tracked in ${h.unit}'
                        : h.frequency.displayName,
                  ),
                  trailing: Wrap(
                    children: [
                      IconButton(
                        tooltip: 'Complete',
                        icon: const Icon(Icons.check_circle_outline),
                        onPressed: h.isActive
                            ? () => _showCompleteHabitDialog(context, h)
                            : null,
                      ),
                      IconButton(
                        tooltip: h.isActive ? 'Deactivate' : 'Activate',
                        icon: Icon(
                          h.isActive
                              ? Icons.toggle_on
                              : Icons.toggle_off_outlined,
                        ),
                        onPressed: () => vm.toggleHabitActive(h),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => vm.deleteHabit(h.id),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Lets the user confirm (or backdate) the completion date, and enter
  /// a quantity when [habit] tracks one (e.g. km for a running habit).
  /// Replaces the previous single-tap "always today, no value" action.
  Future<void> _showCompleteHabitDialog(
    BuildContext context,
    Habit habit,
  ) async {
    var selectedDate = DateTime.now();
    final valueController = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setState) => AlertDialog(
          title: Text('Complete "${habit.name}"'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Date: ${DateFormat.yMMMd().format(selectedDate)}',
                ),
                trailing: const Icon(Icons.edit_calendar_outlined),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: dialogCtx,
                    initialDate: selectedDate,
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
              ),
              if (habit.tracksValue) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: valueController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Value (${habit.unit})',
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogCtx, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (ok == true && context.mounted) {
      await vm.completeHabit(
        habit,
        date: selectedDate,
        value: habit.tracksValue
            ? double.tryParse(valueController.text.trim())
            : null,
      );
    }
  }

  Future<void> _showCreateHabit(BuildContext context) async {
    final name = TextEditingController();
    final unit = TextEditingController();
    var frequency = HabitFrequency.daily;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setState) => AlertDialog(
          title: const Text('New habit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              DropdownButtonFormField<HabitFrequency>(
                initialValue: frequency,
                items: HabitFrequency.values
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.displayName),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => frequency = v);
                },
              ),
              TextField(
                controller: unit,
                decoration: const InputDecoration(
                  labelText: 'Unit (optional, e.g. km, min, reps)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogCtx, true),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
    if (ok == true && context.mounted && name.text.trim().isNotEmpty) {
      await vm.createHabit(
        name.text,
        frequency,
        unit: unit.text.trim().isEmpty ? null : unit.text.trim(),
      );
    }
  }
}

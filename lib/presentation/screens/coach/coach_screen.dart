import 'package:flutter/material.dart';
import 'package:gymgenius/di/injection.dart';
import 'package:gymgenius/engines/ai_coach/models/conversation.dart';
import 'package:gymgenius/engines/decision_engine/models/daily_plan.dart';
import 'package:gymgenius/presentation/viewmodels/coach_viewmodel.dart';
import 'package:provider/provider.dart';

class CoachScreen extends StatelessWidget {
  final DailyPlan? dailyPlan;

  const CoachScreen({super.key, this.dailyPlan});

  static Route<void> route({DailyPlan? dailyPlan}) {
    return MaterialPageRoute(
      builder: (_) => CoachScreen(dailyPlan: dailyPlan),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final vm = getIt<CoachViewModel>();
        Future.microtask(() => vm.bootstrap(dailyPlan));
        return vm;
      },
      child: const _CoachView(),
    );
  }
}

class _CoachView extends StatefulWidget {
  const _CoachView();

  @override
  State<_CoachView> createState() => _CoachViewState();
}

class _CoachViewState extends State<_CoachView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CoachViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Coach'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Daily'),
            Tab(text: 'Chat'),
            Tab(text: 'Weekly'),
          ],
        ),
        actions: [
          if (vm.isOfflineMode)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Center(child: Text('Offline')),
            ),
        ],
      ),
      body: switch (vm.state) {
        CoachUiState.loading || CoachUiState.initial => const Center(
            child: CircularProgressIndicator(),
          ),
        CoachUiState.error => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(vm.errorMessage ?? 'Something went wrong'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      final plan =
                          context.findAncestorWidgetOfExactType<CoachScreen>()
                              ?.dailyPlan;
                      vm.bootstrap(plan);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        CoachUiState.ready => TabBarView(
            controller: _tabs,
            children: [
              _DailyTab(vm: vm),
              _ChatTab(vm: vm, controller: _chatController),
              _WeeklyTab(vm: vm),
            ],
          ),
      },
    );
  }
}

class _DailyTab extends StatelessWidget {
  final CoachViewModel vm;

  const _DailyTab({required this.vm});

  @override
  Widget build(BuildContext context) {
    final daily = vm.daily;
    if (daily == null) {
      return const Center(child: Text('No daily plan available yet.'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(daily.message, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        ...daily.insights.map(
          (i) => Card(
            child: ListTile(
              title: Text(i.title),
              subtitle: Text(i.body),
              leading: const Icon(Icons.lightbulb_outline),
            ),
          ),
        ),
        ...daily.recommendations.map(
          (r) => Card(
            child: ListTile(
              title: Text(r.text),
              subtitle: Text(r.reason),
              leading: const Icon(Icons.check_circle_outline),
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: vm.refreshDaily,
          icon: const Icon(Icons.refresh),
          label: const Text('Regenerate'),
        ),
      ],
    );
  }
}

class _ChatTab extends StatelessWidget {
  final CoachViewModel vm;
  final TextEditingController controller;

  const _ChatTab({required this.vm, required this.controller});

  @override
  Widget build(BuildContext context) {
    final messages = vm.conversation?.messages ?? const <ConversationMessage>[];

    return Column(
      children: [
        Expanded(
          child: messages.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Ask about today\'s workout, recovery, nutrition, or progress.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final m = messages[index];
                    final isUser = m.role == CoachMessageRole.user;
                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                        ),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(m.content),
                      ),
                    );
                  },
                ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Ask your coach...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _send(context),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: vm.sending ? null : () => _send(context),
                  icon: vm.sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _send(BuildContext context) {
    final text = controller.text;
    controller.clear();
    context.read<CoachViewModel>().sendMessage(text);
  }
}

class _WeeklyTab extends StatelessWidget {
  final CoachViewModel vm;

  const _WeeklyTab({required this.vm});

  @override
  Widget build(BuildContext context) {
    final report = vm.weeklyReport;
    final coaching = vm.weekly;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (report != null) ...[
          Text('This week', style: Theme.of(context).textTheme.titleMedium),
          ListTile(
            title: const Text('Workouts'),
            trailing: Text(
              '${report.workoutsCompleted}/${report.workoutsPlanned}',
            ),
          ),
          ListTile(
            title: const Text('Consistency'),
            trailing: Text('${report.consistencyScore}%'),
          ),
          if (report.weightChangeKg != null)
            ListTile(
              title: const Text('Weight change'),
              trailing:
                  Text('${report.weightChangeKg!.toStringAsFixed(1)} kg'),
            ),
          const Divider(),
        ],
        if (coaching != null) ...[
          Text(coaching.message),
          const SizedBox(height: 12),
          ...coaching.recommendations.map(
            (r) => ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: Text(r.text),
              subtitle: Text(r.reason),
            ),
          ),
        ] else
          const Text('Weekly coaching will appear once a daily plan exists.'),
      ],
    );
  }
}

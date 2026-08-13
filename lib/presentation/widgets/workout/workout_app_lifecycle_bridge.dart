import 'package:flutter/widgets.dart';
import 'package:gymgenius/presentation/providers/workout_session_manager.dart';
import 'package:provider/provider.dart';

/// Bridges app lifecycle events to workout timer background notifications.
class WorkoutAppLifecycleBridge extends StatefulWidget {
  const WorkoutAppLifecycleBridge({super.key, required this.child});

  final Widget child;

  @override
  State<WorkoutAppLifecycleBridge> createState() =>
      _WorkoutAppLifecycleBridgeState();
}

class _WorkoutAppLifecycleBridgeState extends State<WorkoutAppLifecycleBridge>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final manager = context.read<WorkoutSessionManager>();
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        manager.onAppBackgrounded();
        break;
      case AppLifecycleState.resumed:
        manager.onAppForegrounded();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

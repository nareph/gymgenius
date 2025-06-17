// widgets/sync_status_widget.dart
import 'package:flutter/material.dart';
import 'package:gymgenius/viewmodels/sync_viewmodel.dart';
import 'package:provider/provider.dart';

class SyncStatusWidget extends StatelessWidget {
  final bool showInAppBar;

  const SyncStatusWidget({
    super.key,
    this.showInAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    // Consume the SyncViewModel
    final syncViewModel = context.watch<SyncViewModel>();

    // If online and no workouts to sync, show nothing.
    if (syncViewModel.isOnline && syncViewModel.totalWorkouts == 0) {
      return const SizedBox.shrink();
    }

    if (showInAppBar) {
      return _buildAppBarIcon(context, syncViewModel);
    } else {
      return _buildBanner(context, syncViewModel);
    }
  }

  Widget _buildAppBarIcon(BuildContext context, SyncViewModel viewModel) {
    return PopupMenuButton<String>(
      icon: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            viewModel.isOnline
                ? Icons.cloud_sync_outlined
                : Icons.cloud_off_outlined,
            color: viewModel.isOnline
                ? (viewModel.isSyncing ? Colors.blue : Colors.white)
                : Colors.orange,
          ),
          if (viewModel.totalWorkouts > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: viewModel.failedCount > 0 ? Colors.red : Colors.blue,
                  borderRadius: BorderRadius.circular(6),
                ),
                constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                child: Text(
                  '${viewModel.totalWorkouts}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          if (viewModel.isSyncing)
            const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2)),
        ],
      ),
      onSelected: (String value) async {
        String? message;
        if (value == 'sync') {
          message = await viewModel.syncPendingWorkouts();
        } else if (value == 'recover') {
          message = await viewModel.forceRecoverStuckWorkouts();
        }
        if (message != null && context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message)));
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'sync',
          enabled: viewModel.isOnline &&
              viewModel.totalWorkouts > 0 &&
              !viewModel.isSyncing,
          child: Text('Sync Now (${viewModel.totalWorkouts})'),
        ),
        if (viewModel.syncingCount > 0)
          PopupMenuItem<String>(
            value: 'recover',
            enabled: !viewModel.isSyncing,
            child: Text('Fix Stuck (${viewModel.syncingCount})'),
          ),
      ],
    );
  }

  /// Builds a detailed banner view for the sync status.
  /// Typically shown in the body of a screen, not the AppBar.
  Widget _buildBanner(BuildContext context, SyncViewModel viewModel) {
    final theme = Theme.of(context);
    final isOnline = viewModel.isOnline;
    final totalWorkouts = viewModel.totalWorkouts;

    // Determine colors based on the state.
    final Color backgroundColor =
        isOnline ? Colors.blue.shade50 : Colors.orange.shade50;
    final Color borderColor =
        isOnline ? Colors.blue.shade200 : Colors.orange.shade200;
    final Color iconColor =
        isOnline ? Colors.blue.shade600 : Colors.orange.shade600;
    final Color textColor =
        isOnline ? Colors.blue.shade800 : Colors.orange.shade800;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isOnline ? Icons.cloud_sync_outlined : Icons.cloud_off_outlined,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _buildStatusText(viewModel), // Use helper to get main text
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Show buttons only if online and there are workouts to sync/fix
              if (isOnline && totalWorkouts > 0)
                viewModel.isSyncing
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: iconColor),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // "Fix stuck" button
                          if (viewModel.syncingCount > 0)
                            IconButton(
                              icon: Icon(Icons.healing,
                                  color: Colors.orange.shade600, size: 20),
                              onPressed: () async {
                                final message =
                                    await viewModel.forceRecoverStuckWorkouts();
                                if (message != null && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(message)));
                                }
                              },
                              tooltip:
                                  'Fix ${viewModel.syncingCount} stuck workout(s)',
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                            ),
                          const SizedBox(width: 4),
                          // "Sync now" button
                          IconButton(
                            icon: Icon(Icons.sync,
                                color: Colors.blue.shade600, size: 20),
                            onPressed: () async {
                              final message =
                                  await viewModel.syncPendingWorkouts();
                              if (message != null && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(message)));
                              }
                            },
                            tooltip: 'Sync now',
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
            ],
          ),
          // Show detailed text only if there are workouts in queue
          if (totalWorkouts > 0) ...[
            const SizedBox(height: 4),
            Text(
              _buildDetailText(viewModel), // Use helper to get detail text
              style: theme.textTheme.bodySmall?.copyWith(
                color: textColor.withAlpha(204),
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Helper method to build the main status text.
  String _buildStatusText(SyncViewModel viewModel) {
    if (!viewModel.isOnline) {
      return 'Offline - ${viewModel.totalWorkouts} workout(s) saved locally';
    } else if (viewModel.totalWorkouts == 0) {
      return 'All workouts synced';
    } else {
      return '${viewModel.totalWorkouts} workout(s) waiting to sync';
    }
  }

  /// Helper method to build the detailed breakdown text.
  String _buildDetailText(SyncViewModel viewModel) {
    List<String> parts = [];
    if (viewModel.pendingCount > 0) {
      parts.add('${viewModel.pendingCount} pending');
    }
    if (viewModel.syncingCount > 0) {
      parts.add('${viewModel.syncingCount} syncing');
    }
    if (viewModel.failedCount > 0) parts.add('${viewModel.failedCount} failed');
    return parts.join(' • ');
  }
}

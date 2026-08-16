// lib/presentation/screens/tabs/home_tab_screen.dart

import 'package:flutter/material.dart';
import 'package:gymgenius/presentation/screens/profile_setup/profile_setup_screen.dart';
import 'package:gymgenius/presentation/viewmodels/home_viewmodel.dart';
import 'package:gymgenius/presentation/widgets/home/complete_profile_view.dart';
import 'package:gymgenius/presentation/widgets/home/error_view.dart';
import 'package:gymgenius/presentation/widgets/home/expired_program_view.dart';
import 'package:gymgenius/presentation/widgets/home/loading_view.dart';
import 'package:gymgenius/presentation/widgets/home/no_program_view.dart';
import 'package:gymgenius/presentation/widgets/home/program_dashboard_view.dart';
import 'package:provider/provider.dart';

class HomeTabScreen extends StatefulWidget {
  final Function(int) onNavigateToTab;

  const HomeTabScreen({
    super.key,
    required this.onNavigateToTab,
  });

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HomeViewModel>().triggerCheckInIfNeeded(context);
    });
  }

  /// Pushed (not swapped in by AuthWrapper), so ProfileSetupScreen's own
  /// Navigator.pop()-free listener still works fine here — but since we
  /// removed that pop entirely (AuthWrapper case), we drive the pop from
  /// here instead once the pushed route returns, then refresh so
  /// HomeViewModel picks up the completed profile.
  Future<void> _completeProfile(
    BuildContext context,
    HomeViewModel viewModel,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfileSetupScreen(
          isPostLogin: true,
          missingFieldIds: viewModel.healthProfile?.missingFieldIds,
        ),
      ),
    );
    if (context.mounted) {
      await viewModel.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: viewModel.refresh,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildBody(context, viewModel),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, HomeViewModel viewModel) {
    Widget wrapInScrollable(Widget child) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: child),
          ),
        ),
      );
    }

    if (viewModel.isGeneratingProgram) {
      return const LoadingView(
        key: ValueKey('generating'),
        message: "Generating your new training program...",
      );
    }

    switch (viewModel.state) {
      case HomeState.initial:
      case HomeState.loading:
        return const LoadingView(
          key: ValueKey('loading'),
          message: "Loading your dashboard...",
        );

      case HomeState.error:
        return wrapInScrollable(ErrorView(
          key: const ValueKey('error_view'),
          message: viewModel.errorMessage ?? "An unknown error occurred.",
          onRetry: viewModel.refresh,
        ));

      case HomeState.loaded:
        final isProfileComplete = viewModel.healthProfile?.isComplete ?? false;
        if (!isProfileComplete) {
          // Reuses the polished ProfileSetupScreen onboarding flow
          // (one question at a time, per-question skip, progress dots)
          // instead of the generic ProfileTabScreen edit form — the
          // latter is built for editing an already-complete profile,
          // not for guiding someone through filling one out for the
          // first time.
          return wrapInScrollable(CompleteProfileView(
            key: const ValueKey('complete_profile'),
            onNavigate: () => _completeProfile(context, viewModel),
            isInsufficient: true,
          ));
        }

        if (viewModel.currentProgram == null) {
          return wrapInScrollable(NoProgramView(
            key: const ValueKey('no_program'),
            onGenerate: viewModel.generateNewProgram,
          ));
        }

        if (viewModel.currentProgram!.isExpired) {
          return wrapInScrollable(ExpiredProgramView(
            key: const ValueKey('expired_program'),
            programName: viewModel.currentProgram!.name,
            onGenerate: viewModel.generateNewProgram,
            onDismiss: viewModel.dismissExpiredProgram,
          ));
        }

        return ProgramDashboardView(
          key: const ValueKey('dashboard'),
          program: viewModel.currentProgram!,
          healthProfile: viewModel.healthProfile!,
          dailyPlan: viewModel.dailyPlan!,
        );
    }
  }
}

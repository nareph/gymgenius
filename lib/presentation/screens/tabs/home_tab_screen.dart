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
        final healthProfile = viewModel.healthProfile;

        // Case 1: No profile exists at all → user must create one.
        if (healthProfile == null) {
          return wrapInScrollable(CompleteProfileView(
            key: const ValueKey('no_profile'),
            onNavigate: () => _completeProfile(context, viewModel),
            isInsufficient: true, // or false; we can show a specific message
          ));
        }

        // Case 2: Profile exists but is incomplete.
        if (!healthProfile.isComplete) {
          return wrapInScrollable(CompleteProfileView(
            key: const ValueKey('incomplete_profile'),
            onNavigate: () => _completeProfile(context, viewModel),
            isInsufficient: true,
          ));
        }

        // Case 3: No program yet.
        if (viewModel.currentProgram == null) {
          return wrapInScrollable(NoProgramView(
            key: const ValueKey('no_program'),
            onGenerate: viewModel.generateNewProgram,
          ));
        }

        // Case 4: Program expired.
        if (viewModel.currentProgram!.isExpired) {
          return wrapInScrollable(ExpiredProgramView(
            key: const ValueKey('expired_program'),
            programName: viewModel.currentProgram!.name,
            onGenerate: viewModel.generateNewProgram,
            onDismiss: viewModel.dismissExpiredProgram,
          ));
        }

        // Case 5: Everything ready → dashboard.
        return ProgramDashboardView(
          key: const ValueKey('dashboard'),
          program: viewModel.currentProgram!,
          healthProfile: healthProfile,
          dailyPlan: viewModel.dailyPlan!,
        );
    }
  }
}

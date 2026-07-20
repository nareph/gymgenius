// lib/screens/tabs/home_tab_screen.dart
import 'package:flutter/material.dart';
import 'package:gymgenius/viewmodels/home_viewmodel.dart';
import 'package:gymgenius/widgets/home/complete_profile_view.dart';
import 'package:gymgenius/widgets/home/error_view.dart';
import 'package:gymgenius/widgets/home/expired_program_view.dart';
import 'package:gymgenius/widgets/home/loading_view.dart';
import 'package:gymgenius/widgets/home/no_program_view.dart';
import 'package:gymgenius/widgets/home/program_dashboard_view.dart';
import 'package:provider/provider.dart';

import '../main_dashboard_screen.dart';

class HomeTabScreen extends StatelessWidget {
  final Function(int) onNavigateToTab;

  const HomeTabScreen({
    super.key,
    required this.onNavigateToTab,
  });

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
        if (!viewModel.isProfileComplete ||
            viewModel.onboardingData == null ||
            !viewModel.onboardingData!.isSufficientForAiGeneration) {
          return wrapInScrollable(CompleteProfileView(
            key: const ValueKey('complete_profile'),
            onNavigate: () => onNavigateToTab(kProfileTabIndex),
            isInsufficient: true,
          ));
        }

        if (viewModel.currentProgram == null) {
          return wrapInScrollable(NoProgramView(
            key: const ValueKey('no_program'),
            onGenerate: viewModel.generateNewProgram,
          ));
        }

        if (viewModel.currentProgram!.isExpired()) {
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
          weeklyWorkout: viewModel.currentWeeklyWorkout,
          onboardingData: viewModel.onboardingData!,
        );
    }
  }
}

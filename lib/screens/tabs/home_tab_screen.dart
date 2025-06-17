import 'package:flutter/material.dart';
import 'package:gymgenius/viewmodels/home_viewmodel.dart';
import 'package:gymgenius/widgets/home/complete_profile_view.dart';
import 'package:gymgenius/widgets/home/error_view.dart';
import 'package:gymgenius/widgets/home/expired_routine_view.dart';
import 'package:gymgenius/widgets/home/loading_view.dart';
import 'package:gymgenius/widgets/home/no_routine_view.dart';
import 'package:gymgenius/widgets/home/offline_view.dart';
import 'package:gymgenius/widgets/home/routine_dashboard_view.dart';
import 'package:provider/provider.dart';

import '../main_dashboard_screen.dart'; // Pour kProfileTabIndex

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

    if (viewModel.isGeneratingRoutine) {
      return const LoadingView(
          key: ValueKey('generating'),
          message: "Generating your new routine...");
    }

    switch (viewModel.state) {
      case HomeState.initial:
      case HomeState.loading:
        return const LoadingView(
            key: ValueKey('loading'), message: "Loading your dashboard...");

      case HomeState.offline:
        if (viewModel.currentRoutine != null) {
          return RoutineDashboardView(
            key: const ValueKey('offline_dashboard'),
            routine: viewModel.currentRoutine!,
            onboardingData: viewModel.onboardingData!,
            isOffline: true,
          );
        }
        return wrapInScrollable(OfflineView(
            key: const ValueKey('offline_view'), onRetry: viewModel.refresh));

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
        if (viewModel.currentRoutine == null) {
          return wrapInScrollable(NoRoutineView(
              key: const ValueKey('no_routine'),
              onGenerate: viewModel.generateNewRoutine));
        }
        if (viewModel.currentRoutine!.isExpired()) {
          return wrapInScrollable(ExpiredRoutineView(
            key: const ValueKey('expired_routine'),
            routineName: viewModel.currentRoutine!.name,
            onGenerate: viewModel.generateNewRoutine,
            onDismiss: viewModel.dismissExpiredRoutine,
          ));
        }
        return RoutineDashboardView(
          key: const ValueKey('dashboard'),
          routine: viewModel.currentRoutine!,
          onboardingData: viewModel.onboardingData!,
        );
    }
  }
}

// lib/presentation/screens/tabs/profile_tab_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/core/logger/logger_service.dart';
import 'package:gymgenius/domain/entities/user.dart';
import 'package:gymgenius/presentation/blocs/auth/auth_bloc.dart';
import 'package:gymgenius/presentation/viewmodels/profile_viewmodel.dart';
import 'package:gymgenius/presentation/widgets/common/error_state_view.dart';
import 'package:gymgenius/presentation/widgets/profile/profile_view.dart';
import 'package:provider/provider.dart';

class ProfileTabScreen extends StatelessWidget {
  const ProfileTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();
    final authState = context.watch<AuthBloc>().state;
    final user = authState.user;

    if (user == null) {
      Log.warning("ProfileTabScreen: User is null");
      return const Center(
          child: Text("Error: User not found. Please restart the app."));
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: viewModel.loadProfile,
        child: _buildBody(context, viewModel, user),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, ProfileViewModel viewModel, User user) {
    Widget content;
    switch (viewModel.state) {
      case ProfileState.initial:
      case ProfileState.loading:
        content = const Center(child: CircularProgressIndicator());
        break;
      case ProfileState.error:
        content = ErrorStateView(
          title: "Profile Error",
          message: viewModel.errorMessage ?? "An unknown error occurred.",
          onRetry: viewModel.loadProfile,
        );
        break;
      case ProfileState.loaded:
      case ProfileState.saving:
        content = Column(
          children: [
            ProfileView(
              displayName: user.displayName ?? user.email.split('@').first,
              email: user.email,
              isEditing: viewModel.isEditing,
              isSaving: viewModel.state == ProfileState.saving,
              sourceDataForUI: viewModel.displayData,
              controllers: viewModel.controllers,
              onToggleEdit: () => viewModel.toggleEditMode(),
              onSaveChanges: viewModel.saveChanges,
              onCancelChanges: () => viewModel.toggleEditMode(cancel: true),
              onUpdatePreference: viewModel.updateEditValue,
            ),
            if (!viewModel.isEditing) _buildSignOutButton(context),
          ],
        );
        break;
    }

    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: content,
        ),
      );
    });
  }

  Widget _buildSignOutButton(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: TextButton.icon(
          icon: Icon(Icons.logout_rounded,
              color: Theme.of(context).colorScheme.error, size: 20),
          label: Text(
            "Sign Out",
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () async {
            final confirmSignOut = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Confirm Sign Out'),
                content: const Text('Are you sure you want to sign out?'),
                actions: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                  ),
                  TextButton(
                    child: Text('Sign Out',
                        style: TextStyle(
                            color: Theme.of(dialogContext).colorScheme.error)),
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                  ),
                ],
              ),
            );

            if (confirmSignOut == true && context.mounted) {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            }
          },
        ),
      ),
    );
  }
}

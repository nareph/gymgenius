import 'package:flutter/material.dart';

class CompleteProfileView extends StatelessWidget {
  final VoidCallback onNavigate;
  final bool isInsufficient;

  const CompleteProfileView({
    super.key,
    required this.onNavigate,
    this.isInsufficient = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title =
        isInsufficient ? "Complete Your Profile" : "Finalize Account Setup";
    final message = isInsufficient
        ? "To generate a personalized workout plan, we need a bit more information about you and your goals."
        : "Please complete your profile to activate all features and get your personalized workout plan.";
    final buttonText = isInsufficient ? "Complete Profile" : "Go to Profile";

    return Center(
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_pin_circle_outlined,
                  size: 50, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(title,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.account_circle_outlined),
                label: Text(buttonText),
                onPressed: onNavigate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

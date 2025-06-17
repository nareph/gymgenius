// lib/widgets/profile/profile_header.dart
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String displayName;
  final String email;
  final String memberSince;

  const ProfileHeader({
    super.key,
    required this.displayName,
    required this.email,
    required this.memberSince,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(
              Icons.person_outline_rounded,
              size: 50,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            displayName,
            style:
                textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            email,
            style: textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          if (memberSince != 'N/A')
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                "Member since $memberSince",
                style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withAlpha(178)),
              ),
            ),
        ],
      ),
    );
  }
}

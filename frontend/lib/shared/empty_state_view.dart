// lib/shared/empty_state_view.dart
import 'package:flutter/material.dart';

class EmptyStateView extends StatelessWidget {
  final String iconPath; // For SVG or use an IconData
  final IconData? icon;
  final String title;
  final String message;

  const EmptyStateView({
    Key? key,
    this.iconPath = '',
    this.icon,
    required this.title,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon != null
                ? Icon(icon, size: 80, color: Theme.of(context).colorScheme.secondary.withOpacity(0.5))
                : const SizedBox(height: 80, width: 80), // Placeholder for SVG
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

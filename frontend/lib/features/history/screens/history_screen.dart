// lib/features/history/screens/history_screen.dart
import 'package:flutter/material.dart';
import '../../../shared/empty_state_view.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan History')),
      body: const EmptyStateView(
        icon: Icons.history,
        title: 'No Plants Scanned Yet 🌱',
        message: 'Your history will appear here once you scan some plants.',
      ),
    );
  }
}

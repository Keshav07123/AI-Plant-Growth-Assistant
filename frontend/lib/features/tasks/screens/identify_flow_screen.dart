// lib/features/tasks/screens/identify_flow_screen.dart
import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';

/// Picks image elsewhere, then jumps straight to analysis (no extra delay screen).
class IdentifyFlowScreen extends StatefulWidget {
  final String? imagePath;
  const IdentifyFlowScreen({Key? key, this.imagePath}) : super(key: key);

  @override
  State<IdentifyFlowScreen> createState() => _IdentifyFlowScreenState();
}

class _IdentifyFlowScreenState extends State<IdentifyFlowScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.imagePath == null) return;
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.scanLoading,
        arguments: ScanLoadingArgs(imagePath: widget.imagePath!, task: 'identify'),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imagePath == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Identify Plant')),
        body: const Center(child: Text('No image selected.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Identify Plant')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Starting analysis…'),
          ],
        ),
      ),
    );
  }
}

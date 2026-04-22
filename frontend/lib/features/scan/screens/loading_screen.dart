// lib/features/scan/screens/loading_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../providers/scan_provider.dart';
import '../../../core/state/data_status.dart';

class LoadingScreen extends StatefulWidget {
  final String? imagePath;
  final String task;

  const LoadingScreen({Key? key, this.imagePath, this.task = 'identify'}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.imagePath != null) {
        _startAnalysis(widget.imagePath!);
      }
    });
  }

  Future<void> _startAnalysis(String path) async {
    final provider = Provider.of<ScanProvider>(context, listen: false);
    await provider.performScan(path, task: widget.task);
    
    if (mounted) {
      if (provider.status == DataStatus.success) {
        Navigator.pushReplacementNamed(context, AppRoutes.scanResult);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage ?? 'Analysis failed')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.imagePath != null)
            Image.file(
              File(widget.imagePath!),
              fit: BoxFit.cover,
            ),
          // Blur overlay
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                widget.task == 'disease' ? 'Checking disease…' : 'Identifying plant…',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// lib/features/scan/screens/result_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/scan_provider.dart';
import '../../../shared/glass_card.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final result = Provider.of<ScanProvider>(context).lastResult;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('No result found')),
      );
    }

    final plant = result.matchedPlant;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'scanned_image',
                child: Image.file(
                  File(result.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                plant?.name ?? 'Unknown Plant',
                style: const TextStyle(
                  shadows: [Shadow(color: Colors.black87, blurRadius: 10)],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Wow Feature: Health Score
                  Row(
                    children: [
                      Expanded(
                        child: GlassCard(
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          child: Column(
                            children: [
                              Text('Health Score 🌿', style: Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: 8),
                              Text('${result.plantHealthScore}%', 
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green)),
                              Text(result.healthStatus, style: const TextStyle(color: Colors.green)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GlassCard(
                          backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                          child: Column(
                            children: [
                              Text('Confidence AI', style: Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: 8),
                              Text('${result.confidencePercent.toStringAsFixed(1)}%', 
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                              const Text('High Accuracy', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  if (plant != null) ...[
                    Text(
                      'Common Name',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey),
                    ),
                    Text(
                      plant.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    Text('Scientific Name', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey)),
                    Text(plant.scientificName, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 16)),
                    const SizedBox(height: 16),
                    Text('Description', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(plant.description),
                    const SizedBox(height: 24),
                    Text('Care Instructions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    // Grid for care info
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 2.5,
                      children: [
                        _CareMetricCard(icon: Icons.water_drop, label: 'Water', value: plant.careRequirements.water),
                        _CareMetricCard(icon: Icons.wb_sunny, label: 'Sunlight', value: plant.careRequirements.sunlight),
                        _CareMetricCard(icon: Icons.landscape, label: 'Soil', value: plant.careRequirements.soil),
                        _CareMetricCard(icon: Icons.thermostat, label: 'Temp', value: plant.careRequirements.temperature),
                      ],
                    ),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CareMetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  
  const _CareMetricCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)
        ]
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          )
        ],
      ),
    );
  }
}

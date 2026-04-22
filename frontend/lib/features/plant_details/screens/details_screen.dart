// lib/features/plant_details/screens/details_screen.dart
import 'package:flutter/material.dart';
import '../../../models/plant_model.dart';

class DetailsScreen extends StatelessWidget {
  final PlantModel plant;

  const DetailsScreen({Key? key, required this.plant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(plant.name, style: const TextStyle(shadows: [Shadow(color: Colors.black87, blurRadius: 10)])),
              background: Hero(
                tag: 'plant_image_${plant.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    plant.imageUrl.startsWith('http')
                        ? Image.network(plant.imageUrl, fit: BoxFit.cover)
                        : Image.asset(
                            plant.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.local_florist,
                                size: 72,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.18),
                              Colors.transparent,
                              Colors.black.withOpacity(0.45),
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Common name', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey)),
                  Text(plant.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Text('Scientific name', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey)),
                  Text(plant.scientificName, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 16)),
                  const SizedBox(height: 16),
                  
                  Text('Description', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(plant.description),
                  const SizedBox(height: 24),
                  
                  Text('Care Requirements', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 2.5,
                    children: [
                      _CareBadge(icon: Icons.water_drop, label: 'Water', value: plant.careRequirements.water),
                      _CareBadge(icon: Icons.wb_sunny, label: 'Sunlight', value: plant.careRequirements.sunlight),
                      _CareBadge(icon: Icons.landscape, label: 'Soil', value: plant.careRequirements.soil),
                      _CareBadge(icon: Icons.thermostat, label: 'Temp', value: plant.careRequirements.temperature),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  Text('Growth Stages', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: plant.growthSteps.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          child: Text('${index + 1}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(plant.growthSteps[index]),
                      );
                    },
                  ),
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

class _CareBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  
  const _CareBadge({required this.icon, required this.label, required this.value});

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

import 'package:flutter/material.dart';
import '../../../models/plant_model.dart';
import '../../plant_details/screens/details_screen.dart';

class MorePlantsScreen extends StatefulWidget {
  final List<PlantModel> plants;

  const MorePlantsScreen({super.key, required this.plants});

  @override
  State<MorePlantsScreen> createState() => _MorePlantsScreenState();
}

class _MorePlantsScreenState extends State<MorePlantsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PlantModel> get _filteredPlants {
    final sortedPlants = [...widget.plants]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return sortedPlants;
    return sortedPlants.where((plant) {
      return plant.name.toLowerCase().contains(query) ||
          plant.scientificName.toLowerCase().contains(query);
    }).toList();
  }

  List<PlantModel> get _suggestions {
    if (_query.trim().isEmpty) return [];
    return _filteredPlants.take(6).toList();
  }

  void _openPlant(PlantModel plant) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailsScreen(plant: plant)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final filtered = _filteredPlants;
    final suggestions = _suggestions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('More plants'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search a plant...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (suggestions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scheme.outline.withOpacity(0.2)),
                ),
                child: Column(
                  children: suggestions.map((plant) {
                    return ListTile(
                      title: Text(plant.name),
                      subtitle: Text(plant.scientificName),
                      leading: const Icon(Icons.local_florist_outlined),
                      onTap: () {
                        _searchController.text = plant.name;
                        setState(() => _query = plant.name);
                        _openPlant(plant);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text('No plants found.'))
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final plant = filtered[index];
                        return ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          tileColor: scheme.surfaceContainerHighest.withOpacity(0.35),
                          leading: Hero(
                            tag: 'plant_image_${plant.id}',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                plant.imageUrl,
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.local_florist,
                                  color: scheme.primary,
                                ),
                              ),
                            ),
                          ),
                          title: Text(plant.name),
                          subtitle: Text(plant.scientificName),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => _openPlant(plant),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/providers/plant_provider.dart
import 'package:flutter/material.dart';
import '../models/plant_model.dart';
import '../data/model_catalog.dart';
import '../services/task_ai_service.dart';

class PlantProvider with ChangeNotifier {
  List<PlantModel> _plants = [];
  List<PlantModel> get plants => _plants;
  final TaskAiService _taskAiService = TaskAiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  PlantProvider() {
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    _isLoading = true;
    notifyListeners();

    try {
      final entries = await _taskAiService.fetchAllPlantEntries();
      final catalogByName = {
        for (final plant in ModelCatalog.plants) plant.name.toLowerCase(): plant,
      };
      final dbPlants = entries.asMap().entries.map((entry) {
        final index = entry.key;
        final plantName = entry.value['name']!.trim();
        final scientificName = entry.value['scientific_name']!.trim();
        final knownPlant = catalogByName[plantName.toLowerCase()];
        if (knownPlant != null) {
          return PlantModel(
            id: 'db_${index}_${knownPlant.id}',
            name: knownPlant.name,
            scientificName: knownPlant.scientificName,
            description: knownPlant.description,
            imageUrl: knownPlant.imageUrl,
            careRequirements: knownPlant.careRequirements,
            growthSteps: knownPlant.growthSteps,
          );
        }
        return PlantModel(
          id: 'db_${index}_${plantName.toLowerCase().replaceAll(' ', '_')}',
          name: plantName,
          scientificName: scientificName.isEmpty ? plantName : scientificName,
          description:
              'Plant available in your growth database. Open details or Grow a Plant for guided steps.',
          imageUrl: '',
          careRequirements: CareRequirements(
            water: 'Check species-specific schedule',
            sunlight: 'Depends on plant type',
            soil: 'Well-draining mix recommended',
            temperature: 'Moderate range',
            fertilizer: 'Use balanced fertilizer when needed',
          ),
          growthSteps: const [
            'Use the Grow a Plant flow for tailored growth guidance.',
            'Keep monitoring leaves and watering routine.',
            'Adjust care based on season and local weather.',
          ],
        );
      }).toList();

      final existingNames = {for (final plant in dbPlants) plant.name.toLowerCase()};
      final modelOnlyPlants = ModelCatalog.plants.where(
        (plant) => !existingNames.contains(plant.name.toLowerCase()),
      );

      _plants = [
        ...dbPlants,
        ...modelOnlyPlants,
      ];
    } catch (_) {
      _plants = ModelCatalog.plants;
    }
    _isLoading = false;
    notifyListeners();
  }

  PlantModel getPlantById(String id) {
    return _plants.firstWhere((p) => p.id == id);
  }
}

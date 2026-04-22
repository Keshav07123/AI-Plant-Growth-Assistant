// lib/models/plant_model.dart

class PlantModel {
  final String id;
  final String name;
  final String scientificName;
  final String description;
  final String imageUrl;
  final CareRequirements careRequirements;
  final List<String> growthSteps;
  
  PlantModel({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.description,
    required this.imageUrl,
    required this.careRequirements,
    required this.growthSteps,
  });
}

class CareRequirements {
  final String water;
  final String sunlight;
  final String soil;
  final String temperature;
  final String fertilizer;

  CareRequirements({
    required this.water,
    required this.sunlight,
    required this.soil,
    required this.temperature,
    required this.fertilizer,
  });
}

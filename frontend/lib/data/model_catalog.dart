import '../models/plant_model.dart';

/// Crops/species represented in `final_plant_model.keras` (PlantVillage-style labels).
/// Only these appear on the home screen collection.
class ModelCatalog {
  ModelCatalog._();

  static List<PlantModel> get plants => [
        PlantModel(
          id: 'model_apple',
          name: 'Apple',
          scientificName: 'Malus domestica',
          description:
              'Included in your disease-detection model. Capture a clear leaf image for best results.',
          imageUrl: 'assets/plants/apple.jpg',
          careRequirements: CareRequirements(
            water: 'Keep soil evenly moist in growing season',
            sunlight: 'Full sun (6+ hours)',
            soil: 'Deep, fertile, well-drained',
            temperature: '15°C - 25°C',
            fertilizer: 'Balanced feed in spring',
          ),
          growthSteps: [
            'Prune in late winter to open the canopy.',
            'Thin fruit early to avoid overcrowding.',
            'Watch leaves for spots or scab-like lesions.',
          ],
        ),
        PlantModel(
          id: 'model_blueberry',
          name: 'Blueberry',
          scientificName: 'Vaccinium spp.',
          description:
              'Included in your trained model. Acidic soil is important for healthy bushes.',
          imageUrl: 'assets/plants/blueberry.jpg',
          careRequirements: CareRequirements(
            water: 'Consistent moisture, avoid drought',
            sunlight: 'Full sun',
            soil: 'Acidic (pH 4.5–5.5), rich in organic matter',
            temperature: '15°C - 28°C',
            fertilizer: 'Acid-loving plant fertilizer',
          ),
          growthSteps: [
            'Mulch to keep roots cool and moist.',
            'Prune old canes after a few years.',
            'Net bushes if birds eat the berries.',
          ],
        ),
        PlantModel(
          id: 'model_cherry',
          name: 'Cherry',
          scientificName: 'Prunus avium / P. cerasus',
          description:
              'Cherry (including sour) classes are in your model. Leaf images work best.',
          imageUrl: 'assets/plants/cherry.jpg',
          careRequirements: CareRequirements(
            water: 'Deep water during dry spells',
            sunlight: 'Full sun',
            soil: 'Well-drained loam',
            temperature: '12°C - 26°C',
            fertilizer: 'Light feeding in early spring',
          ),
          growthSteps: [
            'Plant in a spot with good airflow.',
            'Monitor leaves for powdery mildew signs.',
            'Harvest when fruit color and firmness look right.',
          ],
        ),
        PlantModel(
          id: 'model_corn',
          name: 'Corn (maize)',
          scientificName: 'Zea mays',
          description:
              'Maize leaf diseases in your model. Photograph affected leaves up close.',
          imageUrl: 'assets/plants/corn.jpg',
          careRequirements: CareRequirements(
            water: '1–1.5 inches per week',
            sunlight: 'Full sun',
            soil: 'Rich, well-drained',
            temperature: '18°C - 30°C',
            fertilizer: 'Nitrogen-heavy when young',
          ),
          growthSteps: [
            'Plant in blocks for better pollination.',
            'Control weeds early; avoid damaging roots.',
            'Check mid-leaf for blight or rust patterns.',
          ],
        ),
        PlantModel(
          id: 'model_grape',
          name: 'Grape',
          scientificName: 'Vitis vinifera',
          description:
              'Grapevine leaf diseases are covered by your model.',
          imageUrl: 'assets/plants/grape.jpg',
          careRequirements: CareRequirements(
            water: 'Moderate; reduce before harvest',
            sunlight: 'Full sun',
            soil: 'Well-drained, not overly fertile',
            temperature: '18°C - 30°C',
            fertilizer: 'Light nitrogen if vines are weak',
          ),
          growthSteps: [
            'Train vines on a trellis or wires.',
            'Improve airflow with pruning and leaf thinning.',
            'Inspect leaves for rot, measles, or blight.',
          ],
        ),
        PlantModel(
          id: 'model_orange',
          name: 'Orange (citrus)',
          scientificName: 'Citrus × sinensis',
          description:
              'Citrus greening class exists in your model; use representative leaf photos.',
          imageUrl: 'assets/plants/orange.jpg',
          careRequirements: CareRequirements(
            water: 'Deep, less frequent watering',
            sunlight: 'Bright light / full sun',
            soil: 'Well-drained',
            temperature: '18°C - 32°C',
            fertilizer: 'Citrus-specific fertilizer',
          ),
          growthSteps: [
            'Protect from hard frost.',
            'Watch for mottled or asymmetrical leaves.',
            'Avoid overwatering in containers.',
          ],
        ),
        PlantModel(
          id: 'model_peach',
          name: 'Peach',
          scientificName: 'Prunus persica',
          description:
              'Peach bacterial spot is one class in your trained weights.',
          imageUrl: 'assets/plants/peach.jpg',
          careRequirements: CareRequirements(
            water: 'Deep watering weekly when fruiting',
            sunlight: 'Full sun',
            soil: 'Deep, fertile, well-drained',
            temperature: '15°C - 28°C',
            fertilizer: 'Balanced feed after bloom',
          ),
          growthSteps: [
            'Thin fruit for larger peaches.',
            'Prune annually for an open vase shape.',
            'Check leaves for angular spots or holes.',
          ],
        ),
        PlantModel(
          id: 'model_pepper',
          name: 'Bell pepper',
          scientificName: 'Capsicum annuum',
          description:
              'Bell pepper classes are in your model dataset.',
          imageUrl: 'assets/plants/bellpepper.jpg',
          careRequirements: CareRequirements(
            water: 'Even moisture; avoid wetting foliage',
            sunlight: 'Full sun',
            soil: 'Rich, well-drained',
            temperature: '21°C - 29°C',
            fertilizer: 'Regular feeding during fruit set',
          ),
          growthSteps: [
            'Stake plants if heavy with fruit.',
            'Remove crowded lower leaves for airflow.',
            'Watch for spots or yellowing.',
          ],
        ),
        PlantModel(
          id: 'model_potato',
          name: 'Potato',
          scientificName: 'Solanum tuberosum',
          description:
              'Early and late blight classes are in your model—leaf photos help most.',
          imageUrl: 'assets/plants/potato.jpg',
          careRequirements: CareRequirements(
            water: 'Consistent moisture; hill soil around stems',
            sunlight: 'Full sun',
            soil: 'Loose, well-drained',
            temperature: '15°C - 24°C',
            fertilizer: 'Avoid excess nitrogen late season',
          ),
          growthSteps: [
            'Hill soil as plants grow.',
            'Stop watering when plants begin to die back.',
            'Inspect leaflets for blight lesions.',
          ],
        ),
        PlantModel(
          id: 'model_raspberry',
          name: 'Raspberry',
          scientificName: 'Rubus idaeus',
          description:
              'Healthy raspberry class is included in your model.',
          imageUrl: 'assets/plants/raspberry.jpg',
          careRequirements: CareRequirements(
            water: 'Regular moisture',
            sunlight: 'Full sun to partial shade',
            soil: 'Rich, slightly acidic, well-drained',
            temperature: '15°C - 26°C',
            fertilizer: 'Compost or balanced feed in spring',
          ),
          growthSteps: [
            'Prune floricanes after fruiting.',
            'Thin crowded canes.',
            'Mulch to reduce splash-borne disease.',
          ],
        ),
        PlantModel(
          id: 'model_soybean',
          name: 'Soybean',
          scientificName: 'Glycine max',
          description:
              'Soybean healthy class is in your model.',
          imageUrl: 'assets/plants/soybean.jpg',
          careRequirements: CareRequirements(
            water: 'Moist during pod fill',
            sunlight: 'Full sun',
            soil: 'Well-drained loam',
            temperature: '18°C - 30°C',
            fertilizer: 'Often minimal if soil is fertile',
          ),
          growthSteps: [
            'Rotate crops to reduce disease buildup.',
            'Scout leaves for unusual spots.',
            'Harvest when pods mature.',
          ],
        ),
        PlantModel(
          id: 'model_squash',
          name: 'Squash',
          scientificName: 'Cucurbita spp.',
          description:
              'Powdery mildew on squash leaves is modeled.',
          imageUrl: 'assets/plants/squash.jpg',
          careRequirements: CareRequirements(
            water: 'Deep watering at soil level',
            sunlight: 'Full sun',
            soil: 'Rich, well-drained',
            temperature: '18°C - 30°C',
            fertilizer: 'Compost or balanced fertilizer',
          ),
          growthSteps: [
            'Space plants for airflow.',
            'Avoid overhead watering if mildew is an issue.',
            'Check leaf undersides for mildew.',
          ],
        ),
        PlantModel(
          id: 'model_strawberry',
          name: 'Strawberry',
          scientificName: 'Fragaria × ananassa',
          description:
              'Leaf scorch and healthy classes appear in your model.',
          imageUrl: 'assets/plants/strawberry.jpg',
          careRequirements: CareRequirements(
            water: 'Consistent moisture; drip preferred',
            sunlight: 'Full sun',
            soil: 'Slightly acidic, well-drained',
            temperature: '15°C - 26°C',
            fertilizer: 'Feed after harvest renovation',
          ),
          growthSteps: [
            'Renovate beds after harvest.',
            'Mulch with straw to keep fruit clean.',
            'Remove leaves with heavy scorch if needed.',
          ],
        ),
        PlantModel(
          id: 'model_tomato',
          name: 'Tomato',
          scientificName: 'Solanum lycopersicum',
          description:
              'Many tomato disease classes are in your model—the largest group.',
          imageUrl: 'assets/plants/tomato.jpg',
          careRequirements: CareRequirements(
            water: 'Deep, regular watering',
            sunlight: 'Full sun (6–8 hours)',
            soil: 'Rich, slightly acidic, well-drained',
            temperature: '18°C - 29°C',
            fertilizer: 'Balanced; extra phosphorus during flowering',
          ),
          growthSteps: [
            'Stake or cage plants early.',
            'Prune lower leaves for airflow.',
            'Inspect leaves for spots, mosaic, or curling.',
          ],
        ),
      ];
}

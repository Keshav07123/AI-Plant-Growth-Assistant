// lib/services/dummy_data_service.dart
import '../models/plant_model.dart';

class PlantDataService {
  static final List<PlantModel> plants = [
    PlantModel(
      id: 'p1',
      name: 'Rose',
      scientificName: 'Rosa rubiginosa',
      description: 'A classic and beautiful flowering shrub known for its fragrant blooms and thorny stems. Highly valued as an ornamental plant.',
      imageUrl: 'assets/rose.png',
      careRequirements: CareRequirements(
        water: 'Every 2-3 days',
        sunlight: 'Full Sun (6+ hrs)',
        soil: 'Loamy, well-draining',
        temperature: '15°C - 28°C',
        fertilizer: 'Every 2 weeks in spring',
      ),
      growthSteps: [
        'Plant rose bush in a sunny spot.',
        'Water deeply to establish roots.',
        'Prune in early spring to encourage new growth.',
        'Apply fertilizer as buds begin to form.',
        'Enjoy blooming throughout summer.'
      ],
    ),
    PlantModel(
      id: 'p2',
      name: 'Tulsi',
      scientificName: 'Ocimum tenuiflorum',
      description: 'Holy Basil is a sacred and medicinal herb widely grown in Southeast Asia for religious, culinary, and health purposes.',
      imageUrl: 'assets/tulsi.png',
      careRequirements: CareRequirements(
        water: 'Daily in summer',
        sunlight: 'Full Sun / Partial Shade',
        soil: 'Rich organic, well-draining',
        temperature: '20°C - 35°C',
        fertilizer: 'Organic compost monthly',
      ),
      growthSteps: [
        'Sow seeds 1/4 inch deep in rich soil.',
        'Keep soil consistently moist but not waterlogged.',
        'Pinch early flowers to encourage bushier leaf growth.',
        'Harvest leaves as needed for teas or cooking.'
      ],
    ),
    PlantModel(
      id: 'p3',
      name: 'Aloe Vera',
      scientificName: 'Aloe barbadensis miller',
      description: 'A popular succulent species primarily known for the soothing cosmetic and medicinal gel held within its thick leaves.',
      imageUrl: 'assets/aloe_vera.png',
      careRequirements: CareRequirements(
        water: 'Every 2-3 weeks',
        sunlight: 'Bright indirect',
        soil: 'Cactus/Succulent mix',
        temperature: '13°C - 27°C',
        fertilizer: 'Once a year in spring',
      ),
      growthSteps: [
        'Plant in a pot with drainage holes.',
        'Water thoroughly, then let soil dry completely.',
        'Place in a bright room but avoid scorching direct sun.',
        'Repot pups (offshoots) to propagate new plants.'
      ],
    ),
    PlantModel(
      id: 'p4',
      name: 'Money Plant',
      scientificName: 'Epipremnum aureum',
      description: 'A hardy, low-maintenance trailing vine famous for its heart-shaped leaves and supposed ability to bring financial luck.',
      imageUrl: 'assets/money_plant.png',
      careRequirements: CareRequirements(
        water: 'Once a week',
        sunlight: 'Low to bright indirect',
        soil: 'Well-draining potting mix',
        temperature: '15°C - 30°C',
        fertilizer: 'Every 1-2 months',
      ),
      growthSteps: [
        'Propagate via a stem cutting in water or soil.',
        'Provide climbing support or let it trail from a basket.',
        'Wipe leaves occasionally with a damp cloth to remove dust.',
        'Prune to control length and promote bushier growth.'
      ],
    ),
    PlantModel(
      id: 'p5',
      name: 'Sunflower',
      scientificName: 'Helianthus annuus',
      description: 'Tall, vibrant, and sun-tracking annuals carrying large, iconic yellow flower heads that produce edible seeds.',
      imageUrl: 'assets/sunflower.png',
      careRequirements: CareRequirements(
        water: 'Deep watering weekly',
        sunlight: 'Full Sun (8+ hrs)',
        soil: 'Loose, nutrient-rich',
        temperature: '21°C - 26°C',
        fertilizer: 'Only in poor soils',
      ),
      growthSteps: [
        'Direct sow seeds after the last frost.',
        'Protect young seedlings from pests.',
        'Provide stakes for taller varieties to withstand wind.',
        'Harvest heads once petals dry and back turns brown.'
      ],
    ),
    PlantModel(
      id: 'p6',
      name: 'Tomato',
      scientificName: 'Solanum lycopersicum',
      description: 'A fruiting vine native to South America, tomatoes are one of the most popular garden vegetables grown worldwide.',
      imageUrl: 'assets/tomato.png',
      careRequirements: CareRequirements(
        water: '1-2 inches weekly',
        sunlight: 'Full Sun (6-8 hrs)',
        soil: 'Slightly acidic, loamy',
        temperature: '18°C - 29°C',
        fertilizer: 'High phosphorus every 2-3 weeks',
      ),
      growthSteps: [
        'Start seeds indoors 6-8 weeks before last frost.',
        'Transplant deeply into the garden embedding the lower stem.',
        'Add a trellis or tomato cage for immediate support.',
        'Pinch off suckers to direct energy into fruit bearing.'
      ],
    ),
    PlantModel(
      id: 'p7',
      name: 'Mint',
      scientificName: 'Mentha',
      description: 'Incredibly vigorous and aromatic perennial herb widely used in teas, cocktails, and culinary garnishes.',
      imageUrl: 'assets/mint.png',
      careRequirements: CareRequirements(
        water: 'Keep consistently damp',
        sunlight: 'Partial shade / Full sun',
        soil: 'Moist but well-draining',
        temperature: '13°C - 21°C',
        fertilizer: 'Light liquid feed in spring',
      ),
      growthSteps: [
        'Plant in a confined container to prevent aggressive garden takeover.',
        'Harvest sprigs frequently to prevent flowering.',
        'Trim back stems to the ground in late autumn.',
        'Divide roots every few years to keep the plant vigorous.'
      ],
    ),
    PlantModel(
      id: 'p8',
      name: 'Snake Plant',
      scientificName: 'Sansevieria trifasciata',
      description: 'Striking upright succulent famous for its extreme hardiness, low-light tolerance, and air-purifying qualities.',
      imageUrl: 'assets/snake_plant.png',
      careRequirements: CareRequirements(
        water: 'Every 2-4 weeks',
        sunlight: 'Any light condition',
        soil: 'Sand/Cactus mix',
        temperature: '15°C - 35°C',
        fertilizer: 'Once during summer',
      ),
      growthSteps: [
        'Plant in a shallow, wide pot as roots spread out.',
        'Do not overwater; allow soil to bone-dry between waterings.',
        'Wipe the tall sword-like leaves clean periodically.',
        'Propagate via leaf cuttings or root division.'
      ],
    ),
    PlantModel(
      id: 'p9',
      name: 'Cactus',
      scientificName: 'Cactaceae',
      description: 'Desert-dwelling succulents adapted to extreme drought, storing massive amounts of water in their modified stems.',
      imageUrl: 'assets/cactus.png',
      careRequirements: CareRequirements(
        water: 'Once a month',
        sunlight: 'Direct Full Sun',
        soil: 'Gritty, fast-draining',
        temperature: 'Above 18°C',
        fertilizer: 'Low-nitrogen feed in summer',
      ),
      growthSteps: [
        'Select a pot that is barely wider than the cactus base.',
        'Provide the brightest, sunniest window available.',
        'Stop watering completely during deep winter hibernation.',
        'Handle with thick gloves when repotting.'
      ],
    ),
    PlantModel(
      id: 'p10',
      name: 'Lavender',
      scientificName: 'Lavandula',
      description: 'A Mediterranean herb famous for its unmistakable fragrance, beautiful purple flower spikes, and calming properties.',
      imageUrl: 'assets/lavender.png',
      careRequirements: CareRequirements(
        water: 'Only when dry',
        sunlight: 'Full Sun',
        soil: 'Alkaline, sandy/rocky',
        temperature: '20°C - 30°C',
        fertilizer: 'Rarely needed',
      ),
      growthSteps: [
        'Ensure excellent drainage; it hates wet feet.',
        'Leave plenty of space between plants for air circulation.',
        'Prune back one-third of the plant after summer blooms fade.',
        'Harvest flowers just as they begin to open for maximum scent.'
      ],
    ),
  ];
}

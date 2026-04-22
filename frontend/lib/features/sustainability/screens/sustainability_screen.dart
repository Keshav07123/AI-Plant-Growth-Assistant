// lib/features/sustainability/screens/sustainability_screen.dart
import 'package:flutter/material.dart';

class SustainabilityScreen extends StatelessWidget {
  const SustainabilityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sustainability Guide 🌍', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: TabBar(
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(text: 'Plastic Bottle Pots'),
              Tab(text: 'Homemade Manure'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PlasticPotsGuide(),
            _CompostGuide(),
          ],
        ),
      ),
    );
  }
}

class _PlasticPotsGuide extends StatefulWidget {
  const _PlasticPotsGuide({Key? key}) : super(key: key);

  @override
  State<_PlasticPotsGuide> createState() => _PlasticPotsGuideState();
}

class _PlasticPotsGuideState extends State<_PlasticPotsGuide> {
  final List<bool> _stepsCompleted = [true, false, false, false];

  int get _completedCount => _stepsCompleted.where((element) => element).length;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Upcycle Plastic Bottles', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Turn waste into beautiful planters.', style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Icon(Icons.recycling, size: 50, color: Theme.of(context).colorScheme.primary),
            ],
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: _completedCount / 4,
            backgroundColor: Colors.grey.withOpacity(0.3),
            color: Colors.green,
          ),
          const SizedBox(height: 10),
          Text('$_completedCount of 4 steps completed', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(height: 24),
          
          _buildStepCard(
            index: 0,
            title: 'Clean & Cut ✂️',
            description: 'Wash a 2-liter bottle and cut it in half.',
          ),
          _buildStepCard(
            index: 1,
            title: 'Drainage Holes 🕳️',
            description: 'Poke 4-5 small holes in the bottom half.',
          ),
          _buildStepCard(
            index: 2,
            title: 'Add Soil & Seeds 🌱',
            description: 'Fill with soil mix and plant your seeds or cuttings.',
          ),
          _buildStepCard(
            index: 3,
            title: 'Decorate (Optional) 🎨',
            description: 'Paint the outside to protect roots and look stylish!',
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStepCard({required int index, required String title, required String description}) {
    bool isDone = _stepsCompleted[index];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: InkWell(
          onTap: () => setState(() => _stepsCompleted[index] = !_stepsCompleted[index]),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone ? Colors.green : Colors.transparent,
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: isDone ? const Icon(Icons.check, size: 20, color: Colors.white) : null,
          ),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, decoration: isDone ? TextDecoration.lineThrough : null)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(description),
        ),
      ),
    );
  }
}

class _CompostGuide extends StatefulWidget {
  const _CompostGuide({Key? key}) : super(key: key);

  @override
  State<_CompostGuide> createState() => _CompostGuideState();
}

class _CompostGuideState extends State<_CompostGuide> {
  final List<bool> _stepsCompleted = [true, false, false, false, false];

  int get _completedCount => _stepsCompleted.where((element) => element).length;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Make Your Own Compost', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Rich nutrients from kitchen waste.', style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Icon(Icons.compost, size: 50, color: Theme.of(context).colorScheme.primary),
            ],
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: _completedCount / 5,
            backgroundColor: Colors.grey.withOpacity(0.3),
            color: Colors.green,
          ),
          const SizedBox(height: 10),
          Text('$_completedCount of 5 steps completed', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(height: 24),
          
          _buildStepCard(
            index: 0,
            title: 'Get a Container 🪣',
            description: 'Find a plastic bin and drill holes in the bottom and sides.',
          ),
          _buildStepCard(
            index: 1,
            title: 'Brown & Green Waste 🍂',
            description: 'Add dry leaves (brown) and vegetable scraps (green) in layers.',
          ),
          _buildStepCard(
            index: 2,
            title: 'Add Soil 🌱',
            description: 'Sprinkle soil to introduce microorganisms.',
          ),
          _buildStepCard(
            index: 3,
            title: 'Water It 💧',
            description: 'Keep slightly moist like a damp sponge.',
          ),
          _buildStepCard(
            index: 4,
            title: 'Turn & Wait ⏳',
            description: 'Turn weekly. Ready in 2-3 months!',
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStepCard({required int index, required String title, required String description}) {
    bool isDone = _stepsCompleted[index];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: InkWell(
          onTap: () => setState(() => _stepsCompleted[index] = !_stepsCompleted[index]),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone ? Colors.green : Colors.transparent,
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: isDone ? const Icon(Icons.check, size: 20, color: Colors.white) : null,
          ),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, decoration: isDone ? TextDecoration.lineThrough : null)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(description),
        ),
      ),
    );
  }
}

// lib/features/tasks/screens/grow_flow_screen.dart
import 'package:flutter/material.dart';
import '../../../services/task_ai_service.dart';

class GrowFlowScreen extends StatefulWidget {
  const GrowFlowScreen({Key? key}) : super(key: key);

  @override
  State<GrowFlowScreen> createState() => _GrowFlowScreenState();
}

class _GrowFlowScreenState extends State<GrowFlowScreen> {
  int _currentStep = 0;
  final TaskAiService _taskAiService = TaskAiService();
  final TextEditingController _searchController = TextEditingController();

  List<String> _plants = [];
  String _plantSearchQuery = '';
  String? _selectedPlant;

  final List<String> _goals = ['Grow from seed', 'Maintain plant', 'Improve growth'];
  String _selectedGoal = 'Grow from seed';

  bool _isSubmitted = false;
  bool _isLoading = false;
  bool _isPlantLoading = true;
  String? _error;
  Map<String, dynamic>? _growthData;

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPlants() async {
    setState(() {
      _isPlantLoading = true;
      _error = null;
    });
    try {
      final plants = await _taskAiService.fetchAllPlants();
      if (!mounted) return;
      setState(() {
        _plants = plants;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isPlantLoading = false;
      });
    }
  }

  List<String> get _filteredPlants {
    if (_plantSearchQuery.trim().isEmpty) return _plants;
    final query = _plantSearchQuery.toLowerCase();
    return _plants.where((p) => p.toLowerCase().contains(query)).toList();
  }

  List<String> get _suggestedPlants {
    if (_plantSearchQuery.trim().isEmpty) return [];
    return _filteredPlants.take(6).toList();
  }

  Future<void> _submitData() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _isSubmitted = false;
    });
    try {
      final response = await _taskAiService.fetchGrowthPlan(_selectedPlant!);
      if (!mounted) return;
      setState(() {
        _growthData = (response['data'] as Map<String, dynamic>?) ?? {};
        _isSubmitted = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grow a Plant')),
      body: _isSubmitted
          ? _buildResultView()
          : Stepper(
              type: StepperType.vertical,
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep < 2) {
                  if (_currentStep == 0 && _selectedPlant == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a plant.')));
                    return;
                  }
                  setState(() => _currentStep += 1);
                } else {
                  _submitData();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep -= 1);
                } else {
                  Navigator.pop(context);
                }
              },
              steps: [
                Step(
                  title: const Text('Plant Selection'),
                  content: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search plant by name',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _plantSearchQuery = value;
                            final exactMatch = _plants.where(
                              (plant) => plant.toLowerCase() == value.trim().toLowerCase(),
                            );
                            _selectedPlant = exactMatch.isNotEmpty ? exactMatch.first : null;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      if (!_isPlantLoading && _suggestedPlants.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Column(
                            children: _suggestedPlants.map((plant) {
                              return ListTile(
                                dense: true,
                                title: Text(plant),
                                leading: const Icon(Icons.spa_outlined),
                                trailing: _selectedPlant == plant
                                    ? const Icon(Icons.check_circle, color: Colors.green)
                                    : null,
                                onTap: () {
                                  setState(() {
                                    _selectedPlant = plant;
                                    _plantSearchQuery = plant;
                                    _searchController.text = plant;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (_isPlantLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Select plant',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedPlant,
                          items: _filteredPlants.map((plant) {
                            return DropdownMenuItem(
                              value: plant,
                              child: Text(plant),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedPlant = val;
                            });
                          },
                        ),
                    ],
                  ),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0 ? StepState.complete : StepState.editing,
                ),
                Step(
                  title: const Text('Goal'),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('What do you want to achieve?', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      ..._goals.map((goal) {
                        return RadioListTile<String>(
                          title: Text(goal),
                          value: goal,
                          groupValue: _selectedGoal,
                          onChanged: (val) {
                            setState(() {
                              _selectedGoal = val!;
                            });
                          },
                        );
                      }).toList(),
                    ],
                  ),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1 ? StepState.complete : StepState.editing,
                ),
                Step(
                  title: const Text('Output Generation'),
                  content: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Text(_error ?? 'Generate the step-by-step guidance based on your inputs.'),
                  isActive: _currentStep >= 2,
                  state: StepState.editing,
                ),
              ],
            ),
    );
  }

  Widget _buildResultView() {
    final plan = (_growthData?['growth_plan'] as List?)?.cast<dynamic>() ?? [];
    final tips = (_growthData?['tips'] as List?)?.cast<dynamic>() ?? [];

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Growth Plan: ${_growthData?['common_name'] ?? _selectedPlant}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text('Goal: $_selectedGoal', style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
          const Divider(height: 30),
          Expanded(
            child: ListView(
              children: [
                if (plan.isEmpty) _buildTimelineTile('Info', 'No growth plan found for this plant.'),
                ...plan.map((step) {
                  if (step is Map) {
                    return _buildTimelineTile(
                      step['stage']?.toString() ?? 'Stage',
                      step['task']?.toString() ?? '',
                    );
                  }
                  return _buildTimelineTile('Stage', step.toString());
                }),
                if (tips.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text('Quick Tips', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...tips.map((tip) => Text('- ${tip.toString()}')),
                ],
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTimelineTile(String time, String action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(time, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(action, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}

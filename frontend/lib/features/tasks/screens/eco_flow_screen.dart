// lib/features/tasks/screens/eco_flow_screen.dart
import 'package:flutter/material.dart';
import '../../../services/task_ai_service.dart';

class EcoFlowScreen extends StatefulWidget {
  const EcoFlowScreen({Key? key}) : super(key: key);

  @override
  State<EcoFlowScreen> createState() => _EcoFlowScreenState();
}

class _EcoFlowScreenState extends State<EcoFlowScreen> {
  int _currentStep = 0;
  final TaskAiService _taskAiService = TaskAiService();

  final List<String> _wasteTypes = ['Plastic bottle', 'Kitchen waste', 'Old bucket', 'Tin cans'];
  String _selectedWaste = 'Plastic bottle';

  bool _isSubmitted = false;
  bool _isLoading = false;
  String? _error;
  List<dynamic> _useCases = [];

  Future<void> _submitData() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _isSubmitted = false;
    });
    try {
      final response = await _taskAiService.fetchEcoTasks(_selectedWaste);
      final data = (response['data'] as Map<String, dynamic>?) ?? {};
      if (!mounted) return;
      setState(() {
        _useCases = (data['use_cases'] as List?)?.cast<dynamic>() ?? [];
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
      appBar: AppBar(title: const Text('Eco / Reuse Tips')),
      body: _isSubmitted
        ? _buildResultView()
        : Stepper(
            type: StepperType.vertical,
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep < 1) {
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
                title: const Text('Select Waste Type'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('What do you have available?', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    ..._wasteTypes.map((waste) {
                      return RadioListTile<String>(
                        title: Text(waste),
                        value: waste,
                        groupValue: _selectedWaste,
                        onChanged: (val) {
                          setState(() {
                            _selectedWaste = val!;
                          });
                        },
                      );
                    }).toList(),
                  ],
                ),
                isActive: _currentStep >= 0,
                state: _currentStep > 0 ? StepState.complete : StepState.editing,
              ),
              Step(
                title: const Text('Get Upcycling Plan'),
                content: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Text(_error ?? 'Submit to generate your upcycling guide.'),
                isActive: _currentStep >= 1,
                state: StepState.editing,
              ),
            ],
          ),
    );
  }

  Widget _buildResultView() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.recycling, color: Colors.green, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Text('Upcycling: $_selectedWaste', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: 30),
          Expanded(
            child: ListView(
              children: _getInstructionsForWaste(),
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

  List<Widget> _getInstructionsForWaste() {
    final List<String> instructions = [];
    for (final useCase in _useCases) {
      if (useCase is! Map) continue;
      final title = useCase['title']?.toString() ?? 'Use case';
      instructions.add(title);
      final steps = (useCase['steps'] as List?)?.cast<dynamic>() ?? [];
      for (final step in steps) {
        instructions.add(step.toString());
      }
    }
    if (instructions.isEmpty) {
      instructions.add('No eco tasks were found for this waste type.');
    }

    return instructions.map((step) => Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(step, style: const TextStyle(fontSize: 16))),
        ],
      ),
    )).toList();
  }
}

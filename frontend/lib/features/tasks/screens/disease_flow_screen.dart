// lib/features/tasks/screens/disease_flow_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../services/task_ai_service.dart';

class DiseaseFlowScreen extends StatefulWidget {
  final String? imagePath;
  const DiseaseFlowScreen({Key? key, this.imagePath}) : super(key: key);

  @override
  State<DiseaseFlowScreen> createState() => _DiseaseFlowScreenState();
}

class _DiseaseFlowScreenState extends State<DiseaseFlowScreen> {
  int _currentStep = 0;
  final TaskAiService _taskAiService = TaskAiService();
  
  final Map<String, bool> _symptoms = {
    'Yellow leaves': false,
    'Brown spots': false,
    'White powder': false,
    'Holes in leaves': false,
    'Wilting': false,
  };

  String _severity = 'Mild';
  bool _isLoading = false;
  Map<String, dynamic>? _result;
  String? _error;

  Future<void> _submitData() async {
    final selectedSymptoms = _symptoms.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key.toLowerCase())
        .toList();

    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });

    try {
      if (widget.imagePath == null) {
        throw Exception('Image is required for model-based disease diagnosis.');
      }
      final response = await _taskAiService.fetchImageDiagnosis(widget.imagePath!);
      if (!mounted) return;
      setState(() {
        _result = response;
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
      appBar: AppBar(title: const Text('Check Disease')),
      body: _result != null ? _buildResultView() : Stepper(
            type: StepperType.vertical,
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep < 3) {
                if (_currentStep == 1 && !_symptoms.values.any((v) => v)) {
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text('Please select at least one symptom.'))
                   );
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
                title: const Text('Image Upload'),
                content: widget.imagePath != null
                  ? Image.file(File(widget.imagePath!), height: 150)
                  : const Text('No image provided.'),
                isActive: _currentStep >= 0,
                state: _currentStep > 0 ? StepState.complete : StepState.editing,
              ),
              Step(
                title: const Text('Symptom Selection (Mandatory)'),
                content: Column(
                  children: _symptoms.keys.map((symptom) {
                    return CheckboxListTile(
                      title: Text(symptom),
                      value: _symptoms[symptom],
                      onChanged: (val) {
                        setState(() {
                          _symptoms[symptom] = val ?? false;
                        });
                      },
                    );
                  }).toList(),
                ),
                isActive: _currentStep >= 1,
                state: _currentStep > 1 ? StepState.complete : StepState.editing,
              ),
              Step(
                title: const Text('Severity'),
                content: Column(
                  children: ['Mild', 'Moderate', 'Severe'].map((sev) {
                    return RadioListTile<String>(
                      title: Text(sev),
                      value: sev,
                      groupValue: _severity,
                      onChanged: (val) {
                        setState(() {
                          _severity = val!;
                        });
                      },
                    );
                  }).toList(),
                ),
                isActive: _currentStep >= 2,
                state: _currentStep > 2 ? StepState.complete : StepState.editing,
              ),
              Step(
                title: const Text('Submit'),
                content: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Text(_error ?? 'Review your inputs and submit to diagnose the disease.'),
                isActive: _currentStep >= 3,
                state: StepState.editing,
              )
            ],
          ),
    );
  }

  Widget _buildResultView() {
    final model = _result ?? {};
    final plantName = (model['plant_name'] ?? 'Unknown').toString();
    final diseaseName = (model['disease_name'] ?? 'Unknown').toString();
    final commonName = (model['disease_common_name'] ?? diseaseName).toString();
    final confidence = (model['confidence_percent'] ?? 0).toString();
    final healthScore = (model['plant_health_score'] ?? 0).toString();
    final healthStatus = (model['health_status'] ?? 'Unknown').toString();
    final remedies = (model['remedies'] as List?)?.cast<dynamic>() ?? [];
    final prevention = (model['prevention'] as List?)?.cast<dynamic>() ?? [];
    final remediesToShow = remedies.isEmpty
        ? const <dynamic>[
            'No specific remedy found in local database. Isolate the plant, remove highly affected leaves, and monitor daily.'
          ]
        : remedies;
    final preventionToShow = prevention.isEmpty
        ? const <dynamic>[
            'Keep good airflow, avoid overwatering, and water near roots instead of leaves.'
          ]
        : prevention;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF111827)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.verified,
                          color: Colors.greenAccent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Model Diagnosis Result',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _infoChip('Plant Name', plantName),
                    const SizedBox(height: 8),
                    _infoChip('Disease Name', diseaseName),
                    const SizedBox(height: 8),
                    _infoChip('Common Name', commonName),
                    const SizedBox(height: 8),
                    _infoChip('Confidence (%)', confidence),
                    const SizedBox(height: 8),
                    _infoChip('Health Score', healthScore),
                    const SizedBox(height: 8),
                    _infoChip('Health Status', healthStatus),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView(
                  children: [
                    _sectionCard('Remedies', remediesToShow, Icons.healing),
                    const SizedBox(height: 12),
                    _sectionCard('Prevention', preventionToShow, Icons.shield_outlined),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.white70, fontSize: 14),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w700)),
            TextSpan(text: value, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(String title, List<dynamic> items, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.lightGreenAccent),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: Colors.white)),
                  Expanded(
                    child: Text(
                      item.toString(),
                      style: const TextStyle(color: Colors.white70, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}

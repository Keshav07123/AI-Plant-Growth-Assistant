// lib/features/tasks/models/task_payload.dart
import 'dart:convert';

class TaskPayload {
  final String task;
  final String? imagePath;
  final List<String>? symptoms;
  final String? severity;
  final String? plantName;
  final String? goal;
  final String? wasteType;
  final String? extraDetails;

  TaskPayload({
    required this.task,
    this.imagePath,
    this.symptoms,
    this.severity,
    this.plantName,
    this.goal,
    this.wasteType,
    this.extraDetails,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'task': task,
    };
    if (imagePath != null) data['image'] = imagePath;
    if (symptoms != null) data['symptoms'] = symptoms;
    if (severity != null) data['severity'] = severity;
    if (plantName != null) data['plant_name'] = plantName;
    if (goal != null) data['goal'] = goal;
    if (wasteType != null) data['waste_type'] = wasteType;
    if (extraDetails != null && extraDetails!.isNotEmpty) data['extra_details'] = extraDetails;
    return data;
  }

  String toJsonString() => json.encode(toJson());
}

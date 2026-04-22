// lib/models/scan_result_model.dart
import 'plant_model.dart';

class ScanResultModel {
  final String scanId;
  final DateTime scannedAt;
  final String imagePath;
  final PlantModel? matchedPlant;
  final double confidencePercent;
  final int plantHealthScore; // The WOW Feature: 0-100%
  final String healthStatus; 

  ScanResultModel({
    required this.scanId,
    required this.scannedAt,
    required this.imagePath,
    this.matchedPlant,
    required this.confidencePercent,
    required this.plantHealthScore,
    required this.healthStatus,
  });
}

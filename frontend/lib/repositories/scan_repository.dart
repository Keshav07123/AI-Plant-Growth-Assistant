// lib/repositories/scan_repository.dart
import '../models/scan_result_model.dart';
import '../services/mock_ai_service.dart';

// Decouples AI backend connection from UI
class ScanRepository {
  final MockAiService _apiService;

  ScanRepository({MockAiService? apiService})
      : _apiService = apiService ?? MockAiService();

  Future<ScanResultModel> analyzePlant(String imagePath, {required String task}) async {
    try {
      return await _apiService.analyzePlantImage(imagePath, task: task);
    } catch (e) {
      throw Exception('Failed to communicate with AI Backend. $e');
    }
  }
}

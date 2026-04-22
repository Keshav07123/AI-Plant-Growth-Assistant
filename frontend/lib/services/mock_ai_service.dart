import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../core/constants/api_constants.dart';
import '../models/scan_result_model.dart';
import '../models/plant_model.dart';

class MockAiService {
  /// Android often omits MIME on multipart parts; set explicitly so servers accept the upload.
  static MediaType _mediaTypeForPath(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('image', 'jpeg');
    }
  }

  static String _basename(String path) {
    final i = path.replaceAll('\\', '/').lastIndexOf('/');
    return i >= 0 ? path.substring(i + 1) : path;
  }

  Future<ScanResultModel> analyzePlantImage(String imagePath, {required String task}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.predictPath}?task=$task');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        await http.MultipartFile.fromPath(
          'image',
          imagePath,
          filename: _basename(imagePath),
          contentType: _mediaTypeForPath(imagePath),
        ),
      );

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 180),
      onTimeout: () => throw TimeoutException(
        'Backend did not respond in time. Start the server and check adb reverse.',
      ),
    );
    final responseBody = await streamedResponse.stream.bytesToString().timeout(
      const Duration(seconds: 180),
      onTimeout: () => throw TimeoutException('Slow response while reading result.'),
    );
    if (streamedResponse.statusCode != 200) {
      throw Exception('Backend error: ${streamedResponse.statusCode} $responseBody');
    }

    final Map<String, dynamic> data = jsonDecode(responseBody) as Map<String, dynamic>;
    final String plantName = (data['plant_name'] ?? 'Unknown').toString();
    final String diseaseName = (data['disease_name'] ?? 'Unknown').toString();
    final double confidencePercent = ((data['confidence_percent'] ?? 0) as num).toDouble();
    final int healthScore = ((data['plant_health_score'] ?? 0) as num).toInt();
    final String healthStatus = (data['health_status'] ?? 'Unknown').toString();
    String? scientificName;
    String? wikiUrl;
    final inatRaw = data['inaturalist'];
    if (inatRaw is Map<String, dynamic>) {
      scientificName = inatRaw['name']?.toString();
      wikiUrl = inatRaw['wikipedia_url']?.toString();
    }

    return ScanResultModel(
      scanId: DateTime.now().millisecondsSinceEpoch.toString(),
      scannedAt: DateTime.now(),
      imagePath: imagePath,
      confidencePercent: confidencePercent,
      plantHealthScore: healthScore,
      healthStatus: healthStatus,
      matchedPlant: PlantModel(
        id: plantName.toLowerCase().replaceAll(' ', '_'),
        name: plantName,
        scientificName: scientificName ?? plantName,
        description: diseaseName == 'healthy'
            ? 'No visible disease signs were detected by the model.'
            : 'Predicted issue: $diseaseName',
        imageUrl: wikiUrl ?? '',
        careRequirements: CareRequirements(
          water: diseaseName == 'healthy' ? 'Regular watering as per species need' : 'Avoid overwatering; monitor soil moisture',
          sunlight: 'Adequate sunlight based on species',
          soil: 'Well-draining and nutrient-rich',
          temperature: '18°C - 30°C',
          fertilizer: 'Balanced fertilizer schedule',
        ),
        growthSteps: [
          'Inspect leaves daily for progression.',
          'Remove heavily affected leaves.',
          'Keep tools sanitized to avoid spread.',
          'Follow a species-specific care routine.',
        ],
      ),
    );
  }
}

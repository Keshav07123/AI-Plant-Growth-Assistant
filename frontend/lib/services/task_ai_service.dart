import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../core/constants/api_constants.dart';

class TaskAiService {
  static const Duration _requestTimeout = Duration(seconds: 25);

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

  Future<Map<String, dynamic>> fetchImageDiagnosis(String imagePath) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.predictPath}?task=disease');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        await http.MultipartFile.fromPath(
          'image',
          imagePath,
          filename: _basename(imagePath),
          contentType: _mediaTypeForPath(imagePath),
        ),
      );
    final streamedResponse = await request.send().timeout(_requestTimeout);
    final responseBody = await streamedResponse.stream.bytesToString().timeout(_requestTimeout);
    if (streamedResponse.statusCode != 200) {
      throw Exception('Backend error ${streamedResponse.statusCode}: $responseBody');
    }
    final decoded = jsonDecode(responseBody);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid response format from backend.');
    }
    return decoded;
  }

  Future<Map<String, dynamic>> fetchDiseaseMatch(List<String> symptoms, {String? plantName}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.agentPath}');
    final payload = <String, dynamic>{'task': 'disease', 'symptoms': symptoms};
    if (plantName != null && plantName.trim().isNotEmpty) {
      payload['plant'] = plantName;
    }
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        )
        .timeout(_requestTimeout);
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> fetchGrowthPlan(String plant) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.agentPath}');
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'task': 'growth', 'plant': plant}),
        )
        .timeout(_requestTimeout);
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> fetchEcoTasks(String wasteType) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.agentPath}');
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'task': 'eco', 'waste': wasteType}),
        )
        .timeout(_requestTimeout);
    return _parseResponse(response);
  }

  Future<List<String>> fetchAllPlants() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/plants');
    final response = await http.get(uri).timeout(_requestTimeout);
    final parsed = _parseResponse(response);
    final data = (parsed['data'] as Map<String, dynamic>?) ?? {};
    final plants = (data['plants'] as List?)?.cast<dynamic>() ?? [];
    return plants.map((e) => e.toString()).toList();
  }

  Future<List<Map<String, String>>> fetchAllPlantEntries() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/plants');
    final response = await http.get(uri).timeout(_requestTimeout);
    final parsed = _parseResponse(response);
    final data = (parsed['data'] as Map<String, dynamic>?) ?? {};
    final entries = (data['plant_entries'] as List?)?.cast<dynamic>() ?? [];
    return entries
        .whereType<Map>()
        .map((entry) => {
              'name': (entry['name'] ?? '').toString(),
              'scientific_name': (entry['scientific_name'] ?? '').toString(),
            })
        .where((entry) => entry['name']!.trim().isNotEmpty)
        .toList();
  }

  Map<String, dynamic> _parseResponse(http.Response response) {
    final body = response.body.isEmpty ? '{}' : response.body;
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid response format from backend.');
    }
    if (response.statusCode != 200) {
      throw Exception('Backend error ${response.statusCode}: ${response.body}');
    }
    final status = decoded['status']?.toString();
    if (status == 'error') {
      final message = decoded['message']?.toString() ?? 'Unknown backend error.';
      throw Exception(message);
    }
    return decoded;
  }
}

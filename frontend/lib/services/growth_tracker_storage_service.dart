import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/growth_track_model.dart';

class GrowthTrackerStorageService {
  static const String _trackerKey = 'growth_tracks';

  Future<List<GrowthTrackModel>> loadTracks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_trackerKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(GrowthTrackModel.fromMap)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTracks(List<GrowthTrackModel> tracks) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(tracks.map((e) => e.toMap()).toList());
    await prefs.setString(_trackerKey, encoded);
  }
}

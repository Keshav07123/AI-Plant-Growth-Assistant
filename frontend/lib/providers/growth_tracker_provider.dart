import 'dart:async';

import 'package:flutter/material.dart';

import '../models/growth_track_model.dart';
import '../services/growth_tracker_storage_service.dart';

class GrowthTrackerProvider with ChangeNotifier {
  final GrowthTrackerStorageService _storageService;
  Timer? _ticker;

  GrowthTrackerProvider({GrowthTrackerStorageService? storageService})
      : _storageService = storageService ?? GrowthTrackerStorageService() {
    _initialize();
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  DateTime _now = DateTime.now();
  DateTime get now => _now;

  List<GrowthTrackModel> _tracks = [];
  List<GrowthTrackModel> get tracks => List.unmodifiable(_tracks);

  Future<void> _initialize() async {
    _tracks = await _storageService.loadTracks();
    _isLoading = false;
    notifyListeners();
    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _now = DateTime.now();
      notifyListeners();
    });
  }

  Future<void> addTrack({
    required String plantName,
    required DateTime startedAt,
    required int expectedGrowthDays,
  }) async {
    final id = '${plantName}_${DateTime.now().millisecondsSinceEpoch}';
    _tracks = [
      ..._tracks,
      GrowthTrackModel(
        id: id,
        plantName: plantName,
        startedAt: startedAt,
        expectedGrowthDays: expectedGrowthDays,
      ),
    ];
    await _storageService.saveTracks(_tracks);
    notifyListeners();
  }

  Future<void> markWatered(String id) async {
    _tracks = _tracks
        .map(
          (t) => t.id == id ? t.copyWith(lastWateredAt: DateTime.now()) : t,
        )
        .toList();
    await _storageService.saveTracks(_tracks);
    notifyListeners();
  }

  Future<void> removeTrack(String id) async {
    _tracks = _tracks.where((t) => t.id != id).toList();
    await _storageService.saveTracks(_tracks);
    notifyListeners();
  }

  Future<void> addProgressPhoto({
    required String trackId,
    required String imagePath,
  }) async {
    if (imagePath.trim().isEmpty) {
      return;
    }
    _tracks = _tracks.map((track) {
      if (track.id != trackId) {
        return track;
      }
      return track.copyWith(
        progressPhotos: [
          ...track.progressPhotos,
          GrowthPhotoLog(
            imagePath: imagePath,
            capturedAt: DateTime.now(),
          ),
        ],
      );
    }).toList();
    await _storageService.saveTracks(_tracks);
    notifyListeners();
  }

  int suggestedDurationDays(String plantName) {
    final normalized = plantName.trim().toLowerCase();
    const durations = <String, int>{
      'apple': 140,
      'blueberry': 120,
      'cherry': 120,
      'corn (maize)': 100,
      'grape': 110,
      'orange (citrus)': 160,
      'peach': 130,
      'bell pepper': 90,
      'potato': 100,
      'raspberry': 120,
      'soybean': 95,
      'squash': 70,
      'strawberry': 90,
      'tomato': 85,
    };
    return durations[normalized] ?? 90;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

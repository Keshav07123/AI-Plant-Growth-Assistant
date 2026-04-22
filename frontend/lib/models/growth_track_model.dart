import 'dart:convert';

class GrowthPhotoLog {
  final String imagePath;
  final DateTime capturedAt;

  GrowthPhotoLog({
    required this.imagePath,
    required this.capturedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'imagePath': imagePath,
      'capturedAt': capturedAt.toIso8601String(),
    };
  }

  factory GrowthPhotoLog.fromMap(Map<String, dynamic> map) {
    return GrowthPhotoLog(
      imagePath: map['imagePath']?.toString() ?? '',
      capturedAt: DateTime.tryParse(map['capturedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class GrowthTrackModel {
  final String id;
  final String plantName;
  final DateTime startedAt;
  final int expectedGrowthDays;
  final DateTime? lastWateredAt;
  final List<GrowthPhotoLog> progressPhotos;

  GrowthTrackModel({
    required this.id,
    required this.plantName,
    required this.startedAt,
    required this.expectedGrowthDays,
    this.lastWateredAt,
    this.progressPhotos = const [],
  });

  GrowthTrackModel copyWith({
    String? id,
    String? plantName,
    DateTime? startedAt,
    int? expectedGrowthDays,
    DateTime? lastWateredAt,
    List<GrowthPhotoLog>? progressPhotos,
    bool clearLastWateredAt = false,
  }) {
    return GrowthTrackModel(
      id: id ?? this.id,
      plantName: plantName ?? this.plantName,
      startedAt: startedAt ?? this.startedAt,
      expectedGrowthDays: expectedGrowthDays ?? this.expectedGrowthDays,
      lastWateredAt: clearLastWateredAt ? null : (lastWateredAt ?? this.lastWateredAt),
      progressPhotos: progressPhotos ?? this.progressPhotos,
    );
  }

  double progress(DateTime now) {
    final totalSeconds = expectedGrowthDays * 24 * 60 * 60;
    if (totalSeconds <= 0) {
      return 1;
    }
    final elapsedSeconds = now.difference(startedAt).inSeconds;
    final raw = elapsedSeconds / totalSeconds;
    if (raw < 0) {
      return 0;
    }
    if (raw > 1) {
      return 1;
    }
    return raw;
  }

  String stage(DateTime now) {
    final p = progress(now);
    if (p < 0.2) {
      return 'Seedling';
    }
    if (p < 0.6) {
      return 'Vegetative';
    }
    if (p < 0.9) {
      return 'Flowering';
    }
    return 'Harvest';
  }

  Duration remaining(DateTime now) {
    final target = startedAt.add(Duration(days: expectedGrowthDays));
    final diff = target.difference(now);
    return diff.isNegative ? Duration.zero : diff;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plantName': plantName,
      'startedAt': startedAt.toIso8601String(),
      'expectedGrowthDays': expectedGrowthDays,
      'lastWateredAt': lastWateredAt?.toIso8601String(),
      'progressPhotos': progressPhotos.map((p) => p.toMap()).toList(),
    };
  }

  factory GrowthTrackModel.fromMap(Map<String, dynamic> map) {
    return GrowthTrackModel(
      id: map['id']?.toString() ?? '',
      plantName: map['plantName']?.toString() ?? 'Plant',
      startedAt: DateTime.tryParse(map['startedAt']?.toString() ?? '') ?? DateTime.now(),
      expectedGrowthDays: (map['expectedGrowthDays'] as num?)?.toInt() ?? 60,
      lastWateredAt: map['lastWateredAt'] == null
          ? null
          : DateTime.tryParse(map['lastWateredAt'].toString()),
      progressPhotos: (map['progressPhotos'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(GrowthPhotoLog.fromMap)
              .where((photo) => photo.imagePath.trim().isNotEmpty)
              .toList() ??
          const [],
    );
  }

  String toJson() => jsonEncode(toMap());

  factory GrowthTrackModel.fromJson(String source) =>
      GrowthTrackModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

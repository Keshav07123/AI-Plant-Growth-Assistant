import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:math' as math;

import '../../../models/growth_track_model.dart';
import '../../../providers/growth_tracker_provider.dart';
import '../../../providers/plant_provider.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  double _estimatedGrowthPercent(GrowthTrackModel track, DateTime now) {
    final timeProgress = track.progress(now).clamp(0.0, 1.0);
    final elapsedDays = now.difference(track.startedAt).inDays;
    final expectedPhotoCount = math.max(1, (elapsedDays / 5).ceil());
    final photoCount = track.progressPhotos.length;
    final photoProgress = (photoCount / expectedPhotoCount).clamp(0.0, 1.0);

    // Blend timeline progress with photo consistency so estimate responds to uploads.
    final estimated = (timeProgress * 0.8) + (photoProgress * 0.2);
    return estimated.clamp(0.0, 1.0);
  }

  int _estimatedRemainingDays(GrowthTrackModel track, DateTime now) {
    final estimatedProgress = _estimatedGrowthPercent(track, now);
    final rawDays = ((1 - estimatedProgress) * track.expectedGrowthDays).ceil();
    return rawDays < 0 ? 0 : rawDays;
  }

  Future<void> _addProgressPhoto(BuildContext context, String trackId) async {
    final trackerProvider = Provider.of<GrowthTrackerProvider>(context, listen: false);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take photo'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
    if (source == null) {
      return;
    }

    final file = await _imagePicker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (file == null) {
      return;
    }

    await trackerProvider.addProgressPhoto(trackId: trackId, imagePath: file.path);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Progress photo added.')),
    );
  }

  Future<void> _showAddPlantDialog(BuildContext context) async {
    final plantProvider = Provider.of<PlantProvider>(context, listen: false);
    final trackerProvider = Provider.of<GrowthTrackerProvider>(context, listen: false);
    if (plantProvider.plants.isEmpty) {
      return;
    }

    String selectedPlant = plantProvider.plants.first.name;
    DateTime startedAt = DateTime.now();
    int growthDays = trackerProvider.suggestedDurationDays(selectedPlant);

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocalState) {
            return AlertDialog(
              title: const Text('Add Plant to Tracker'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedPlant,
                      decoration: const InputDecoration(
                        labelText: 'Plant',
                        border: OutlineInputBorder(),
                      ),
                      items: plantProvider.plants
                          .map(
                            (p) => DropdownMenuItem<String>(
                              value: p.name,
                              child: Text(p.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setLocalState(() {
                          selectedPlant = value;
                          growthDays = trackerProvider.suggestedDurationDays(value);
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Started: ${DateFormat('dd MMM yyyy').format(startedAt)}',
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: startedAt,
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setLocalState(() {
                                startedAt = DateTime(
                                  picked.year,
                                  picked.month,
                                  picked.day,
                                  startedAt.hour,
                                  startedAt.minute,
                                  startedAt.second,
                                );
                              });
                            }
                          },
                          child: const Text('Pick date'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: growthDays.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Expected growth days',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        final parsed = int.tryParse(value);
                        if (parsed != null && parsed > 0) {
                          growthDays = parsed;
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await trackerProvider.addTrack(
                      plantName: selectedPlant,
                      startedAt: startedAt,
                      expectedGrowthDays: growthDays,
                    );
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final trackerProvider = Provider.of<GrowthTrackerProvider>(context);
    final now = trackerProvider.now;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Growth Tracker'),
        actions: [
          IconButton(
            onPressed: () => _showAddPlantDialog(context),
            icon: const Icon(Icons.add),
            tooltip: 'Track new plant',
          ),
        ],
      ),
      body: trackerProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : trackerProvider.tracks.isEmpty
              ? _EmptyTrackerState(onAdd: () => _showAddPlantDialog(context))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: trackerProvider.tracks.length,
                  itemBuilder: (context, index) {
                    final track = trackerProvider.tracks[index];
                    final progress = track.progress(now);
                    final stage = track.stage(now);
                    final remaining = track.remaining(now);
                    final remainingLabel = _formatDuration(remaining);
                    final estimatedProgress = _estimatedGrowthPercent(track, now);
                    final estimatedRemainingDays = _estimatedRemainingDays(track, now);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    track.plantName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => trackerProvider.removeTrack(track.id),
                                  tooltip: 'Remove',
                                ),
                              ],
                            ),
                            Text(
                              'Started ${DateFormat('dd MMM yyyy').format(track.startedAt)}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 10),
                            LinearProgressIndicator(
                              value: progress,
                              minHeight: 10,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Stage: $stage',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text('${(progress * 100).toStringAsFixed(1)}%'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              remaining == Duration.zero
                                  ? 'Growth target reached'
                                  : 'Time remaining: $remainingLabel',
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.45),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Estimated growth: ${(estimatedProgress * 100).toStringAsFixed(1)}%',
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    estimatedRemainingDays == 0
                                        ? 'Estimated to be fully grown.'
                                        : 'Estimated $estimatedRemainingDays day(s) more to grow properly.',
                                    style: const TextStyle(color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => trackerProvider.markWatered(track.id),
                                  icon: const Icon(Icons.water_drop_outlined),
                                  label: const Text('Mark watered'),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    track.lastWateredAt == null
                                        ? 'Not watered yet'
                                        : 'Last watered ${DateFormat('dd MMM, hh:mm a').format(track.lastWateredAt!)}',
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _addProgressPhoto(context, track.id),
                                  icon: const Icon(Icons.add_a_photo_outlined),
                                  label: const Text('Add photo'),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${track.progressPhotos.length} photos',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            if (track.progressPhotos.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 90,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: track.progressPhotos.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                                  itemBuilder: (context, photoIndex) {
                                    final photo = track.progressPhotos[photoIndex];
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Stack(
                                        children: [
                                          Image.file(
                                            File(photo.imagePath),
                                            width: 90,
                                            height: 90,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              width: 90,
                                              height: 90,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                              alignment: Alignment.center,
                                              child: const Icon(Icons.broken_image_outlined),
                                            ),
                                          ),
                                          Positioned(
                                            left: 0,
                                            right: 0,
                                            bottom: 0,
                                            child: Container(
                                              color: Colors.black54,
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              child: Text(
                                                DateFormat('dd MMM').format(photo.capturedAt),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPlantDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Track plant'),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);

    if (days > 0) {
      return '${days}d ${hours}h';
    }
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${duration.inMinutes}m';
  }
}

class _EmptyTrackerState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyTrackerState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timeline,
              size: 68,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            const Text(
              'No plants tracked yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add a plant to start live, real-time growth progress tracking.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add first plant'),
            ),
          ],
        ),
      ),
    );
  }
}

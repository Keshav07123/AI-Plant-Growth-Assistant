import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/plant_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/plant_provider.dart';
import '../../plant_details/screens/details_screen.dart';
import 'more_plants_screen.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  static const int _initialVisibleCount = 6;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetails(BuildContext context, PlantModel plant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsScreen(plant: plant),
      ),
    );
  }

  Widget _imageFallback(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.local_florist,
        size: 48,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  /// Soft tint behind each card image (visible at edges / while loading).
  List<Color> _frameGradient(BuildContext context, int index) {
    final base = Theme.of(context).colorScheme.primary;
    final palettes = [
      [base.withOpacity(0.22), base.withOpacity(0.06)],
      [const Color(0xFF2E7D32).withOpacity(0.18), const Color(0xFF81C784).withOpacity(0.08)],
      [const Color(0xFF1565C0).withOpacity(0.18), const Color(0xFF64B5F6).withOpacity(0.08)],
      [const Color(0xFF6A1B9A).withOpacity(0.16), const Color(0xFFCE93D8).withOpacity(0.07)],
      [const Color(0xFFEF6C00).withOpacity(0.16), const Color(0xFFFFB74D).withOpacity(0.08)],
    ];
    return palettes[index % palettes.length];
  }

  Widget _plantPhoto(BuildContext context, String assetPath, int index) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _frameGradient(context, index),
            ),
          ),
        ),
        Image.asset(
          assetPath,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => _imageFallback(context),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.12),
                  Colors.transparent,
                  Colors.black.withOpacity(0.38),
                ],
                stops: const [0.0, 0.42, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final plantProvider = Provider.of<PlantProvider>(context);
    final user = authProvider.currentUser;
    final scheme = Theme.of(context).colorScheme;
    final allPlants = plantProvider.plants;
    final plantsWithAssets =
        allPlants.where((plant) => plant.imageUrl.trim().startsWith('assets/')).toList();
    final query = _searchQuery.trim().toLowerCase();
    final filteredPlants = query.isEmpty
        ? allPlants
        : allPlants.where((plant) {
            return plant.name.toLowerCase().contains(query) ||
                plant.scientificName.toLowerCase().contains(query);
          }).toList();
    final filteredPlantsWithAssets = filteredPlants
        .where((plant) => plant.imageUrl.trim().startsWith('assets/'))
        .toList();
    final homePlants = query.isEmpty
        ? plantsWithAssets.take(_initialVisibleCount).toList()
        : filteredPlantsWithAssets.take(_initialVisibleCount).toList();
    final suggestions = query.isEmpty ? <PlantModel>[] : filteredPlants.take(5).toList();
    final hasRemainingPlants = filteredPlants.length > homePlants.length;
    final remainingPlants = hasRemainingPlants
        ? filteredPlants.skip(homePlants.length).toList()
        : <PlantModel>[];

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
        title: Text(
          user != null ? 'Hey ${user.name} 🌿' : 'Hey Plant Lover 🌿',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scheme.surface,
              scheme.primaryContainer.withOpacity(0.22),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      scheme.primary.withOpacity(0.14),
                      scheme.tertiary.withOpacity(0.10),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: scheme.outline.withOpacity(0.12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: scheme.surface.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(Icons.eco_rounded, color: scheme.primary, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Plant collection',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.3,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: scheme.surface.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _searchQuery = value),
                        decoration: const InputDecoration(
                          hintText: 'Search plants…',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search_rounded),
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    if (suggestions.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: scheme.surface.withOpacity(0.96),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: scheme.outline.withOpacity(0.12)),
                        ),
                        child: Column(
                          children: suggestions.map((plant) {
                            return ListTile(
                              dense: true,
                              title: Text(plant.name),
                              subtitle: Text(plant.scientificName),
                              leading: const Icon(Icons.spa_outlined),
                              onTap: () {
                                _searchController.text = plant.name;
                                setState(() => _searchQuery = plant.name);
                                _openDetails(context, plant);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 22),
              if (plantProvider.isLoading)
                const Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.74,
                  ),
                  itemCount: homePlants.length + (hasRemainingPlants ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (hasRemainingPlants && index == homePlants.length) {
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MorePlantsScreen(plants: remainingPlants),
                              ),
                            );
                          },
                          child: Ink(
                            decoration: BoxDecoration(
                              color: scheme.surface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: scheme.outline.withOpacity(0.14)),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_circle_outline, size: 34, color: scheme.primary),
                                  const SizedBox(height: 10),
                                  Text(
                                    'More plants',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: scheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${remainingPlants.length} more',
                                    style: TextStyle(
                                      color: scheme.onSurface.withOpacity(0.65),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    final plant = homePlants[index];
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () => _openDetails(context, plant),
                        child: Ink(
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: scheme.outline.withOpacity(0.08)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.07),
                                blurRadius: 18,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                  child: Hero(
                                    tag: 'plant_image_${plant.id}',
                                    child: _plantPhoto(context, plant.imageUrl, index),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                                child: Column(
                                  children: [
                                    Text(
                                      plant.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        letterSpacing: -0.2,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      plant.scientificName,
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: scheme.onSurface.withOpacity(0.62),
                                        fontSize: 11.5,
                                        height: 1.25,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

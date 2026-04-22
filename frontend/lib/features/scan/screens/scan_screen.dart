// lib/features/scan/screens/scan_screen.dart
import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/glass_card.dart';
import 'package:image_picker/image_picker.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({Key? key}) : super(key: key);

  void _navigateToFlow(BuildContext context, String routeName, {bool requiresImage = false}) async {
    if (requiresImage) {
      final ImagePicker picker = ImagePicker();
      // Show bottom sheet to choose between camera and gallery
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Photo Library'),
                    onTap: () {
                      Navigator.of(context).pop(ImageSource.gallery);
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.of(context).pop(ImageSource.camera);
                  },
                ),
              ],
            ),
          );
        },
      );

      if (source != null) {
        // Resize/compress at capture time to speed up upload + backend inference.
        final XFile? image = await picker.pickImage(
          source: source,
          imageQuality: 75,
          maxWidth: 1600,
          maxHeight: 1600,
        );
        if (image != null && context.mounted) {
          Navigator.pushNamed(context, routeName, arguments: image.path);
        }
      }
    } else {
      Navigator.pushNamed(context, routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Elegant Premium Background
          Positioned.fill(
            child: Image.asset(
              'assets/plant_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.9),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Action Center', 
                    style: TextStyle(
                      fontSize: 32, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white, 
                      shadows: [Shadow(color: Colors.black87, blurRadius: 10)]
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'What do you want to do today?',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          _buildActionCard(
                            context,
                            title: 'Identify Plant',
                            subtitle: 'Upload an image to identify any plant species',
                            icon: Icons.image_search,
                            onTap: () => _navigateToFlow(context, AppRoutes.identifyFlow, requiresImage: true),
                          ),
                          _buildActionCard(
                            context,
                            title: 'Check Disease',
                            subtitle: 'Diagnose plant health and get treatments',
                            icon: Icons.healing,
                            onTap: () => _navigateToFlow(context, AppRoutes.diseaseFlow, requiresImage: true),
                          ),
                          _buildActionCard(
                            context,
                            title: 'Grow a Plant',
                            subtitle: 'Get step-by-step guidance for your plant',
                            icon: Icons.grass,
                            onTap: () => _navigateToFlow(context, AppRoutes.growFlow),
                          ),
                          _buildActionCard(
                            context,
                            title: 'Eco / Reuse Tips',
                            subtitle: 'Learn to upcycle materials for gardening',
                            icon: Icons.eco,
                            onTap: () => _navigateToFlow(context, AppRoutes.ecoFlow),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          height: 120,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                ),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

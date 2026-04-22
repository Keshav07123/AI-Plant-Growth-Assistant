import 'package:flutter/material.dart';
import '../../features/home/screens/dashboard_screen.dart';
import '../../features/scan/screens/scan_screen.dart';
import '../../features/scan/screens/loading_screen.dart';
import '../../features/scan/screens/result_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/auth/screens/auth_wrapper.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/tasks/screens/disease_flow_screen.dart';
import '../../features/tasks/screens/eco_flow_screen.dart';
import '../../features/tasks/screens/grow_flow_screen.dart';
import '../../features/tasks/screens/identify_flow_screen.dart';

class ScanLoadingArgs {
  final String imagePath;
  final String task;
  const ScanLoadingArgs({required this.imagePath, required this.task});
}

class AppRoutes {
  static const String authWrapper = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String dashboard = '/dashboard';
  static const String scan = '/scan';
  static const String scanLoading = '/scan_loading';
  static const String scanResult = '/scan_result';
  static const String history = '/history';
  static const String identifyFlow = '/identify_flow';
  static const String diseaseFlow = '/disease_flow';
  static const String growFlow = '/grow_flow';
  static const String ecoFlow = '/eco_flow';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case authWrapper:
        return MaterialPageRoute(builder: (_) => const AuthWrapper());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case scan:
        return MaterialPageRoute(builder: (_) => const ScanScreen());
      case scanLoading:
        final args = settings.arguments as ScanLoadingArgs?;
        return MaterialPageRoute(
          builder: (_) => LoadingScreen(
            imagePath: args?.imagePath,
            task: args?.task ?? 'identify',
          ),
        );
      case scanResult:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const ResultScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      case history:
        return MaterialPageRoute(builder: (_) => const HistoryScreen());
      case identifyFlow:
        final imagePath = settings.arguments as String?;
        return MaterialPageRoute(builder: (_) => IdentifyFlowScreen(imagePath: imagePath));
      case diseaseFlow:
        final imagePath = settings.arguments as String?;
        return MaterialPageRoute(builder: (_) => DiseaseFlowScreen(imagePath: imagePath));
      case growFlow:
        return MaterialPageRoute(builder: (_) => const GrowFlowScreen());
      case ecoFlow:
        return MaterialPageRoute(builder: (_) => const EcoFlowScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}

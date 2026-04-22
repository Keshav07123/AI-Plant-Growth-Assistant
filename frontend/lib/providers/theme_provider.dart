// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';

class ThemeProvider with ChangeNotifier {
  final LocalStorageService _storageService;
  bool _isDarkMode = false;

  ThemeProvider({LocalStorageService? storageService})
      : _storageService = storageService ?? LocalStorageService() {
    _loadTheme();
  }

  bool get isDarkMode => _isDarkMode;

  Future<void> _loadTheme() async {
    _isDarkMode = await _storageService.getThemeMode() ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _storageService.saveThemeMode(_isDarkMode);
    notifyListeners();
  }
}

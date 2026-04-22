// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/local_storage_service.dart';

class AuthProvider with ChangeNotifier {
  final LocalStorageService _storageService;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool _isLoading = true; // Initially loading while checking shared_prefs
  bool get isLoading => _isLoading;

  AuthProvider({LocalStorageService? storageService})
      : _storageService = storageService ?? LocalStorageService() {
    _checkInitialSession();
  }

  Future<void> _checkInitialSession() async {
    final isLoggedIn = await _storageService.isLoggedIn();
    if (isLoggedIn) {
      final name = await _storageService.getUserName() ?? 'Plant Lover';
      _currentUser = UserModel(id: 'local_id', name: name, email: 'saved@local.com');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signup(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    // Simulate network API delay
    await Future.delayed(const Duration(seconds: 1));

    _currentUser = UserModel(id: 'local_id', name: name, email: email);
    await _storageService.saveUserSession(name);

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    // Simulate network API delay
    await Future.delayed(const Duration(seconds: 1));

    // Assume successful login and grab previous name if exists
    final savedName = await _storageService.getUserName() ?? 'Plant Lover';
    _currentUser = UserModel(id: 'local_id', name: savedName, email: email);
    await _storageService.saveUserSession(savedName);

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
    await _storageService.clearUserSession();
    notifyListeners();
  }
}

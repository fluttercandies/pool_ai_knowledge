import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/admin_user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  bool _isLoggedIn = false;
  bool _isSuperAdmin = false;
  String? _username;
  bool _isLoading = true;
  String? _error;

  AuthProvider(this._authService);

  bool get isLoggedIn => _isLoggedIn;
  bool get isSuperAdmin => _isSuperAdmin;
  String? get username => _username;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isLoggedIn = await _authService.isLoggedIn();
      if (_isLoggedIn) {
        _username = await _authService.getUsername();
        _isSuperAdmin = await _authService.isSuperAdmin();
      }
    } catch (e) {
      _isLoggedIn = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(username, password);
      _isLoggedIn = true;
      _username = username;
      _isSuperAdmin = response['is_super_admin'] ?? false;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    _username = null;
    _isSuperAdmin = false;
    notifyListeners();
  }

  Future<bool> createAdminUser(AdminCreate admin) async {
    _error = null;
    try {
      await _authService.createAdminUser(admin);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to create user: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

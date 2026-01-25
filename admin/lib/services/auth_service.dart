import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/admin_user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;
  static const String _tokenKey = 'auth_token';
  static const String _usernameKey = 'username';
  static const String _isSuperAdminKey = 'is_super_admin';

  AuthService(this._apiService);

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _apiService.post(
      ApiConfig.adminLogin,
      body: AdminLogin(username: username, password: password).toJson(),
    );

    final token = response['access_token'];
    if (token != null) {
      await _saveToken(token);
      await _saveUserInfo(
        username,
        response['is_super_admin'] ?? false,
      );
      _apiService.setToken(token);
    }

    return response;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_isSuperAdminKey);
    _apiService.setToken(null);
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _saveUserInfo(String username, bool isSuperAdmin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
    await prefs.setBool(_isSuperAdminKey, isSuperAdmin);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  Future<bool> isSuperAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isSuperAdminKey) ?? false;
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token != null) {
      _apiService.setToken(token);
      return true;
    }
    return false;
  }

  Future<void> createAdminUser(AdminCreate admin) async {
    await _apiService.post(ApiConfig.adminUsers, body: admin.toJson());
  }
}

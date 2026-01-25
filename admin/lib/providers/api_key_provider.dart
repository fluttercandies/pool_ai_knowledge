import 'package:flutter/material.dart';
import '../models/api_key.dart';
import '../services/api_key_service.dart';
import '../services/api_service.dart';

class ApiKeyProvider extends ChangeNotifier {
  final ApiKeyService _apiKeyService;
  List<ApiKey> _apiKeys = [];
  bool _isLoading = false;
  String? _error;
  int _total = 0;
  ApiKey? _lastCreatedKey;

  ApiKeyProvider(this._apiKeyService);

  List<ApiKey> get apiKeys => _apiKeys;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get total => _total;
  ApiKey? get lastCreatedKey => _lastCreatedKey;

  Future<void> loadApiKeys({int skip = 0, int limit = 100}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiKeyService.getApiKeys(skip: skip, limit: limit);
      _apiKeys = response.items;
      _total = response.total;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load API keys: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createApiKey(ApiKeyCreate apiKey) async {
    _error = null;
    try {
      final created = await _apiKeyService.createApiKey(apiKey);
      _lastCreatedKey = created;
      await loadApiKeys();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to create API key: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateApiKey(int keyId, ApiKeyUpdate apiKey) async {
    _error = null;
    try {
      await _apiKeyService.updateApiKey(keyId, apiKey);
      await loadApiKeys();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to update API key: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteApiKey(int keyId) async {
    _error = null;
    try {
      await _apiKeyService.deleteApiKey(keyId);
      await loadApiKeys();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to delete API key: $e';
      notifyListeners();
      return false;
    }
  }

  void clearLastCreatedKey() {
    _lastCreatedKey = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

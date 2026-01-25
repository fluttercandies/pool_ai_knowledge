import '../config/api_config.dart';
import '../models/api_key.dart';
import 'api_service.dart';

class ApiKeyService {
  final ApiService _apiService;

  ApiKeyService(this._apiService);

  Future<ApiKeyListResponse> getApiKeys({int skip = 0, int limit = 100}) async {
    final response = await _apiService.get(
      ApiConfig.apiKeys,
      queryParams: {'skip': skip, 'limit': limit},
    );
    return ApiKeyListResponse.fromJson(response);
  }

  Future<ApiKey> getApiKey(int keyId) async {
    final response = await _apiService.get('${ApiConfig.apiKeys}/$keyId');
    return ApiKey.fromJson(response);
  }

  Future<ApiKey> createApiKey(ApiKeyCreate apiKey) async {
    final response = await _apiService.post(
      ApiConfig.apiKeys,
      body: apiKey.toJson(),
    );
    return ApiKey.fromJson(response);
  }

  Future<ApiKey> updateApiKey(int keyId, ApiKeyUpdate apiKey) async {
    final response = await _apiService.put(
      '${ApiConfig.apiKeys}/$keyId',
      body: apiKey.toJson(),
    );
    return ApiKey.fromJson(response);
  }

  Future<void> deleteApiKey(int keyId) async {
    await _apiService.delete('${ApiConfig.apiKeys}/$keyId');
  }
}

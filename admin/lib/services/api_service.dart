import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  String? get token => _token;

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw ApiException('Unauthorized', statusCode: 401);
    } else if (response.statusCode == 422) {
      final error = jsonDecode(response.body);
      throw ApiException(error['detail']?.toString() ?? 'Validation error',
          statusCode: 422);
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(error['detail']?.toString() ?? 'Request failed',
          statusCode: response.statusCode);
    }
  }

  Future<Map<String, dynamic>> get(String endpoint,
      {Map<String, dynamic>? queryParams}) async {
    var uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    if (queryParams != null) {
      uri = uri.replace(
          queryParameters:
              queryParams.map((k, v) => MapEntry(k, v.toString())));
    }
    final response = await http.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(String endpoint,
      {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final response = await http.post(
      uri,
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(String endpoint,
      {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final response = await http.put(
      uri,
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<void> delete(String endpoint) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final response = await http.delete(uri, headers: _headers);
    if (response.statusCode != 204 && response.statusCode != 200) {
      await _handleResponse(response);
    }
  }
}

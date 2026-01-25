class ApiKey {
  final int? id;
  final String name;
  final String? key;
  final String? keyPrefix;
  final bool isActive;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final DateTime? lastUsedAt;

  ApiKey({
    this.id,
    required this.name,
    this.key,
    this.keyPrefix,
    this.isActive = true,
    this.expiresAt,
    this.createdAt,
    this.lastUsedAt,
  });

  factory ApiKey.fromJson(Map<String, dynamic> json) {
    return ApiKey(
      id: json['id'],
      name: json['name'] ?? '',
      key: json['key'],
      keyPrefix: json['key_prefix'],
      isActive: json['is_active'] ?? true,
      expiresAt:
          json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
      createdAt:
          json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      lastUsedAt: json['last_used_at'] != null
          ? DateTime.parse(json['last_used_at'])
          : null,
    );
  }
}

class ApiKeyCreate {
  final String name;
  final DateTime? expiresAt;

  ApiKeyCreate({required this.name, this.expiresAt});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'name': name};
    if (expiresAt != null) {
      map['expires_at'] = expiresAt!.toIso8601String();
    }
    return map;
  }
}

class ApiKeyUpdate {
  final String? name;
  final bool? isActive;
  final DateTime? expiresAt;

  ApiKeyUpdate({this.name, this.isActive, this.expiresAt});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (isActive != null) map['is_active'] = isActive;
    if (expiresAt != null) map['expires_at'] = expiresAt!.toIso8601String();
    return map;
  }
}

class ApiKeyListResponse {
  final List<ApiKey> items;
  final int total;

  ApiKeyListResponse({required this.items, required this.total});

  factory ApiKeyListResponse.fromJson(Map<String, dynamic> json) {
    return ApiKeyListResponse(
      items: (json['items'] as List? ?? [])
          .map((e) => ApiKey.fromJson(e))
          .toList(),
      total: json['total'] ?? 0,
    );
  }
}

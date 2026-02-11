class Post {
  final String id;
  final String title;
  final String content;
  final List<String> tags;
  final String language;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Post({
    required this.id,
    required this.title,
    required this.content,
    required this.tags,
    this.language = 'zh-CN',
    this.createdAt,
    this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json['id'] as String? ?? json['_id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        content: json['content'] as String? ?? '',
        tags: (json['tags'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        language: json['language'] as String? ?? 'zh-CN',
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'] as String)
            : null,
      );
}

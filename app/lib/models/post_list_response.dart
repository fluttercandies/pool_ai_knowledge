import 'post.dart';

class PostListResponse {
  final List<Post> posts;
  final int total;

  const PostListResponse({required this.posts, required this.total});

  factory PostListResponse.fromJson(Map<String, dynamic> json) =>
      PostListResponse(
        posts: (json['posts'] as List<dynamic>?)
                ?.map((e) => Post.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        total: json['total'] as int? ?? 0,
      );
}

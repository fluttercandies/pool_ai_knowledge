import '../config/api_config.dart';
import '../models/post.dart';
import 'api_service.dart';

class PostService {
  final ApiService _apiService;

  PostService(this._apiService);

  Future<PostListResponse> getPosts({int skip = 0, int limit = 20}) async {
    final response = await _apiService.get(
      ApiConfig.posts,
      queryParams: {'skip': skip, 'limit': limit},
    );
    return PostListResponse.fromJson(response);
  }

  Future<Post> getPost(String postId) async {
    final response = await _apiService.get('${ApiConfig.posts}/$postId');
    return Post.fromJson(response);
  }

  Future<Post> createPost(PostCreate post) async {
    final response = await _apiService.post(
      ApiConfig.posts,
      body: post.toJson(),
    );
    return Post.fromJson(response);
  }

  Future<Post> updatePost(String postId, PostUpdate post) async {
    final response = await _apiService.put(
      '${ApiConfig.posts}/$postId',
      body: post.toJson(),
    );
    return Post.fromJson(response);
  }

  Future<void> deletePost(String postId) async {
    await _apiService.delete('${ApiConfig.posts}/$postId');
  }
}

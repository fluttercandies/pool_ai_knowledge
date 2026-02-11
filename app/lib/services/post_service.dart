import '../models/post.dart';
import '../models/post_list_response.dart';
import 'dio_client.dart';

class PostService {
  final _dio = DioClient().dio;

  Future<PostListResponse> getPosts({int skip = 0, int limit = 6}) async {
    final response = await _dio.get(
      '/api/web/posts',
      queryParameters: {'skip': skip, 'limit': limit},
    );
    return PostListResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Post> getPost(String id) async {
    final response = await _dio.get('/api/web/posts/$id');
    return Post.fromJson(response.data as Map<String, dynamic>);
  }

  Future<dynamic> searchPosts(String query, {int topK = 3}) async {
    final response = await _dio.post(
      '/api/web/search',
      data: {'query': query, 'top_k': topK},
    );
    return response.data;
  }
}

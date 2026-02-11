import '../models/chat_response.dart';
import 'dio_client.dart';

class ChatService {
  final _dio = DioClient().dio;

  Future<ChatApiResponse> chatWithAgent(String message,
      {String? postId}) async {
    final data = <String, dynamic>{
      'agent_name': 'knowledge',
      'message': message,
    };
    if (postId != null) data['post_id'] = postId;

    final response = await _dio.post('/api/chat', data: data);
    return ChatApiResponse.fromJson(response.data as Map<String, dynamic>);
  }
}

import 'chat_reference.dart';

class ChatApiResponse {
  final String response;
  final List<ChatReference> references;

  const ChatApiResponse({required this.response, this.references = const []});

  factory ChatApiResponse.fromJson(Map<String, dynamic> json) =>
      ChatApiResponse(
        response: json['response'] as String? ?? '',
        references: (json['references'] as List<dynamic>?)
                ?.map((e) => ChatReference.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

import 'chat_reference.dart';

enum MessageRole { user, assistant }

class ChatMessage {
  final MessageRole role;
  final String content;
  final List<ChatReference> references;
  final bool isError;
  final String? postTitle;

  const ChatMessage({
    required this.role,
    required this.content,
    this.references = const [],
    this.isError = false,
    this.postTitle,
  });
}

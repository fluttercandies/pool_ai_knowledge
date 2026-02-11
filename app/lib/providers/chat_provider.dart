import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/constants.dart';
import '../models/chat_message.dart';
import '../models/post.dart';
import '../services/chat_service.dart';
import '../services/post_service.dart';
import 'locale_provider.dart';

// Chat state
class ChatState {
  final List<ChatMessage> messages;
  final bool isSending;
  final String? selectedPostId;
  final String? selectedPostTitle;

  const ChatState({
    this.messages = const [],
    this.isSending = false,
    this.selectedPostId,
    this.selectedPostTitle,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
    String? selectedPostId,
    String? selectedPostTitle,
    bool clearPost = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      selectedPostId: clearPost ? null : (selectedPostId ?? this.selectedPostId),
      selectedPostTitle:
          clearPost ? null : (selectedPostTitle ?? this.selectedPostTitle),
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final Ref ref;

  ChatNotifier(this.ref) : super(const ChatState());

  void selectPost(String? postId, String? postTitle) {
    state = state.copyWith(selectedPostId: postId, selectedPostTitle: postTitle);
  }

  void clearPostContext() {
    state = state.copyWith(clearPost: true);
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || state.isSending) return;

    final userMsg = ChatMessage(
      role: MessageRole.user,
      content: text,
      postTitle: state.selectedPostTitle,
    );
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isSending: true,
    );

    try {
      final response = await ChatService().chatWithAgent(
        text,
        postId: state.selectedPostId,
      );
      final aiMsg = ChatMessage(
        role: MessageRole.assistant,
        content: response.response,
        references: response.references,
      );
      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isSending: false,
      );
    } catch (e) {
      final locale = ref.read(localeProvider);
      final errorText = locale.languageCode == 'zh'
          ? '抱歉，请求失败，请稍后重试。'
          : 'Sorry, the request failed. Please try again later.';
      final errorMsg = ChatMessage(
        role: MessageRole.assistant,
        content: errorText,
        isError: true,
      );
      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isSending: false,
      );
    }
  }
}

final chatProvider =
    StateNotifierProvider.autoDispose<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref);
});

// Post options for the article selector in chat
final chatPostOptionsProvider =
    FutureProvider.autoDispose<List<Post>>((ref) async {
  ref.watch(localeProvider);
  final data = await PostService().getPosts(
    skip: 0,
    limit: AppConfig.chatPostOptionsLimit,
  );
  return data.posts;
});

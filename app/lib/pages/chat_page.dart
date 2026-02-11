import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_strings.dart';
import '../models/post.dart';
import '../providers/chat_provider.dart';
import '../providers/locale_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/typing_indicator.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String? initialPostId;
  final String? initialPostTitle;

  const ChatPage({super.key, this.initialPostId, this.initialPostTitle});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  bool _initialized = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    ref.read(chatProvider.notifier).sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final s = AppStrings.of(locale);
    final chatState = ref.watch(chatProvider);
    final postOptions = ref.watch(chatPostOptionsProvider);

    // Initialize post context from query params
    if (!_initialized) {
      _initialized = true;
      if (widget.initialPostId != null) {
        final title = widget.initialPostTitle != null
            ? Uri.decodeComponent(widget.initialPostTitle!)
            : null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(chatProvider.notifier)
              .selectPost(widget.initialPostId, title);
        });
      }
    }

    // Auto-scroll when messages change
    ref.listen(chatProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length || next.isSending) {
        _scrollToBottom();
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(s.chatTitle, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          s.chatDesc,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),

        // Article context selector
        _buildContextSelector(context, s, chatState, postOptions),

        const SizedBox(height: 12),

        // Chat area
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Column(
              children: [
                // Messages
                Expanded(
                  child: chatState.messages.isEmpty
                      ? _buildEmptyHint(context, s)
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: chatState.messages.length +
                              (chatState.isSending ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == chatState.messages.length) {
                              return const Align(
                                alignment: Alignment.centerLeft,
                                child: TypingIndicator(),
                              );
                            }
                            return ChatBubble(
                              message: chatState.messages[index],
                              onReferenceTap: (postId) {
                                context.go('/posts/$postId');
                              },
                            );
                          },
                        ),
                ),

                // Input area
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: KeyboardListener(
                          focusNode: _focusNode,
                          onKeyEvent: (event) {
                            if (event is KeyDownEvent &&
                                event.logicalKey ==
                                    LogicalKeyboardKey.enter &&
                                !HardwareKeyboard.instance.isShiftPressed) {
                              _sendMessage();
                            }
                          },
                          child: TextField(
                            controller: _textController,
                            maxLines: 4,
                            minLines: 2,
                            enabled: !chatState.isSending,
                            decoration: InputDecoration(
                              hintText: chatState.selectedPostTitle != null
                                  ? s.chatPlaceholderWithPost(
                                      chatState.selectedPostTitle!)
                                  : s.chatPlaceholder,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 54,
                        child: FilledButton(
                          onPressed: chatState.isSending
                              ? null
                              : () => _sendMessage(),
                          child: Text(s.chatSend),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContextSelector(
    BuildContext context,
    AppStrings s,
    ChatState chatState,
    AsyncValue<List<Post>> postOptions,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: postOptions.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const SizedBox.shrink(),
            data: (posts) {
              return DropdownButtonFormField<String>(
                initialValue: chatState.selectedPostId,
                decoration: InputDecoration(
                  hintText: s.chatSelectPost,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  isDense: true,
                ),
                isExpanded: true,
                items: posts.map((post) {
                  return DropdownMenuItem(
                    value: post.id,
                    child: Text(
                      post.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (postId) {
                  if (postId != null) {
                    final post = posts.firstWhere((p) => p.id == postId);
                    ref
                        .read(chatProvider.notifier)
                        .selectPost(postId, post.title);
                  }
                },
              );
            },
          ),
        ),
        if (chatState.selectedPostId != null) ...[
          const SizedBox(width: 8),
          InputChip(
            label: Text(
              '${s.chatContextPrefix}: ${chatState.selectedPostTitle ?? ""}',
              overflow: TextOverflow.ellipsis,
            ),
            onDeleted: () {
              ref.read(chatProvider.notifier).clearPostContext();
            },
            backgroundColor: colorScheme.secondaryContainer,
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyHint(BuildContext context, AppStrings s) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline,
              size: 64, color: colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            s.chatEmptyHint,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            s.chatEmptySubHint,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}

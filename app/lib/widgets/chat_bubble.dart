import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/chat_message.dart';
import '../models/chat_reference.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final void Function(String postId)? onReferenceTap;

  const ChatBubble({
    super.key,
    required this.message,
    this.onReferenceTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _avatar(context, isUser),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isUser
                        ? colorScheme.primary
                        : message.isError
                            ? colorScheme.errorContainer
                            : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft:
                          isUser ? const Radius.circular(16) : Radius.zero,
                      bottomRight:
                          isUser ? Radius.zero : const Radius.circular(16),
                    ),
                  ),
                  child: isUser
                      ? Text(
                          message.content,
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 14,
                          ),
                        )
                      : MarkdownBody(
                          data: message.content,
                          selectable: true,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(
                              fontSize: 14,
                              color: message.isError
                                  ? colorScheme.onErrorContainer
                                  : colorScheme.onSurface,
                            ),
                            code: TextStyle(
                              fontSize: 13,
                              backgroundColor: colorScheme.surfaceContainerLow,
                            ),
                            codeblockDecoration: BoxDecoration(
                              color: colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onTapLink: (_, href, __) {
                            if (href != null) {
                              launchUrl(Uri.parse(href));
                            }
                          },
                        ),
                ),
                if (message.references.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _buildReferences(context, message.references),
                ],
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser) _avatar(context, isUser),
        ],
      ),
    );
  }

  Widget _avatar(BuildContext context, bool isUser) {
    final colorScheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: 16,
      backgroundColor:
          isUser ? colorScheme.primary : colorScheme.secondaryContainer,
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        size: 18,
        color: isUser
            ? colorScheme.onPrimary
            : colorScheme.onSecondaryContainer,
      ),
    );
  }

  Widget _buildReferences(BuildContext context, List<ChatReference> refs) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: refs.map((ref) {
        return ActionChip(
          avatar: const Icon(Icons.article_outlined, size: 16),
          label: Text(ref.title, style: const TextStyle(fontSize: 12)),
          visualDensity: VisualDensity.compact,
          onPressed: () => onReferenceTap?.call(ref.postId),
        );
      }).toList(),
    );
  }
}

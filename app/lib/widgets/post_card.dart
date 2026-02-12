import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/post.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final int excerptLength;
  final VoidCallback onTap;

  const PostCard({
    super.key,
    required this.post,
    this.excerptLength = 100,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final excerpt = post.content.length > excerptLength
        ? '${post.content.substring(0, excerptLength)}...'
        : post.content;
    final dateStr = post.createdAt != null
        ? DateFormat('yyyy-MM-dd').format(post.createdAt!)
        : '';

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                excerpt,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: post.tags.take(3).map((tag) {
                        return Chip(
                          label: Text(tag,
                              style: TextStyle(
                                  color: colorScheme.primary)),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ),
                  ),
                  if (dateStr.isNotEmpty)
                    Text(
                      dateStr,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

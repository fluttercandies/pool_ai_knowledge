import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/constants.dart';
import '../l10n/app_strings.dart';
import '../providers/locale_provider.dart';
import '../providers/posts_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/post_card.dart';
import '../widgets/responsive_grid.dart';

class PostsPage extends ConsumerWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final s = AppStrings.of(locale);
    final postsState = ref.watch(postsListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(s.postsTitle, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 20),
        Expanded(
          child: postsState.isLoading && postsState.data == null
              ? const LoadingIndicator()
              : postsState.error != null && postsState.data == null
                  ? EmptyState(message: postsState.error!)
                  : postsState.data == null || postsState.data!.posts.isEmpty
                      ? EmptyState(message: s.postsNoPosts)
                      : Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: ResponsiveGrid(
                                  children:
                                      postsState.data!.posts.map((post) {
                                    return PostCard(
                                      post: post,
                                      excerptLength: 120,
                                      onTap: () =>
                                          context.go('/posts/${post.id}'),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            if (postsState.data!.total >
                                AppConfig.postsPageSize)
                              _Pagination(
                                currentPage: postsState.page,
                                totalPages: (postsState.data!.total /
                                        AppConfig.postsPageSize)
                                    .ceil(),
                                onPageChanged: (page) {
                                  ref
                                      .read(postsListProvider.notifier)
                                      .setPage(page);
                                },
                              ),
                          ],
                        ),
        ),
      ],
    );
  }
}

class _Pagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const _Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed:
                currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left),
          ),
          ...List.generate(totalPages, (i) {
            final page = i + 1;
            final isActive = page == currentPage;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: TextButton(
                onPressed: isActive ? null : () => onPageChanged(page),
                style: TextButton.styleFrom(
                  backgroundColor:
                      isActive ? colorScheme.primaryContainer : null,
                  foregroundColor: isActive
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
                  minimumSize: const Size(40, 40),
                  padding: EdgeInsets.zero,
                ),
                child: Text('$page'),
              ),
            );
          }),
          IconButton(
            onPressed: currentPage < totalPages
                ? () => onPageChanged(currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

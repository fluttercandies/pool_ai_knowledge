import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_strings.dart';
import '../providers/locale_provider.dart';
import '../providers/posts_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/post_card.dart';
import '../widgets/responsive_grid.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final s = AppStrings.of(locale);
    final recentPosts = ref.watch(recentPostsProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
            child: Column(
              children: [
                Text(
                  s.homeHeroTitle,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  s.homeHeroDesc,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: () => context.go('/posts'),
                      icon: const Icon(Icons.article_outlined),
                      label: Text(s.homeBrowsePosts),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.go('/chat'),
                      icon: const Icon(Icons.chat_outlined),
                      label: Text(s.homeAiChat),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s.homeRecentPosts,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              TextButton(
                onPressed: () => context.go('/posts'),
                child: Text(s.homeViewAll),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Posts grid
          recentPosts.when(
            loading: () => const LoadingIndicator(),
            error: (err, _) => EmptyState(message: err.toString()),
            data: (data) {
              if (data.posts.isEmpty) {
                return EmptyState(message: s.homeNoPosts);
              }
              return ResponsiveGrid(
                children: data.posts.map((post) {
                  return PostCard(
                    post: post,
                    excerptLength: 100,
                    onTap: () => context.go('/posts/${post.id}'),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

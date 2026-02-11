import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../pages/home_page.dart';
import '../pages/posts_page.dart';
import '../pages/post_detail_page.dart';
import '../pages/chat_page.dart';
import '../widgets/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const HomePage(),
          ),
          GoRoute(
            path: '/posts',
            builder: (_, _) => const PostsPage(),
          ),
          GoRoute(
            path: '/posts/:id',
            builder: (_, state) => PostDetailPage(
              postId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/chat',
            builder: (_, state) {
              final postId = state.uri.queryParameters['postId'];
              final postTitle = state.uri.queryParameters['postTitle'];
              return ChatPage(
                initialPostId: postId,
                initialPostTitle: postTitle,
              );
            },
          ),
        ],
      ),
    ],
  );
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/constants.dart';
import '../models/post_list_response.dart';
import '../services/post_service.dart';
import 'locale_provider.dart';

// Recent posts for home page
final recentPostsProvider =
    FutureProvider.autoDispose<PostListResponse>((ref) {
  ref.watch(localeProvider);
  return PostService().getPosts(skip: 0, limit: AppConfig.homePostsLimit);
});

// Paginated posts list state
class PostsListState {
  final PostListResponse? data;
  final bool isLoading;
  final String? error;
  final int page;

  const PostsListState({
    this.data,
    this.isLoading = false,
    this.error,
    this.page = 1,
  });

  PostsListState copyWith({
    PostListResponse? data,
    bool? isLoading,
    String? error,
    int? page,
  }) {
    return PostsListState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      page: page ?? this.page,
    );
  }
}

class PostsListNotifier extends StateNotifier<PostsListState> {
  final Ref ref;

  PostsListNotifier(this.ref) : super(const PostsListState()) {
    loadPosts();
  }

  Future<void> loadPosts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await PostService().getPosts(
        skip: (state.page - 1) * AppConfig.postsPageSize,
        limit: AppConfig.postsPageSize,
      );
      state = state.copyWith(data: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setPage(int page) {
    state = state.copyWith(page: page);
    loadPosts();
  }
}

final postsListProvider =
    StateNotifierProvider.autoDispose<PostsListNotifier, PostsListState>((ref) {
  ref.watch(localeProvider);
  return PostsListNotifier(ref);
});

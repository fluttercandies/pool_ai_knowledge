import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import '../services/api_service.dart';

class PostProvider extends ChangeNotifier {
  final PostService _postService;
  List<Post> _posts = [];
  Post? _currentPost;
  bool _isLoading = false;
  String? _error;
  int _total = 0;

  PostProvider(this._postService);

  List<Post> get posts => _posts;
  Post? get currentPost => _currentPost;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get total => _total;

  Future<void> loadPosts({int skip = 0, int limit = 20}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _postService.getPosts(skip: skip, limit: limit);
      _posts = response.items;
      _total = response.total;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load posts: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> loadPost(String postId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentPost = await _postService.getPost(postId);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to load post: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> createPost(PostCreate post) async {
    _error = null;
    try {
      await _postService.createPost(post);
      await loadPosts();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to create post: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePost(String postId, PostUpdate post) async {
    _error = null;
    try {
      await _postService.updatePost(postId, post);
      await loadPosts();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to update post: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePost(String postId) async {
    _error = null;
    try {
      await _postService.deletePost(postId);
      await loadPosts();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to delete post: $e';
      notifyListeners();
      return false;
    }
  }

  void clearCurrentPost() {
    _currentPost = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

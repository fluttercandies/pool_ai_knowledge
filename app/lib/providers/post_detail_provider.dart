import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/post.dart';
import '../services/post_service.dart';
import 'locale_provider.dart';

final postDetailProvider =
    FutureProvider.autoDispose.family<Post, String>((ref, id) {
  ref.watch(localeProvider);
  return PostService().getPost(id);
});

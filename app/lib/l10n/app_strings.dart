import 'dart:ui';

import 'strings_zh.dart';
import 'strings_en.dart';

class AppStrings {
  final Map<String, String> _map;
  AppStrings._(this._map);

  static AppStrings of(Locale locale) {
    if (locale.languageCode == 'zh') return AppStrings._(zhStrings);
    return AppStrings._(enStrings);
  }

  String get(String key) => _map[key] ?? key;

  String getWithArgs(String key, Map<String, String> args) {
    var result = get(key);
    args.forEach((k, v) {
      result = result.replaceAll('{$k}', v);
    });
    return result;
  }

  // Nav
  String get navTitle => get('nav.title');
  String get navHome => get('nav.home');
  String get navPosts => get('nav.posts');
  String get navChat => get('nav.chat');

  // Home
  String get homeHeroTitle => get('home.heroTitle');
  String get homeHeroDesc => get('home.heroDesc');
  String get homeBrowsePosts => get('home.browsePosts');
  String get homeAiChat => get('home.aiChat');
  String get homeRecentPosts => get('home.recentPosts');
  String get homeViewAll => get('home.viewAll');
  String get homeNoPosts => get('home.noPosts');

  // Posts
  String get postsTitle => get('posts.title');
  String get postsNoPosts => get('posts.noPosts');

  // Detail
  String get detailBack => get('detail.back');
  String get detailNotFound => get('detail.notFound');
  String get detailChatCta => get('detail.chatCta');
  String get detailAskAi => get('detail.askAi');

  // Chat
  String get chatTitle => get('chat.title');
  String get chatDesc => get('chat.desc');
  String get chatSelectPost => get('chat.selectPost');
  String get chatContextPrefix => get('chat.contextPrefix');
  String get chatEmptyHint => get('chat.emptyHint');
  String get chatEmptySubHint => get('chat.emptySubHint');
  String get chatPlaceholder => get('chat.placeholder');
  String chatPlaceholderWithPost(String title) =>
      getWithArgs('chat.placeholderWithPost', {'title': title});
  String get chatSend => get('chat.send');
  String get chatError => get('chat.error');

  // Lang
  String get langZh => get('lang.zh');
  String get langEn => get('lang.en');
}

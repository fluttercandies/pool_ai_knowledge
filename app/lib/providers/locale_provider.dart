import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/dio_client.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('zh', 'CN'));

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('language') ?? 'zh-CN';
    state = _parseLocale(saved);
    DioClient().setLanguage(saved);
  }

  Future<void> setLocale(String languageTag) async {
    state = _parseLocale(languageTag);
    DioClient().setLanguage(languageTag);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageTag);
  }

  String get languageTag {
    if (state.countryCode != null && state.countryCode!.isNotEmpty) {
      return '${state.languageCode}-${state.countryCode}';
    }
    return state.languageCode;
  }

  Locale _parseLocale(String tag) {
    if (tag.contains('-')) {
      final parts = tag.split('-');
      return Locale(parts[0], parts[1]);
    }
    return Locale(tag);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

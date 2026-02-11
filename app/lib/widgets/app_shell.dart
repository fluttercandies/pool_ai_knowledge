import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/locale_provider.dart';
import '../l10n/app_strings.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  static const _navPaths = ['/', '/posts', '/chat'];

  int _indexFromLocation(String location) {
    if (location.startsWith('/posts/')) return 1;
    if (location == '/posts') return 1;
    if (location.startsWith('/chat')) return 2;
    return 0;
  }

  void _navigateTo(BuildContext context, int index) {
    context.go(_navPaths[index]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final s = AppStrings.of(locale);
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 600;
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);

    if (isWide) {
      return Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            onTap: () => context.go('/'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.menu_book),
                const SizedBox(width: 8),
                Text(s.navTitle),
              ],
            ),
          ),
          actions: [
            _NavButton(
              label: s.navHome,
              isActive: currentIndex == 0,
              onTap: () => _navigateTo(context, 0),
            ),
            _NavButton(
              label: s.navPosts,
              isActive: currentIndex == 1,
              onTap: () => _navigateTo(context, 1),
            ),
            _NavButton(
              label: s.navChat,
              isActive: currentIndex == 2,
              onTap: () => _navigateTo(context, 2),
            ),
            const SizedBox(width: 16),
            _LanguageSwitcher(locale: locale, ref: ref),
            const SizedBox(width: 16),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: child,
            ),
          ),
        ),
      );
    }

    // Mobile layout with bottom navigation
    return Scaffold(
      appBar: AppBar(
        title: Text(s.navTitle),
        actions: [
          _LanguageSwitcher(locale: locale, ref: ref),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => _navigateTo(context, i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: s.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.article_outlined),
            selectedIcon: const Icon(Icons.article),
            label: s.navPosts,
          ),
          NavigationDestination(
            icon: const Icon(Icons.chat_outlined),
            selectedIcon: const Icon(Icons.chat),
            label: s.navChat,
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: isActive ? colorScheme.primary : colorScheme.onSurface,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class _LanguageSwitcher extends StatelessWidget {
  final Locale locale;
  final WidgetRef ref;

  const _LanguageSwitcher({required this.locale, required this.ref});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      tooltip: '',
      onSelected: (lang) {
        ref.read(localeProvider.notifier).setLocale(lang);
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'zh-CN',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (locale.languageCode == 'zh')
                Icon(Icons.check, size: 18, color: Theme.of(context).colorScheme.primary),
              if (locale.languageCode == 'zh') const SizedBox(width: 8),
              const Text('中文'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'en',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (locale.languageCode == 'en')
                Icon(Icons.check, size: 18, color: Theme.of(context).colorScheme.primary),
              if (locale.languageCode == 'en') const SizedBox(width: 8),
              const Text('English'),
            ],
          ),
        ),
      ],
    );
  }
}

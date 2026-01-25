import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final int currentIndex;

  const MainLayout({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final isTablet = MediaQuery.of(context).size.width > 600;

    final destinations = [
      const NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      const NavigationDestination(
        icon: Icon(Icons.key_outlined),
        selectedIcon: Icon(Icons.key),
        label: 'API Keys',
      ),
      const NavigationDestination(
        icon: Icon(Icons.article_outlined),
        selectedIcon: Icon(Icons.article),
        label: 'Posts',
      ),
      if (authProvider.isSuperAdmin)
        const NavigationDestination(
          icon: Icon(Icons.people_outlined),
          selectedIcon: Icon(Icons.people),
          label: 'Users',
        ),
    ];

    final railDestinations = [
      const NavigationRailDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard),
        label: Text('Dashboard'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.key_outlined),
        selectedIcon: Icon(Icons.key),
        label: Text('API Keys'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.article_outlined),
        selectedIcon: Icon(Icons.article),
        label: Text('Posts'),
      ),
      if (authProvider.isSuperAdmin)
        const NavigationRailDestination(
          icon: Icon(Icons.people_outlined),
          selectedIcon: Icon(Icons.people),
          label: Text('Users'),
        ),
    ];

    void onDestinationSelected(int index) {
      switch (index) {
        case 0:
          Navigator.of(context).pushReplacementNamed('/dashboard');
          break;
        case 1:
          Navigator.of(context).pushReplacementNamed('/api-keys');
          break;
        case 2:
          Navigator.of(context).pushReplacementNamed('/posts');
          break;
        case 3:
          if (authProvider.isSuperAdmin) {
            Navigator.of(context).pushReplacementNamed('/users');
          }
          break;
      }
    }

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: true,
              selectedIndex: widget.currentIndex,
              onDestinationSelected: onDestinationSelected,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'AI Knowledge',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildUserMenu(authProvider),
                  ),
                ),
              ),
              destinations: railDestinations,
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: widget.child),
          ],
        ),
      );
    } else if (isTablet) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: widget.currentIndex,
              onDestinationSelected: onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              destinations: railDestinations,
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: widget.child),
          ],
        ),
        floatingActionButton: _buildUserFab(authProvider),
      );
    } else {
      return Scaffold(
        body: widget.child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: widget.currentIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: destinations,
        ),
        floatingActionButton: _buildUserFab(authProvider),
      );
    }
  }

  Widget _buildUserMenu(AuthProvider authProvider) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'logout') {
          await authProvider.logout();
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                authProvider.username ?? 'User',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              if (authProvider.isSuperAdmin)
                Text(
                  'Super Admin',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout),
              SizedBox(width: 8),
              Text('Logout'),
            ],
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              child: Text(
                (authProvider.username ?? 'U')[0].toUpperCase(),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  authProvider.username ?? 'User',
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                if (authProvider.isSuperAdmin)
                  Text(
                    'Super Admin',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
              ],
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildUserFab(AuthProvider authProvider) {
    return FloatingActionButton.small(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      (authProvider.username ?? 'U')[0].toUpperCase(),
                    ),
                  ),
                  title: Text(authProvider.username ?? 'User'),
                  subtitle: authProvider.isSuperAdmin
                      ? const Text('Super Admin')
                      : null,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () async {
                    Navigator.pop(context);
                    await authProvider.logout();
                    if (mounted) {
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: CircleAvatar(
        radius: 16,
        child: Text(
          (authProvider.username ?? 'U')[0].toUpperCase(),
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}

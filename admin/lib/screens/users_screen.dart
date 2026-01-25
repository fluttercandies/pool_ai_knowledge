import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/admin_user.dart';
import '../providers/auth_provider.dart';
import 'main_layout.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('User Management'),
        ),
        body: const _UsersContent(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showCreateUserDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('New Admin'),
        ),
      ),
    );
  }

  static void _showCreateUserDialog(BuildContext context) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    bool isSuperAdmin = false;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Admin User'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Super Admin'),
                  subtitle: const Text('Can manage other admins'),
                  value: isSuperAdmin,
                  onChanged: (value) {
                    setState(() {
                      isSuperAdmin = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final authProvider = context.read<AuthProvider>();
                  final success = await authProvider.createAdminUser(
                    AdminCreate(
                      username: usernameController.text,
                      password: passwordController.text,
                      isSuperAdmin: isSuperAdmin,
                    ),
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Admin user created successfully'
                              : authProvider.error ?? 'Failed to create user',
                        ),
                        backgroundColor:
                            success ? null : Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsersContent extends StatelessWidget {
  const _UsersContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'User Management',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'As a super admin, you can create new admin users. '
                    'Each admin user can manage API keys and posts. '
                    'Super admins can also create other admin users.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _ActionCard(
                icon: Icons.person_add,
                title: 'Create Admin',
                description: 'Add a new admin user',
                onTap: () => UsersScreen._showCreateUserDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

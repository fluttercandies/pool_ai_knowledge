import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/api_key_provider.dart';
import '../providers/post_provider.dart';
import 'main_layout.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApiKeyProvider>().loadApiKeys();
      context.read<PostProvider>().loadPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await context.read<ApiKeyProvider>().loadApiKeys();
            await context.read<PostProvider>().loadPosts();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: _buildDashboardContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    final authProvider = context.watch<AuthProvider>();
    final apiKeyProvider = context.watch<ApiKeyProvider>();
    final postProvider = context.watch<PostProvider>();
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome, ${authProvider.username ?? "Admin"}!',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),
        if (isDesktop)
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'API Keys',
                  apiKeyProvider.total.toString(),
                  Icons.key,
                  Colors.blue,
                  () => Navigator.of(context).pushReplacementNamed('/api-keys'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Posts',
                  postProvider.total.toString(),
                  Icons.article,
                  Colors.green,
                  () => Navigator.of(context).pushReplacementNamed('/posts'),
                ),
              ),
              if (authProvider.isSuperAdmin) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'User Management',
                    'Admin',
                    Icons.people,
                    Colors.orange,
                    () => Navigator.of(context).pushReplacementNamed('/users'),
                  ),
                ),
              ],
            ],
          )
        else
          Column(
            children: [
              _buildStatCard(
                'API Keys',
                apiKeyProvider.total.toString(),
                Icons.key,
                Colors.blue,
                () => Navigator.of(context).pushReplacementNamed('/api-keys'),
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                'Posts',
                postProvider.total.toString(),
                Icons.article,
                Colors.green,
                () => Navigator.of(context).pushReplacementNamed('/posts'),
              ),
              if (authProvider.isSuperAdmin) ...[
                const SizedBox(height: 16),
                _buildStatCard(
                  'User Management',
                  'Admin',
                  Icons.people,
                  Colors.orange,
                  () => Navigator.of(context).pushReplacementNamed('/users'),
                ),
              ],
            ],
          ),
        const SizedBox(height: 32),
        Text(
          'Recent Posts',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        if (postProvider.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (postProvider.posts.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('No posts yet')),
            ),
          )
        else
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: postProvider.posts.take(5).length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final post = postProvider.posts[index];
                return ListTile(
                  title: Text(post.title),
                  subtitle: Text(
                    post.summary ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Chip(
                    label: Text(
                      post.isPublished ? 'Published' : 'Draft',
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: post.isPublished
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.2),
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      '/posts/edit',
                      arguments: post.id,
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

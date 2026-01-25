import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../providers/post_provider.dart';
import 'main_layout.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().loadPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Posts'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => context.read<PostProvider>().loadPosts(),
            ),
          ],
        ),
        body: _buildBody(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.of(context).pushNamed('/posts/create'),
          icon: const Icon(Icons.add),
          label: const Text('New Post'),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final provider = context.watch<PostProvider>();

    if (provider.isLoading && provider.posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(provider.error!),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => provider.loadPosts(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (provider.posts.isEmpty) {
      return const Center(
        child: Text('No posts yet. Create one to get started.'),
      );
    }

    final isDesktop = MediaQuery.of(context).size.width > 800;

    if (isDesktop) {
      return _buildDataTable(provider);
    } else {
      return _buildListView(provider);
    }
  }

  Widget _buildDataTable(PostProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Title')),
              DataColumn(label: Text('Summary')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Created')),
              DataColumn(label: Text('Actions')),
            ],
            rows: provider.posts.map((post) {
              return DataRow(cells: [
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: Text(
                      post.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Text(
                      post.summary ?? '-',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  Chip(
                    label: Text(
                      post.isPublished ? 'Published' : 'Draft',
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: post.isPublished
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.2),
                  ),
                ),
                DataCell(Text(_formatDate(post.createdAt))),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            '/posts/edit',
                            arguments: post.id,
                          );
                        },
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _showDeleteDialog(post),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildListView(PostProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.loadPosts(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.posts.length,
        itemBuilder: (context, index) {
          final post = provider.posts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(post.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.summary != null)
                    Text(
                      post.summary!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    'Created: ${_formatDate(post.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Chip(
                    label: Text(
                      post.isPublished ? 'Published' : 'Draft',
                      style: const TextStyle(fontSize: 10),
                    ),
                    backgroundColor: post.isPublished
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.2),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.of(context).pushNamed(
                          '/posts/edit',
                          arguments: post.id,
                        );
                      } else if (value == 'delete') {
                        _showDeleteDialog(post);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              isThreeLine: post.summary != null,
              onTap: () {
                Navigator.of(context).pushNamed(
                  '/posts/edit',
                  arguments: post.id,
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showDeleteDialog(Post post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: Text('Are you sure you want to delete "${post.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              final provider = context.read<PostProvider>();
              final success = await provider.deletePost(post.id!);
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Post deleted')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

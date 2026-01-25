import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../providers/post_provider.dart';

class PostEditScreen extends StatefulWidget {
  final String? postId;

  const PostEditScreen({super.key, this.postId});

  @override
  State<PostEditScreen> createState() => _PostEditScreenState();
}

class _PostEditScreenState extends State<PostEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _summaryController = TextEditingController();
  final _tagsController = TextEditingController();
  bool _isPublished = false;
  bool _isLoading = false;

  bool get isEditing => widget.postId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadPost();
    }
  }

  Future<void> _loadPost() async {
    setState(() => _isLoading = true);
    final provider = context.read<PostProvider>();
    final success = await provider.loadPost(widget.postId!);
    if (success && provider.currentPost != null) {
      final post = provider.currentPost!;
      _titleController.text = post.title;
      _contentController.text = post.content;
      _summaryController.text = post.summary ?? '';
      _tagsController.text = post.tags?.join(', ') ?? '';
      _isPublished = post.isPublished;
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _summaryController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = context.read<PostProvider>();
    final tags = _tagsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    bool success;
    if (isEditing) {
      success = await provider.updatePost(
        widget.postId!,
        PostUpdate(
          title: _titleController.text,
          content: _contentController.text,
          summary: _summaryController.text.isEmpty ? null : _summaryController.text,
          tags: tags.isEmpty ? null : tags,
          isPublished: _isPublished,
        ),
      );
    } else {
      success = await provider.createPost(
        PostCreate(
          title: _titleController.text,
          content: _contentController.text,
          summary: _summaryController.text.isEmpty ? null : _summaryController.text,
          tags: tags.isEmpty ? null : tags,
          isPublished: _isPublished,
        ),
      );
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Post updated' : 'Post created'),
        ),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to save post'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Post' : 'Create Post'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton.icon(
              onPressed: _handleSave,
              icon: const Icon(Icons.save),
              label: const Text('Save'),
            ),
        ],
      ),
      body: _isLoading && isEditing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 32 : 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isDesktop ? 800 : double.infinity),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _summaryController,
                          decoration: const InputDecoration(
                            labelText: 'Summary',
                            border: OutlineInputBorder(),
                            helperText: 'Brief description of the post',
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _contentController,
                          decoration: const InputDecoration(
                            labelText: 'Content',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 15,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter content';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _tagsController,
                          decoration: const InputDecoration(
                            labelText: 'Tags',
                            border: OutlineInputBorder(),
                            helperText: 'Comma-separated tags',
                          ),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Published'),
                          subtitle: const Text('Make this post publicly visible'),
                          value: _isPublished,
                          onChanged: (value) {
                            setState(() {
                              _isPublished = value;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 24),
                        if (!isDesktop)
                          FilledButton(
                            onPressed: _isLoading ? null : _handleSave,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Save'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

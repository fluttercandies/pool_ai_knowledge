import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/api_key.dart';
import '../providers/api_key_provider.dart';
import 'main_layout.dart';

class ApiKeysScreen extends StatefulWidget {
  const ApiKeysScreen({super.key});

  @override
  State<ApiKeysScreen> createState() => _ApiKeysScreenState();
}

class _ApiKeysScreenState extends State<ApiKeysScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApiKeyProvider>().loadApiKeys();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('API Keys'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => context.read<ApiKeyProvider>().loadApiKeys(),
            ),
          ],
        ),
        body: _buildBody(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showCreateDialog(),
          icon: const Icon(Icons.add),
          label: const Text('New API Key'),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final provider = context.watch<ApiKeyProvider>();

    if (provider.isLoading && provider.apiKeys.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.apiKeys.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(provider.error!),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => provider.loadApiKeys(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (provider.apiKeys.isEmpty) {
      return const Center(
        child: Text('No API keys yet. Create one to get started.'),
      );
    }

    final isDesktop = MediaQuery.of(context).size.width > 800;

    if (isDesktop) {
      return _buildDataTable(provider);
    } else {
      return _buildListView(provider);
    }
  }

  Widget _buildDataTable(ApiKeyProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Key Prefix')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Created')),
              DataColumn(label: Text('Last Used')),
              DataColumn(label: Text('Actions')),
            ],
            rows: provider.apiKeys.map((key) {
              return DataRow(cells: [
                DataCell(Text(key.name)),
                DataCell(Text(key.keyPrefix ?? '-')),
                DataCell(
                  Chip(
                    label: Text(
                      key.isActive ? 'Active' : 'Inactive',
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: key.isActive
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.red.withValues(alpha: 0.2),
                  ),
                ),
                DataCell(Text(_formatDate(key.createdAt))),
                DataCell(Text(_formatDate(key.lastUsedAt))),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditDialog(key),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _showDeleteDialog(key),
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

  Widget _buildListView(ApiKeyProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.loadApiKeys(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.apiKeys.length,
        itemBuilder: (context, index) {
          final key = provider.apiKeys[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(key.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Prefix: ${key.keyPrefix ?? "-"}'),
                  Text('Created: ${_formatDate(key.createdAt)}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Chip(
                    label: Text(
                      key.isActive ? 'Active' : 'Inactive',
                      style: const TextStyle(fontSize: 10),
                    ),
                    backgroundColor: key.isActive
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.red.withValues(alpha: 0.2),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditDialog(key);
                      } else if (value == 'delete') {
                        _showDeleteDialog(key);
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
              isThreeLine: true,
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

  void _showCreateDialog() {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create API Key'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
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
                final provider = context.read<ApiKeyProvider>();
                final success = await provider.createApiKey(
                  ApiKeyCreate(name: nameController.text),
                );
                if (success && mounted) {
                  Navigator.pop(context);
                  _showCreatedKeyDialog(provider.lastCreatedKey!);
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showCreatedKeyDialog(ApiKey apiKey) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('API Key Created'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please copy your API key now. You won\'t be able to see it again!',
              style: TextStyle(color: Colors.orange),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      apiKey.key ?? '',
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: apiKey.key ?? ''));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              context.read<ApiKeyProvider>().clearLastCreatedKey();
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(ApiKey apiKey) {
    final nameController = TextEditingController(text: apiKey.name);
    bool isActive = apiKey.isActive;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit API Key'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Active'),
                  value: isActive,
                  onChanged: (value) {
                    setState(() {
                      isActive = value;
                    });
                  },
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
                  final provider = context.read<ApiKeyProvider>();
                  final success = await provider.updateApiKey(
                    apiKey.id!,
                    ApiKeyUpdate(name: nameController.text, isActive: isActive),
                  );
                  if (success && mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('API key updated')),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(ApiKey apiKey) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete API Key'),
        content: Text('Are you sure you want to delete "${apiKey.name}"?'),
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
              final provider = context.read<ApiKeyProvider>();
              final success = await provider.deleteApiKey(apiKey.id!);
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('API key deleted')),
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

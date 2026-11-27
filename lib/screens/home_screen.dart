import 'package:flutter/material.dart';
import '../models/entry.dart';
import '../utils/storage.dart';
import '../widgets/entry_card.dart';
import 'create_entery_screen.dart';
import 'create_entry_screen.dart';
import 'entry_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Entry> _entries = [];
  bool _loading = true;
  String _searchQuery = '';
  String? _selectedId; // the card that is currently bigger

  @override
  void initState() {
    super.initState();
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final saved = await loadEntries();
    if (!mounted) return;
    setState(() {
      _entries = saved;
      _loading = false;
    });
  }

  List<Entry> get _filteredEntries {
    if (_searchQuery.isEmpty) return _entries;
    final query = _searchQuery.toLowerCase();
    return _entries.where((entry) {
      return entry.title.toLowerCase().contains(query) ||
          entry.text.toLowerCase().contains(query) ||
          entry.tags.any((tag) => tag.toLowerCase().contains(query));
    }).toList();
  }

  Future<void> _openCreateScreen() async {
    final newEntry = await Navigator.push<Entry>(
      context,
      MaterialPageRoute(builder: (context) => const CreateEntryScreen()),
    );
    if (newEntry != null) {
      setState(() {
        _entries.insert(0, newEntry);
        _entries.sort((a, b) => b.date.compareTo(a.date));
      });
      saveEntries(_entries);
    }
  }

  // Called by the detail screen after an edit.
  void _updateEntry(Entry updated) {
    setState(() {
      final index = _entries.indexWhere((e) => e.id == updated.id);
      if (index != -1) _entries[index] = updated;
      _entries.sort((a, b) => b.date.compareTo(a.date));
    });
    saveEntries(_entries);
  }

  // Called by the detail screen after a delete.
  void _deleteEntry(String id) {
    setState(() {
      _entries.removeWhere((e) => e.id == id);
      if (_selectedId == id) _selectedId = null;
    });
    saveEntries(_entries);
  }

  void _openDetail(Entry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EntryDetailScreen(
          entry: entry,
          onUpdate: _updateEntry,
          onDelete: _deleteEntry,
        ),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    bool showButton = false,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: Colors.grey)),
            if (showButton) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: _openCreateScreen,
                child: const Text('Create your first memory'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeed() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final entries = _filteredEntries;

    if (_entries.isEmpty) {
      return _buildEmptyState(
        icon: Icons.auto_stories_outlined,
        title: 'No memories yet.',
        subtitle: 'Tap + to create your first one!',
        showButton: true,
      );
    }
    if (entries.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off,
        title: 'No results',
        subtitle: 'Try a different search word.',
      );
    }

    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Dismissible(
          key: ValueKey(entry.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete entry?'),
                content: const Text('This cannot be undone.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ) ??
                false;
          },
          onDismissed: (direction) => _deleteEntry(entry.id),
          child: EntryCard(
            entry: entry,
            isSelected: _selectedId == entry.id,
            onTap: () {
              setState(() {
                _selectedId = (_selectedId == entry.id) ? null : entry.id;
              });
            },
            onOpen: () => _openDetail(entry),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _entries.isEmpty
              ? 'Memory Cards'
              : 'Memory Cards (${_entries.length})',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search memories...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(child: _buildFeed()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateScreen,
        tooltip: 'Add memory',
        child: const Icon(Icons.add),
      ),
    );
  }
}

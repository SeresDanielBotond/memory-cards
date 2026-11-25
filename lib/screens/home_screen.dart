import 'package:flutter/material.dart';
import 'package:memory_cards/screens/create_entery_screen.dart';
import '../models/entry.dart';
import '../utils/storage.dart';
import '../widgets/entry_card.dart';
import 'settings_screen.dart' show SettingsScreen;


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Stage 3: starts empty, filled from storage in initState.
  List<Entry> _entries = [];
  bool _loading = true;

  // Stage 5 Track B: current search text.
  String _searchQuery = '';

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

  // Stage 5 Track B: entries that match the search text (title, text or tag).
  List<Entry> get _filteredEntries {
    if (_searchQuery.isEmpty) return _entries;
    final query = _searchQuery.toLowerCase();
    return _entries.where((entry) {
      return entry.title.toLowerCase().contains(query) ||
          entry.text.toLowerCase().contains(query) ||
          entry.tags.any((tag) => tag.toLowerCase().contains(query));
    }).toList();
  }

  // Stage 2: open the create screen and wait for the new Entry.
  Future<void> _openCreateScreen() async {
    final newEntry = await Navigator.push<Entry>(
      context,
      MaterialPageRoute(builder: (context) => const CreateEntryScreen()),
    );
    if (newEntry != null) {
      setState(() {
        _entries.insert(0, newEntry);
        _entries.sort((a, b) => b.date.compareTo(a.date)); // newest first
      });
      saveEntries(_entries); // Stage 3: save after adding
    }
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
            Text(title, style: const TextStyle(fontSize: 18, color: Colors.grey)),
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
        // Stage 3: swipe left to delete.
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
          onDismissed: (direction) {
            // Remove by id, so it is correct even while a search is active.
            setState(() => _entries.removeWhere((e) => e.id == entry.id));
            saveEntries(_entries);
          },
          child: EntryCard(entry: entry),
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
          // Stage 5 Track B: search field.
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

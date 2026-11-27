import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/entry.dart';
import 'create_entery_screen.dart';
import 'create_entry_screen.dart';

// The opened memory: photos you can swipe sideways, full text, edit, delete.
class EntryDetailScreen extends StatefulWidget {
  final Entry entry;
  final void Function(Entry updated) onUpdate; // told when edited
  final void Function(String id) onDelete; // told when deleted

  const EntryDetailScreen({
    super.key,
    required this.entry,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<EntryDetailScreen> createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen> {
  late Entry _entry;
  int _page = 0; // which photo is visible

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
  }

  Future<void> _edit() async {
    final updated = await Navigator.push<Entry>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEntryScreen(entry: _entry),
      ),
    );
    if (updated != null) {
      setState(() {
        _entry = updated;
        _page = 0;
      });
      widget.onUpdate(updated); // tell the home screen so it saves
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
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
    );
    if (confirm == true) {
      widget.onDelete(_entry.id);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  Color _tagColor(String tag) {
    const colors = {
      'Travel': Colors.blue,
      'Food': Colors.orange,
      'Erasmus': Colors.purple,
      'Ideas': Colors.green,
      'Culture': Colors.red,
      'Other': Colors.grey,
    };
    return colors[tag] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final images = _entry.imagePaths;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: _edit,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete',
            onPressed: _delete,
          ),
        ],
      ),
      body: ListView(
        children: [
          // Swipe left / right to see all photos.
          if (images.isNotEmpty)
            SizedBox(
              height: 300,
              child: Stack(
                children: [
                  PageView.builder(
                    key: ValueKey(images.join('|')),
                    itemCount: images.length,
                    onPageChanged: (index) => setState(() => _page = index),
                    itemBuilder: (context, index) {
                      return Image.file(
                        File(images[index]),
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Container(
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: Icon(Icons.broken_image_outlined, size: 48),
                          ),
                        ),
                      );
                    },
                  ),
                  if (images.length > 1)
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_page + 1} / ${images.length}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _entry.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('EEEE, d MMMM yyyy').format(_entry.date),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _entry.text.isEmpty
                    ? const Text('No description',
                    style: TextStyle(color: Colors.grey))
                    : Text(_entry.text, style: const TextStyle(fontSize: 17)),
                if (_entry.tags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _entry.tags
                        .map(
                          (tag) => Chip(
                        label: Text(tag),
                        backgroundColor:
                        _tagColor(tag).withValues(alpha: 0.2),
                        side: BorderSide(color: _tagColor(tag)),
                      ),
                    )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

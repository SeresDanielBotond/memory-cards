import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../data/sample_entries.dart'; // for availableTags
import '../models/entry.dart';

class CreateEntryScreen extends StatefulWidget {
  const CreateEntryScreen({super.key});

  @override
  State<CreateEntryScreen> createState() => _CreateEntryScreenState();
}

class _CreateEntryScreenState extends State<CreateEntryScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  final Set<String> _selectedTags = {}; // Stage 4
  String? _imagePath;

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // Stage 5 Track A: choose a photo from the gallery.
  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _imagePath = picked.path);
    }
  }

  void _save() {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a title'),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    final newEntry = Entry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      text: _textController.text.trim(),
      date: _selectedDate,
      tags: _selectedTags.toList(),
      imagePath: _imagePath,
    );

    Navigator.pop(context, newEntry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Memory'),
        actions: [
          TextButton(
              onPressed: _save
              , child: const Text('Save')
          ),
        ],
      ),
      // ListView (not Column) so the form scrolls when the keyboard opens.
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'Give this memory a name',
              prefixIcon: Icon(Icons.title),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _textController,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'What happened?',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(DateFormat('EEE, d MMM yyyy').format(_selectedDate)),
            ),
          ),
          // Stage 4: tag selection.
          const SizedBox(height: 16),
          Text(
            _selectedTags.isEmpty
                ? 'Tags'
                : 'Tags (${_selectedTags.length} selected)',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: availableTags.map((tag) {
              return FilterChip(
                label: Text(tag),
                selected: _selectedTags.contains(tag),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTags.add(tag);
                    } else {
                      _selectedTags.remove(tag);
                    }
                  });
                },
              );
            }).toList(),
          ),
          // Stage 5 Track A: photo preview or "Add Photo" button.
          const SizedBox(height: 16),
          if (_imagePath != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_imagePath!),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: _pickPhoto,
                  child: const Text('Change photo'),
                ),
                TextButton(
                  onPressed: () => setState(() => _imagePath = null),
                  child: const Text('Remove photo'),
                ),
              ],
            ),
          ] else
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _pickPhoto,
                icon: const Icon(Icons.photo_library),
                label: const Text('Add Photo'),
              ),
            ),
        ],
      ),
    );
  }
}

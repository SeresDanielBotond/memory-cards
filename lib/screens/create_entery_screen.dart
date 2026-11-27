import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../data/sample_entries.dart'; // for availableTags
import '../models/entry.dart';

// Used for BOTH creating a new memory and editing an existing one.
// entry == null  -> new memory
// entry != null  -> edit that memory
class CreateEntryScreen extends StatefulWidget {
  final Entry? entry;

  const CreateEntryScreen({super.key, this.entry});

  @override
  State<CreateEntryScreen> createState() => _CreateEntryScreenState();
}

class _CreateEntryScreenState extends State<CreateEntryScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _textController;
  late DateTime _selectedDate;
  late final Set<String> _selectedTags;
  late List<String> _imagePaths;

  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    // When editing, start with the values of the existing memory.
    _titleController = TextEditingController(text: e?.title ?? '');
    _textController = TextEditingController(text: e?.text ?? '');
    _selectedDate = e?.date ?? DateTime.now();
    _selectedTags = {...?e?.tags};
    _imagePaths = [...?e?.imagePaths];
  }

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

  // Choose several photos at once and ADD them to the list.
  Future<void> _addPhotos() async {
    final picked = await ImagePicker().pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;
    setState(() {
      for (final file in picked) {
        if (!_imagePaths.contains(file.path)) {
          _imagePaths.add(file.path);
        }
      }
    });
  }

  void _removePhoto(int index) {
    setState(() => _imagePaths.removeAt(index));
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

    final Entry result;
    if (_isEditing) {
      // Same id, new values.
      result = widget.entry!.copyWith(
        title: title,
        text: _textController.text.trim(),
        date: _selectedDate,
        tags: _selectedTags.toList(),
        imagePaths: _imagePaths,
      );
    } else {
      result = Entry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        text: _textController.text.trim(),
        date: _selectedDate,
        tags: _selectedTags.toList(),
        imagePaths: _imagePaths,
      );
    }

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Memory' : 'New Memory'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
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
          const SizedBox(height: 16),
          Text(
            _imagePaths.isEmpty
                ? 'Photos'
                : 'Photos (${_imagePaths.length})',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Photos in a row you can scroll sideways. X removes a photo.
          if (_imagePaths.isNotEmpty)
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _imagePaths.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_imagePaths[index]),
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) => Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removePhoto(index),
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.black54,
                            child: Icon(Icons.close,
                                size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _addPhotos,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Add photos'),
            ),
          ),
        ],
      ),
    );
  }
}

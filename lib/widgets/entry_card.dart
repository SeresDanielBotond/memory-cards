import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/entry.dart';

// A single card shown in the feed for one Entry.
class EntryCard extends StatelessWidget {
  final Entry entry;

  const EntryCard({super.key, required this.entry});

  // Stage 4: each tag gets its own color.
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
    // Stage 1: format the date once and reuse it.
    final dateString = DateFormat('EEE, d MMM').format(entry.date);

    return Card(
      // Stage 1: card styling.
      elevation: 4,
      color: Colors.deepPurple.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Color bar on the left edge.
            Container(width: 4, color: Colors.deepPurple),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stage 5 Track A: photo thumbnail at the top.
                    if (entry.imagePath != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(entry.imagePath!),
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          // If the file was cleaned up, show a placeholder.
                          errorBuilder: (context, error, stack) => Container(
                            height: 160,
                            width: double.infinity,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    // Stage 1: title on the left, date on the right.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            entry.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                              fontSize: 20,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.auto_stories,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          dateString,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.deepPurple.shade300,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Text preview, or a grey hint if there is none (Stage 6).
                    entry.text.isEmpty
                        ? const Text(
                      'No description',
                      style: TextStyle(color: Colors.grey),
                    )
                        : Text(
                      entry.text,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Stage 4: tag chips.
                    if (entry.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: entry.tags
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
            ),
          ],
        ),
      ),
    );
  }
}

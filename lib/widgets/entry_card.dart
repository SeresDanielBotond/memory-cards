import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/entry.dart';

// A card in the feed. Tap = grow. When grown, the "Open" button opens it.
class EntryCard extends StatelessWidget {
  final Entry entry;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onOpen;

  const EntryCard({
    super.key,
    required this.entry,
    this.isSelected = false,
    this.onTap,
    this.onOpen,
  });

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
    final dateString = DateFormat('EEE, d MMM').format(entry.date);
    final double imageHeight = isSelected ? 240 : 160;

    return Card(
      elevation: isSelected ? 12 : 4,
      color: isSelected ? Colors.deepPurple.shade100 : Colors.deepPurple.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.symmetric(
        horizontal: isSelected ? 4 : 12,
        vertical: isSelected ? 10 : 6,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: isSelected ? 8 : 4, color: Colors.deepPurple),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(isSelected ? 20 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // First photo, with a "+N" badge if there are more.
                        if (entry.imagePaths.isNotEmpty) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              children: [
                                Image.file(
                                  File(entry.imagePaths.first),
                                  height: imageHeight,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stack) =>
                                      Container(
                                        height: imageHeight,
                                        width: double.infinity,
                                        color: Colors.grey.shade300,
                                        child:
                                        const Icon(Icons.broken_image_outlined),
                                      ),
                                ),
                                if (entry.imagePaths.length > 1)
                                  Positioned(
                                    right: 8,
                                    bottom: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.photo_library,
                                              size: 14, color: Colors.white),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${entry.imagePaths.length}',
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                entry.title,
                                maxLines: isSelected ? null : 1,
                                overflow: isSelected
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                  fontSize: isSelected ? 24 : 20,
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
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.deepPurple.shade300),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        entry.text.isEmpty
                            ? const Text('No description',
                            style: TextStyle(color: Colors.grey))
                            : Text(
                          entry.text,
                          maxLines: isSelected ? null : 3,
                          overflow: isSelected
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                          style:
                          TextStyle(fontSize: isSelected ? 17 : 14),
                        ),
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
                        // The "Open" button only shows on the selected card.
                        if (isSelected && onOpen != null)
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.icon(
                              onPressed: onOpen,
                              icon: const Icon(Icons.open_in_full),
                              label: const Text('Open'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

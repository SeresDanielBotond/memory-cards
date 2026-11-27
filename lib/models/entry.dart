// One memory. Now it can hold MANY photos (imagePaths).
class Entry {
  final String id;
  final String title;
  final String text;
  final DateTime date;
  final List<String> tags;
  final List<String> imagePaths; // all photos of this memory

  const Entry({
    required this.id,
    required this.title,
    required this.text,
    required this.date,
    this.tags = const [],
    this.imagePaths = const [],
  });

  // First photo (or null). Keeps older code working.
  String? get imagePath => imagePaths.isEmpty ? null : imagePaths.first;

  // Makes a changed copy of this entry (used when editing).
  Entry copyWith({
    String? title,
    String? text,
    DateTime? date,
    List<String>? tags,
    List<String>? imagePaths,
  }) {
    return Entry(
      id: id,
      title: title ?? this.title,
      text: text ?? this.text,
      date: date ?? this.date,
      tags: tags ?? this.tags,
      imagePaths: imagePaths ?? this.imagePaths,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'text': text,
    'date': date.toIso8601String(),
    'tags': tags,
    'imagePaths': imagePaths,
  };

  factory Entry.fromJson(Map<String, dynamic> json) {
    // The date may be saved as text or as a number (older versions).
    final rawDate = json['date'];
    final DateTime date = rawDate is int
        ? DateTime.fromMillisecondsSinceEpoch(rawDate)
        : DateTime.parse(rawDate as String);

    // Older saves had ONE photo in 'imagePath'. Still supported.
    List<String> images = [];
    if (json['imagePaths'] != null) {
      images = List<String>.from(json['imagePaths']);
    } else if (json['imagePath'] != null) {
      images = [json['imagePath'] as String];
    }

    return Entry(
      id: json['id'].toString(),
      title: json['title'] as String? ?? '',
      text: json['text'] as String? ?? '',
      date: date,
      tags: List<String>.from(json['tags'] ?? []),
      imagePaths: images,
    );
  }
}

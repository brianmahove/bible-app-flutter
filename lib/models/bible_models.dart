class Translation {
  final String code;
  final String name;
  final String language;

  Translation({required this.code, required this.name, required this.language});

  factory Translation.fromJson(dynamic json) {
    // Convert to Map<String, dynamic> if it's Map<dynamic, dynamic>
    final Map<String, dynamic> jsonMap = _convertToStringMap(json);

    return Translation(
      code: jsonMap['code'] ?? jsonMap['id'] ?? jsonMap['translation'] ?? '',
      name:
          jsonMap['name'] ??
          jsonMap['title'] ??
          jsonMap['translation_name'] ??
          '',
      language: jsonMap['language'] ?? jsonMap['lang'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'name': name, 'language': language};
  }
}

class Book {
  final String id;
  final String name;
  final int chapters;

  Book({required this.id, required this.name, required this.chapters});

  factory Book.fromJson(dynamic json) {
    // Convert to Map<String, dynamic> if it's Map<dynamic, dynamic>
    final Map<String, dynamic> jsonMap = _convertToStringMap(json);

    // Debug the JSON structure to see what we're getting
    print('=== BOOK JSON DEBUG ===');
    print('Raw JSON keys: ${jsonMap.keys}');
    print('Raw JSON values: ${jsonMap.values}');

    // Extract book ID and name
    String id = '';
    String name = '';
    int chapters = 0;

    // Try different possible ID fields
    id =
        jsonMap['id'] ??
        jsonMap['book'] ??
        jsonMap['book_id'] ??
        jsonMap['abbreviation'] ??
        jsonMap['short_name'] ??
        '';

    // Try different possible name fields
    name =
        jsonMap['name'] ??
        jsonMap['title'] ??
        jsonMap['book_name'] ??
        jsonMap['long_name'] ??
        jsonMap['full_name'] ??
        'Unknown Book';

    // The API might have chapters in a nested structure or different field
    // Let's check if there's a chapters array that we can count
    if (jsonMap['chapters'] is List) {
      chapters = (jsonMap['chapters'] as List).length;
      print('Chapters from list count: $chapters');
    }
    // Try different chapter count field names
    else if (jsonMap['chapters'] != null) {
      chapters = _parseChapterCount(jsonMap['chapters']);
      print('Chapters from field: $chapters');
    } else if (jsonMap['chapter_count'] != null) {
      chapters = _parseChapterCount(jsonMap['chapter_count']);
      print('Chapters from chapter_count: $chapters');
    } else if (jsonMap['total_chapters'] != null) {
      chapters = _parseChapterCount(jsonMap['total_chapters']);
      print('Chapters from total_chapters: $chapters');
    } else if (jsonMap['count'] != null) {
      chapters = _parseChapterCount(jsonMap['count']);
      print('Chapters from count: $chapters');
    } else if (jsonMap['num_chapters'] != null) {
      chapters = _parseChapterCount(jsonMap['num_chapters']);
      print('Chapters from num_chapters: $chapters');
    }

    // If we still have 0 chapters, check for any numeric fields that might be chapter count
    if (chapters == 0) {
      for (var key in jsonMap.keys) {
        if (jsonMap[key] is int && jsonMap[key] > 0 && jsonMap[key] < 200) {
          print('Potential chapter field: $key = ${jsonMap[key]}');
          // Common book chapter counts are between 1-150
          if (jsonMap[key] is int &&
              (jsonMap[key] as int) > 0 &&
              (jsonMap[key] as int) <= 150) {
            chapters = jsonMap[key] as int;
            print('Using $key as chapter count: $chapters');
            break;
          }
        }
      }
    }

    print('Final: ID: $id, Name: $name, Chapters: $chapters');

    return Book(id: id, name: name, chapters: chapters);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'chapters': chapters};
  }
}

class Chapter {
  final String translation;
  final String book;
  final int chapter;
  final List<Verse> verses;

  Chapter({
    required this.translation,
    required this.book,
    required this.chapter,
    required this.verses,
  });

  factory Chapter.fromJson(dynamic json) {
    // Convert to Map<String, dynamic> if it's Map<dynamic, dynamic>
    final Map<String, dynamic> jsonMap = _convertToStringMap(json);

    List<Verse> verses = [];
    if (jsonMap['verses'] != null && jsonMap['verses'] is List) {
      final List<dynamic> versesList = jsonMap['verses'] as List;
      verses = versesList.map((v) => Verse.fromJson(v)).toList();
    }

    return Chapter(
      translation: jsonMap['translation'] ?? '',
      book: jsonMap['book'] ?? '',
      chapter: jsonMap['chapter'] ?? 0,
      verses: verses,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'translation': translation,
      'book': book,
      'chapter': chapter,
      'verses': verses.map((v) => v.toJson()).toList(),
    };
  }
}

class Verse {
  final int verse;
  final String text;

  Verse({required this.verse, required this.text});

  factory Verse.fromJson(dynamic json) {
    // Convert to Map<String, dynamic> if it's Map<dynamic, dynamic>
    final Map<String, dynamic> jsonMap = _convertToStringMap(json);

    return Verse(verse: jsonMap['verse'] ?? 0, text: jsonMap['text'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'verse': verse, 'text': text};
  }
}

class Bookmark {
  final int? id;
  final String translation;
  final String book;
  final int chapter;
  final int verse;
  final String note;
  final DateTime createdAt;

  Bookmark({
    this.id,
    required this.translation,
    required this.book,
    required this.chapter,
    required this.verse,
    this.note = '',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'translation': translation,
      'book': book,
      'chapter': chapter,
      'verse': verse,
      'note': note,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'],
      translation: json['translation'],
      book: json['book'],
      chapter: json['chapter'],
      verse: json['verse'],
      note: json['note'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
    );
  }
}

class Commentary {
  final String id;
  final String name;
  final String description;

  Commentary({required this.id, required this.name, required this.description});

  factory Commentary.fromJson(dynamic json) {
    // Convert to Map<String, dynamic> if it's Map<dynamic, dynamic>
    final Map<String, dynamic> jsonMap = _convertToStringMap(json);

    return Commentary(
      id: jsonMap['id'] ?? jsonMap['commentary_id'] ?? jsonMap['slug'] ?? '',
      name:
          jsonMap['name'] ??
          jsonMap['title'] ??
          jsonMap['commentary_name'] ??
          '',
      description:
          jsonMap['description'] ?? jsonMap['desc'] ?? jsonMap['about'] ?? '',
    );
  }
}

class CommentaryChapter {
  final String commentary;
  final String book;
  final int chapter;
  final String content;

  CommentaryChapter({
    required this.commentary,
    required this.book,
    required this.chapter,
    required this.content,
  });

  factory CommentaryChapter.fromJson(dynamic json) {
    // Convert to Map<String, dynamic> if it's Map<dynamic, dynamic>
    final Map<String, dynamic> jsonMap = _convertToStringMap(json);

    return CommentaryChapter(
      commentary: jsonMap['commentary'] ?? '',
      book: jsonMap['book'] ?? '',
      chapter: jsonMap['chapter'] ?? 0,
      content: jsonMap['content'] ?? '',
    );
  }
}

class DownloadedContent {
  final int? id;
  final String translation;
  final String book;
  final int? chapter;
  final String content;
  final DateTime downloadedAt;
  final int size; // in bytes

  DownloadedContent({
    this.id,
    required this.translation,
    required this.book,
    this.chapter,
    required this.content,
    required this.downloadedAt,
    required this.size,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'translation': translation,
      'book': book,
      'chapter': chapter,
      'content': content,
      'downloadedAt': downloadedAt.millisecondsSinceEpoch,
      'size': size,
    };
  }

  factory DownloadedContent.fromJson(Map<String, dynamic> json) {
    return DownloadedContent(
      id: json['id'],
      translation: json['translation'],
      book: json['book'],
      chapter: json['chapter'],
      content: json['content'],
      downloadedAt: DateTime.fromMillisecondsSinceEpoch(json['downloadedAt']),
      size: json['size'] ?? 0,
    );
  }
}

class DownloadProgress {
  final String translation;
  final String book;
  final int currentChapter;
  final int totalChapters;
  final double progress;
  final DownloadStatus status;

  DownloadProgress({
    required this.translation,
    required this.book,
    required this.currentChapter,
    required this.totalChapters,
    required this.progress,
    required this.status,
  });
}

enum DownloadStatus { downloading, completed, error, queued, paused }

class OfflineTranslation {
  final String code;
  final String name;
  final String language;
  final int totalSize;
  final int downloadedBooks;
  final int totalBooks;
  final DateTime downloadedAt;

  OfflineTranslation({
    required this.code,
    required this.name,
    required this.language,
    required this.totalSize,
    required this.downloadedBooks,
    required this.totalBooks,
    required this.downloadedAt,
  });
}

// Helper function to convert Map<dynamic, dynamic> to Map<String, dynamic>
Map<String, dynamic> _convertToStringMap(dynamic json) {
  if (json is Map<String, dynamic>) {
    return json;
  } else if (json is Map<dynamic, dynamic>) {
    return json.map<String, dynamic>(
      (key, value) => MapEntry(key.toString(), value),
    );
  } else {
    return {};
  }
}

// Helper to parse chapter count from various types
int _parseChapterCount(dynamic chapterData) {
  if (chapterData is int) {
    return chapterData;
  } else if (chapterData is String) {
    return int.tryParse(chapterData) ?? 0;
  } else if (chapterData is double) {
    return chapterData.toInt();
  }
  return 0;
}

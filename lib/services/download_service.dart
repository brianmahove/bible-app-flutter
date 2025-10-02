import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'bible_api.dart';
import '../models/bible_models.dart';

class DownloadService {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  final Map<String, CancelToken> _cancelTokens = {};
  final StreamController<DownloadProgress> _progressController =
      StreamController<DownloadProgress>.broadcast();

  Stream<DownloadProgress> get progressStream => _progressController.stream;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _getLocalFile(
    String translation,
    String book,
    int chapter,
  ) async {
    final localPath = await _localPath;
    final fileName = '$translation-$book-$chapter.json';
    return File(
      path.join(localPath, 'bible_data', translation, book, fileName),
    );
  }

  Future<File> _getTranslationInfoFile(String translation) async {
    final localPath = await _localPath;
    return File(
      path.join(localPath, 'bible_data', translation, 'translation_info.json'),
    );
  }

  Future<bool> isTranslationDownloaded(String translation) async {
    try {
      final infoFile = await _getTranslationInfoFile(translation);
      return await infoFile.exists();
    } catch (e) {
      return false;
    }
  }

  Future<bool> isBookDownloaded(String translation, String book) async {
    try {
      final localPath = await _localPath;
      final bookDir = Directory(
        path.join(localPath, 'bible_data', translation, book),
      );
      if (await bookDir.exists()) {
        final files = await bookDir.list().toList();
        return files.whereType<File>().isNotEmpty;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> downloadTranslation(
    String translation, {
    Function(DownloadProgress)? onProgress,
    Function()? onComplete,
    Function(String)? onError,
  }) async {
    try {
      // Get books for this translation
      final books = await BibleApi.getBooks(translation);

      for (final book in books) {
        await downloadBook(
          translation,
          book.id,
          onProgress: onProgress,
          onComplete: onComplete,
          onError: onError,
        );
      }

      // Save translation info
      await _saveTranslationInfo(translation, books.length);

      onComplete?.call();
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  Future<void> downloadBook(
    String translation,
    String bookId, {
    Function(DownloadProgress)? onProgress,
    Function()? onComplete,
    Function(String)? onError,
  }) async {
    try {
      // Get book info to know number of chapters
      final books = await BibleApi.getBooks(translation);
      final book = books.firstWhere((b) => b.id == bookId);

      for (int chapter = 1; chapter <= book.chapters; chapter++) {
        final progress = DownloadProgress(
          translation: translation,
          book: bookId,
          currentChapter: chapter,
          totalChapters: book.chapters,
          progress: (chapter - 1) / book.chapters,
          status: DownloadStatus.downloading,
        );

        _progressController.add(progress);
        onProgress?.call(progress);

        await downloadChapter(translation, bookId, chapter);

        // Small delay to prevent overwhelming the API
        await Future.delayed(Duration(milliseconds: 100));
      }

      final completedProgress = DownloadProgress(
        translation: translation,
        book: bookId,
        currentChapter: book.chapters,
        totalChapters: book.chapters,
        progress: 1.0,
        status: DownloadStatus.completed,
      );

      _progressController.add(completedProgress);
      onComplete?.call();
    } catch (e) {
      final errorProgress = DownloadProgress(
        translation: translation,
        book: bookId,
        currentChapter: 0,
        totalChapters: 0,
        progress: 0.0,
        status: DownloadStatus.error,
      );

      _progressController.add(errorProgress);
      onError?.call(e.toString());
    }
  }

  Future<void> downloadChapter(
    String translation,
    String book,
    int chapter,
  ) async {
    try {
      final chapterData = await BibleApi.getChapter(translation, book, chapter);
      final file = await _getLocalFile(translation, book, chapter);

      // Ensure directory exists
      await file.parent.create(recursive: true);

      // Save chapter data
      await file.writeAsString(json.encode(chapterData.toJson()));
    } catch (e) {
      throw Exception('Failed to download chapter: $e');
    }
  }

  Future<Chapter?> getOfflineChapter(
    String translation,
    String book,
    int chapter,
  ) async {
    try {
      final file = await _getLocalFile(translation, book, chapter);
      if (await file.exists()) {
        final content = await file.readAsString();
        final Map<String, dynamic> data = json.decode(content);
        return Chapter.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<OfflineTranslation>> getDownloadedTranslations() async {
    final List<OfflineTranslation> translations = [];
    try {
      final localPath = await _localPath;
      final bibleDataDir = Directory(path.join(localPath, 'bible_data'));

      if (await bibleDataDir.exists()) {
        final translationDirs = await bibleDataDir.list().toList();

        for (final dir in translationDirs) {
          if (dir is Directory) {
            final translation = path.basename(dir.path);
            final infoFile = await _getTranslationInfoFile(translation);

            if (await infoFile.exists()) {
              final content = await infoFile.readAsString();
              final info = json.decode(content);

              // Calculate total size
              int totalSize = 0;
              int downloadedBooks = 0;

              final bookDirs = await dir.list().toList();
              for (final bookDir in bookDirs) {
                if (bookDir is Directory) {
                  downloadedBooks++;
                  final files = await bookDir.list().toList();
                  for (final file in files) {
                    if (file is File) {
                      final stat = await file.stat();
                      totalSize += stat.size;
                    }
                  }
                }
              }

              translations.add(
                OfflineTranslation(
                  code: translation,
                  name: info['name'] ?? translation,
                  language: info['language'] ?? 'Unknown',
                  totalSize: totalSize,
                  downloadedBooks: downloadedBooks,
                  totalBooks: info['totalBooks'] ?? 0,
                  downloadedAt: DateTime.fromMillisecondsSinceEpoch(
                    info['downloadedAt'],
                  ),
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      print('Error getting downloaded translations: $e');
    }

    return translations;
  }

  Future<int> getOfflineContentSize() async {
    try {
      final localPath = await _localPath;
      final bibleDataDir = Directory(path.join(localPath, 'bible_data'));

      if (await bibleDataDir.exists()) {
        int totalSize = 0;
        await for (final file in bibleDataDir.list(recursive: true)) {
          if (file is File) {
            final stat = await file.stat();
            totalSize += stat.size;
          }
        }
        return totalSize;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<void> deleteTranslation(String translation) async {
    try {
      final localPath = await _localPath;
      final translationDir = Directory(
        path.join(localPath, 'bible_data', translation),
      );
      if (await translationDir.exists()) {
        await translationDir.delete(recursive: true);
      }
    } catch (e) {
      throw Exception('Failed to delete translation: $e');
    }
  }

  Future<void> deleteBook(String translation, String book) async {
    try {
      final localPath = await _localPath;
      final bookDir = Directory(
        path.join(localPath, 'bible_data', translation, book),
      );
      if (await bookDir.exists()) {
        await bookDir.delete(recursive: true);
      }
    } catch (e) {
      throw Exception('Failed to delete book: $e');
    }
  }

  void cancelDownload(String translation, String book) {
    final key = '$translation-$book';
    _cancelTokens[key]?.cancel();
    _cancelTokens.remove(key);
  }

  Future<void> _saveTranslationInfo(String translation, int totalBooks) async {
    final infoFile = await _getTranslationInfoFile(translation);
    final info = {
      'name': translation,
      'language':
          'English', // You might want to get this from the translation list
      'totalBooks': totalBooks,
      'downloadedAt': DateTime.now().millisecondsSinceEpoch,
    };

    await infoFile.parent.create(recursive: true);
    await infoFile.writeAsString(json.encode(info));
  }

  void dispose() {
    _progressController.close();
  }
}

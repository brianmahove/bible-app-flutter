import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/bible_models.dart';
import '../services/bible_api.dart';
import '../services/database_service.dart';
import '../services/download_service.dart';

class BibleProvider with ChangeNotifier {
  // Translation and Book Properties
  List<Translation> _translations = [];
  List<Book> _books = [];
  Chapter? _currentChapter;
  Translation? _selectedTranslation;
  Book? _selectedBook;
  int? _selectedChapter;

  // Commentary Properties
  List<Commentary> _commentaries = [];
  Commentary? _selectedCommentary;
  CommentaryChapter? _currentCommentary;

  // User Content Properties
  List<Bookmark> _bookmarks = [];
  List<Map<String, dynamic>> _readingHistory = [];
  List<OfflineTranslation> _downloadedTranslations = [];

  // Search Properties
  List<Map<String, dynamic>> _searchResults = [];

  // Download Properties
  final Map<String, DownloadProgress> _downloadProgress = {};

  // UI State Properties
  bool _isLoading = false;
  String _error = '';
  bool _showCommentary = false;
  bool _darkMode = false;
  bool _isOfflineMode = false;

  // Getters
  List<Translation> get translations => _translations;
  List<Book> get books => _books;
  Chapter? get currentChapter => _currentChapter;
  Translation? get selectedTranslation => _selectedTranslation;
  Book? get selectedBook => _selectedBook;
  int? get selectedChapter => _selectedChapter;
  bool get isLoading => _isLoading;
  String get error => _error;

  List<Commentary> get commentaries => _commentaries;
  Commentary? get selectedCommentary => _selectedCommentary;
  CommentaryChapter? get currentCommentary => _currentCommentary;

  List<Bookmark> get bookmarks => _bookmarks;
  List<Map<String, dynamic>> get readingHistory => _readingHistory;
  List<OfflineTranslation> get downloadedTranslations =>
      _downloadedTranslations;

  List<Map<String, dynamic>> get searchResults => _searchResults;
  Map<String, DownloadProgress> get downloadProgress => _downloadProgress;

  bool get showCommentary => _showCommentary;
  bool get darkMode => _darkMode;
  bool get isOfflineMode => _isOfflineMode;

  // Initialization Methods
  Future<void> loadTranslations() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _translations = await BibleApi.getAvailableTranslations();

      if (_translations.isEmpty) {
        // Provide fallback data if no translations are loaded
        _translations = _getFallbackEnglishTranslations();
      }

      _selectedTranslation = _translations.isNotEmpty
          ? _translations.first
          : null;
      await _loadBookmarks();
      await _loadReadingHistory();
      await _loadDownloadedTranslations();

      // Try to load commentaries, but don't fail if it doesn't work
      try {
        await loadCommentaries();
      } catch (e) {
        print('Failed to load commentaries: $e');
      }
    } catch (e) {
      _error = 'Failed to load translations: $e';
      // Provide fallback data for testing
      _translations = _getFallbackEnglishTranslations();
      _selectedTranslation = _translations.first;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fallback English translations
  List<Translation> _getFallbackEnglishTranslations() {
    return [
      Translation(code: 'KJV', name: 'King James Version', language: 'English'),
      Translation(
        code: 'NKJV',
        name: 'New King James Version',
        language: 'English',
      ),
      Translation(
        code: 'NIV',
        name: 'New International Version',
        language: 'English',
      ),
      Translation(
        code: 'ESV',
        name: 'English Standard Version',
        language: 'English',
      ),
      Translation(
        code: 'NASB',
        name: 'New American Standard Bible',
        language: 'English',
      ),
      Translation(
        code: 'NLT',
        name: 'New Living Translation',
        language: 'English',
      ),
      Translation(code: 'BSB', name: 'Berean Study Bible', language: 'English'),
      Translation(
        code: 'CSB',
        name: 'Christian Standard Bible',
        language: 'English',
      ),
    ];
  }

  Future<void> loadBooks(String translation) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _books = await BibleApi.getBooks(translation);

      // Check if any books have 0 chapters and replace with fallback data
      final booksWithZeroChapters = _books
          .where((book) => book.chapters == 0)
          .length;
      if (booksWithZeroChapters > 0) {
        print(
          'Found $booksWithZeroChapters books with 0 chapters, using fallback data',
        );

        // Create a map of fallback books for easy lookup
        final fallbackBooksMap = {
          for (var book in _getFallbackBooks()) book.id: book,
        };

        // Update books with fallback chapter counts
        _books = _books.map((book) {
          final fallbackBook = fallbackBooksMap[book.id];
          if (fallbackBook != null && book.chapters == 0) {
            print(
              'Replacing ${book.name} chapters: 0 -> ${fallbackBook.chapters}',
            );
            return Book(
              id: book.id,
              name: book.name,
              chapters: fallbackBook.chapters,
            );
          }
          return book;
        }).toList();
      }

      if (_books.isEmpty) {
        _error = 'No books available for $translation translation.';
        // Provide complete fallback data
        _books = _getFallbackBooks();
      }
    } catch (e) {
      _error = 'Failed to load books: $e';
      print('Error loading books: $e');

      // Provide complete fallback data
      _books = _getFallbackBooks();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Book> _getFallbackBooks() {
    return [
      // Old Testament
      Book(id: 'GEN', name: 'Genesis', chapters: 50),
      Book(id: 'EXO', name: 'Exodus', chapters: 40),
      Book(id: 'LEV', name: 'Leviticus', chapters: 27),
      Book(id: 'NUM', name: 'Numbers', chapters: 36),
      Book(id: 'DEU', name: 'Deuteronomy', chapters: 34),
      Book(id: 'JOS', name: 'Joshua', chapters: 24),
      Book(id: 'JDG', name: 'Judges', chapters: 21),
      Book(id: 'RUT', name: 'Ruth', chapters: 4),
      Book(id: '1SA', name: '1 Samuel', chapters: 31),
      Book(id: '2SA', name: '2 Samuel', chapters: 24),
      Book(id: '1KI', name: '1 Kings', chapters: 22),
      Book(id: '2KI', name: '2 Kings', chapters: 25),
      Book(id: '1CH', name: '1 Chronicles', chapters: 29),
      Book(id: '2CH', name: '2 Chronicles', chapters: 36),
      Book(id: 'EZR', name: 'Ezra', chapters: 10),
      Book(id: 'NEH', name: 'Nehemiah', chapters: 13),
      Book(id: 'EST', name: 'Esther', chapters: 10),
      Book(id: 'JOB', name: 'Job', chapters: 42),
      Book(id: 'PSA', name: 'Psalms', chapters: 150),
      Book(id: 'PRO', name: 'Proverbs', chapters: 31),
      Book(id: 'ECC', name: 'Ecclesiastes', chapters: 12),
      Book(id: 'SNG', name: 'Song of Solomon', chapters: 8),
      Book(id: 'ISA', name: 'Isaiah', chapters: 66),
      Book(id: 'JER', name: 'Jeremiah', chapters: 52),
      Book(id: 'LAM', name: 'Lamentations', chapters: 5),
      Book(id: 'EZK', name: 'Ezekiel', chapters: 48),
      Book(id: 'DAN', name: 'Daniel', chapters: 12),
      Book(id: 'HOS', name: 'Hosea', chapters: 14),
      Book(id: 'JOL', name: 'Joel', chapters: 3),
      Book(id: 'AMO', name: 'Amos', chapters: 9),
      Book(id: 'OBA', name: 'Obadiah', chapters: 1),
      Book(id: 'JON', name: 'Jonah', chapters: 4),
      Book(id: 'MIC', name: 'Micah', chapters: 7),
      Book(id: 'NAM', name: 'Nahum', chapters: 3),
      Book(id: 'HAB', name: 'Habakkuk', chapters: 3),
      Book(id: 'ZEP', name: 'Zephaniah', chapters: 3),
      Book(id: 'HAG', name: 'Haggai', chapters: 2),
      Book(id: 'ZEC', name: 'Zechariah', chapters: 14),
      Book(id: 'MAL', name: 'Malachi', chapters: 4),

      // New Testament
      Book(id: 'MAT', name: 'Matthew', chapters: 28),
      Book(id: 'MRK', name: 'Mark', chapters: 16),
      Book(id: 'LUK', name: 'Luke', chapters: 24),
      Book(id: 'JHN', name: 'John', chapters: 21),
      Book(id: 'ACT', name: 'Acts', chapters: 28),
      Book(id: 'ROM', name: 'Romans', chapters: 16),
      Book(id: '1CO', name: '1 Corinthians', chapters: 16),
      Book(id: '2CO', name: '2 Corinthians', chapters: 13),
      Book(id: 'GAL', name: 'Galatians', chapters: 6),
      Book(id: 'EPH', name: 'Ephesians', chapters: 6),
      Book(id: 'PHP', name: 'Philippians', chapters: 4),
      Book(id: 'COL', name: 'Colossians', chapters: 4),
      Book(id: '1TH', name: '1 Thessalonians', chapters: 5),
      Book(id: '2TH', name: '2 Thessalonians', chapters: 3),
      Book(id: '1TI', name: '1 Timothy', chapters: 6),
      Book(id: '2TI', name: '2 Timothy', chapters: 4),
      Book(id: 'TIT', name: 'Titus', chapters: 3),
      Book(id: 'PHM', name: 'Philemon', chapters: 1),
      Book(id: 'HEB', name: 'Hebrews', chapters: 13),
      Book(id: 'JAS', name: 'James', chapters: 5),
      Book(id: '1PE', name: '1 Peter', chapters: 5),
      Book(id: '2PE', name: '2 Peter', chapters: 3),
      Book(id: '1JN', name: '1 John', chapters: 5),
      Book(id: '2JN', name: '2 John', chapters: 1),
      Book(id: '3JN', name: '3 John', chapters: 1),
      Book(id: 'JUD', name: 'Jude', chapters: 1),
      Book(id: 'REV', name: 'Revelation', chapters: 22),
    ];
  }

  // Chapter Loading Methods
  Future<void> loadChapter(String translation, String book, int chapter) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Try to load from offline storage first if in offline mode or if book is downloaded
      if (_isOfflineMode ||
          await DownloadService().isBookDownloaded(translation, book)) {
        final offlineChapter = await DownloadService().getOfflineChapter(
          translation,
          book,
          chapter,
        );
        if (offlineChapter != null) {
          _setChapterData(offlineChapter, translation, book, chapter);
          return;
        } else if (_isOfflineMode) {
          throw Exception(
            'Chapter not available offline. Please check your internet connection or download the content first.',
          );
        }
      }

      // Fall back to online API
      final onlineChapter = await BibleApi.getChapter(
        translation,
        book,
        chapter,
      );
      _setChapterData(onlineChapter, translation, book, chapter);
    } catch (e) {
      _error = 'Failed to load chapter: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setChapterData(
    Chapter chapter,
    String translation,
    String book,
    int chapterNum,
  ) {
    _currentChapter = chapter;
    _selectedTranslation = _translations.firstWhere(
      (t) => t.code == translation,
      orElse: () => _translations.first,
    );
    _selectedBook = _books.firstWhere(
      (b) => b.id == book,
      orElse: () => _books.first,
    );
    _selectedChapter = chapterNum;

    // Save to reading history
    _saveReadingHistory(translation, book, chapterNum);

    // Load commentary if enabled
    if (_showCommentary && _selectedCommentary != null) {
      loadCommentaryChapter(_selectedCommentary!.id, book, chapterNum);
    }

    _isLoading = false;
    notifyListeners();
  }

  // Commentary Methods
  Future<void> loadCommentaries() async {
    _isLoading = true;
    notifyListeners();

    try {
      _commentaries = await BibleApi.getAvailableCommentaries();
      if (_commentaries.isNotEmpty) {
        _selectedCommentary = _commentaries.first;
      }
    } catch (e) {
      _error = 'Failed to load commentaries: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCommentaryChapter(
    String commentary,
    String book,
    int chapter,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentCommentary = await BibleApi.getCommentaryChapter(
        commentary,
        book,
        chapter,
      );
    } catch (e) {
      _error = 'Failed to load commentary: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Bookmark Methods
  Future<void> addBookmark(int verse, [String note = '']) async {
    if (_currentChapter == null) return;

    try {
      final bookmark = Bookmark(
        translation: _currentChapter!.translation,
        book: _currentChapter!.book,
        chapter: _currentChapter!.chapter,
        verse: verse,
        note: note,
        createdAt: DateTime.now(),
      );

      await DatabaseService().insertBookmark(bookmark);
      await _loadBookmarks();
    } catch (e) {
      _error = 'Failed to add bookmark: $e';
      notifyListeners();
    }
  }

  Future<void> removeBookmark(int bookmarkId) async {
    try {
      await DatabaseService().deleteBookmark(bookmarkId);
      await _loadBookmarks();
    } catch (e) {
      _error = 'Failed to remove bookmark: $e';
      notifyListeners();
    }
  }

  Future<void> _loadBookmarks() async {
    try {
      _bookmarks = await DatabaseService().getBookmarks();
    } catch (e) {
      _error = 'Failed to load bookmarks: $e';
    }
  }

  // Reading History Methods
  Future<void> _saveReadingHistory(
    String translation,
    String book,
    int chapter,
  ) async {
    try {
      await DatabaseService().saveReadingHistory(translation, book, chapter);
      await _loadReadingHistory();
    } catch (e) {
      _error = 'Failed to save reading history: $e';
    }
  }

  Future<void> _loadReadingHistory() async {
    try {
      _readingHistory = await DatabaseService().getReadingHistory();
    } catch (e) {
      _error = 'Failed to load reading history: $e';
    }
  }

  // Download Methods
  Future<void> downloadTranslation(String translation) async {
    _downloadProgress[translation] = DownloadProgress(
      translation: translation,
      book: '',
      currentChapter: 0,
      totalChapters: 0,
      progress: 0.0,
      status: DownloadStatus.queued,
    );
    notifyListeners();

    try {
      await DownloadService().downloadTranslation(
        translation,
        onProgress: (progress) {
          _downloadProgress[translation] = progress;
          notifyListeners();
        },
        onComplete: () async {
          _downloadProgress.remove(translation);
          await _loadDownloadedTranslations();
          notifyListeners();
        },
        onError: (error) {
          _downloadProgress[translation] = DownloadProgress(
            translation: translation,
            book: '',
            currentChapter: 0,
            totalChapters: 0,
            progress: 0.0,
            status: DownloadStatus.error,
          );
          _error = 'Download failed: $error';
          notifyListeners();
        },
      );
    } catch (e) {
      _error = 'Failed to start download: $e';
      _downloadProgress.remove(translation);
      notifyListeners();
    }
  }

  Future<void> downloadBook(String translation, String book) async {
    final key = '$translation-$book';
    _downloadProgress[key] = DownloadProgress(
      translation: translation,
      book: book,
      currentChapter: 0,
      totalChapters: 0,
      progress: 0.0,
      status: DownloadStatus.queued,
    );
    notifyListeners();

    try {
      await DownloadService().downloadBook(
        translation,
        book,
        onProgress: (progress) {
          _downloadProgress[key] = progress;
          notifyListeners();
        },
        onComplete: () async {
          _downloadProgress.remove(key);
          await _loadDownloadedTranslations();
          notifyListeners();
        },
        onError: (error) {
          _downloadProgress[key] = DownloadProgress(
            translation: translation,
            book: book,
            currentChapter: 0,
            totalChapters: 0,
            progress: 0.0,
            status: DownloadStatus.error,
          );
          _error = 'Download failed: $error';
          notifyListeners();
        },
      );
    } catch (e) {
      _error = 'Failed to start download: $e';
      _downloadProgress.remove(key);
      notifyListeners();
    }
  }

  Future<void> _loadDownloadedTranslations() async {
    try {
      _downloadedTranslations = await DownloadService()
          .getDownloadedTranslations();
    } catch (e) {
      _error = 'Failed to load downloaded translations: $e';
    }
  }

  Future<void> deleteTranslation(String translation) async {
    try {
      await DownloadService().deleteTranslation(translation);
      await _loadDownloadedTranslations();

      // If the deleted translation was selected, switch to another one
      if (_selectedTranslation?.code == translation &&
          _translations.isNotEmpty) {
        _selectedTranslation = _translations.first;
        await loadBooks(_selectedTranslation!.code);
      }

      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete translation: $e';
      notifyListeners();
    }
  }

  Future<void> deleteBook(String translation, String book) async {
    try {
      await DownloadService().deleteBook(translation, book);
      await _loadDownloadedTranslations();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete book: $e';
      notifyListeners();
    }
  }

  void cancelDownload(String translation, String book) {
    final key = '$translation-$book';
    DownloadService().cancelDownload(translation, book);
    _downloadProgress.remove(key);
    notifyListeners();
  }

  // Search Methods
  Future<void> searchVerses(String query) async {
    if (query.length < 3) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await BibleApi.searchVerses(
        query,
        _selectedTranslation?.code ?? 'BSB',
      );
    } catch (e) {
      _error = 'Search failed: $e';
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // UI State Methods
  void toggleCommentary() {
    _showCommentary = !_showCommentary;
    if (_showCommentary &&
        _selectedCommentary != null &&
        _currentChapter != null) {
      loadCommentaryChapter(
        _selectedCommentary!.id,
        _currentChapter!.book,
        _currentChapter!.chapter,
      );
    }
    notifyListeners();
  }

  void toggleDarkMode() {
    _darkMode = !_darkMode;
    notifyListeners();
  }

  void toggleOfflineMode() {
    _isOfflineMode = !_isOfflineMode;
    notifyListeners();
  }

  // Selection Methods
  void setSelectedTranslation(Translation translation) {
    _selectedTranslation = translation;
    loadBooks(translation.code);
    notifyListeners();
  }

  void setSelectedBook(Book book) {
    _selectedBook = book;
    notifyListeners();
  }

  void setSelectedChapter(int chapter) {
    _selectedChapter = chapter;
    notifyListeners();
  }

  void setSelectedCommentary(Commentary commentary) {
    _selectedCommentary = commentary;
    if (_showCommentary && _currentChapter != null) {
      loadCommentaryChapter(
        commentary.id,
        _currentChapter!.book,
        _currentChapter!.chapter,
      );
    }
    notifyListeners();
  }

  // Utility Methods
  void clearError() {
    _error = '';
    notifyListeners();
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  // Check if content is available offline
  Future<bool> isTranslationDownloaded(String translation) async {
    return await DownloadService().isTranslationDownloaded(translation);
  }

  Future<bool> isBookDownloaded(String translation, String book) async {
    return await DownloadService().isBookDownloaded(translation, book);
  }

  // Get total offline storage size
  Future<int> getOfflineStorageSize() async {
    return await DownloadService().getOfflineContentSize();
  }

  // Refresh all data
  Future<void> refreshAll() async {
    await loadTranslations();
    if (_selectedTranslation != null) {
      await loadBooks(_selectedTranslation!.code);
    }
    if (_currentChapter != null) {
      await loadChapter(
        _currentChapter!.translation,
        _currentChapter!.book,
        _currentChapter!.chapter,
      );
    }
  }

  // Test API endpoints
  Future<void> testApiEndpoints() async {
    print('Testing API endpoints...');

    try {
      // Test translations endpoint
      await BibleApi.debugApiResponse(
        '${BibleApi.baseUrl}/available_translations.json',
      );

      // Test books endpoint
      await BibleApi.debugApiResponse('${BibleApi.baseUrl}/BSB/books.json');

      // Test chapter endpoint
      await BibleApi.debugApiResponse('${BibleApi.baseUrl}/BSB/GEN/1.json');
    } catch (e) {
      print('API test failed: $e');
    }
  }

  // Dispose method for cleanup
  @override
  void dispose() {
    DownloadService().dispose();
    super.dispose();
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bible_models.dart';

class BibleApi {
  static const String baseUrl = 'https://bible.helloao.org/api';

  static Future<List<Translation>> getAvailableTranslations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/available_translations.json'),
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        // Handle both List and Map responses
        if (data is List) {
          final allTranslations = data
              .map((json) => Translation.fromJson(json))
              .toList();

          // Filter for English translations only
          final englishTranslations = allTranslations.where((translation) {
            final language = translation.language.toLowerCase();
            final name = translation.name.toLowerCase();
            final code = translation.code.toLowerCase();

            return language.contains('english') ||
                language.contains('en') ||
                name.contains('english') ||
                name.contains('eng') ||
                code.contains('en') ||
                _isKnownEnglishTranslation(translation);
          }).toList();

          print('=== ENGLISH TRANSLATIONS FOUND ===');
          print('Total translations: ${allTranslations.length}');
          print('English translations: ${englishTranslations.length}');
          for (var t in englishTranslations) {
            print(' - ${t.name} (${t.code}) - ${t.language}');
          }

          return englishTranslations;
        } else if (data is Map) {
          // Convert to Map<String, dynamic>
          final Map<String, dynamic> dataMap = _convertToStringMap(data);

          // If the API returns a map, convert it to a list
          if (dataMap.containsKey('translations')) {
            final translationsData = dataMap['translations'] as List;
            final allTranslations = translationsData
                .map((json) => Translation.fromJson(json))
                .toList();

            // Filter for English translations only
            final englishTranslations = allTranslations.where((translation) {
              final language = translation.language.toLowerCase();
              final name = translation.name.toLowerCase();
              final code = translation.code.toLowerCase();

              return language.contains('english') ||
                  language.contains('en') ||
                  name.contains('english') ||
                  name.contains('eng') ||
                  code.contains('en') ||
                  _isKnownEnglishTranslation(translation);
            }).toList();

            return englishTranslations;
          } else {
            // If it's a map but doesn't have 'translations' key, try to parse it as a single translation
            final translation = Translation.fromJson(dataMap);
            if (_isEnglishTranslation(translation)) {
              return [translation];
            }
            return [];
          }
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load translations: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading translations: $e');
      // Return common English translations as fallback
      return _getFallbackEnglishTranslations();
    }
  }

  // Helper to check if a translation is English
  static bool _isEnglishTranslation(Translation translation) {
    final language = translation.language.toLowerCase();
    final name = translation.name.toLowerCase();
    final code = translation.code.toLowerCase();

    return language.contains('english') ||
        language.contains('en') ||
        name.contains('english') ||
        name.contains('eng') ||
        code.contains('en') ||
        _isKnownEnglishTranslation(translation);
  }

  // Check for known English translation codes and names
  static bool _isKnownEnglishTranslation(Translation translation) {
    final knownEnglishCodes = [
      'KJV',
      'NKJV',
      'NIV',
      'ESV',
      'NASB',
      'NLT',
      'CSB',
      'RSV',
      'ASV',
      'BSB',
      'WEB',
      'YLT',
      'DBY',
      'HCSB',
      'MEV',
      'GNV',
      'JUB',
      'AKJ',
      'LSV',
      'TLV',
    ];

    final knownEnglishNames = [
      'king james',
      'new king james',
      'new international',
      'english standard',
      'new american standard',
      'new living',
      'christian standard',
      'revised standard',
      'american standard',
      'berean study',
      'world english',
      'young\'s literal',
      'darby',
      'holman christian',
      'modern english',
      'geneva',
      'jubilee',
      'american king james',
      'literal standard',
      'tree of life',
    ];

    final code = translation.code.toUpperCase();
    final name = translation.name.toLowerCase();

    return knownEnglishCodes.contains(code) ||
        knownEnglishNames.any((englishName) => name.contains(englishName));
  }

  // Fallback English translations
  static List<Translation> _getFallbackEnglishTranslations() {
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
      Translation(
        code: 'RSV',
        name: 'Revised Standard Version',
        language: 'English',
      ),
      Translation(
        code: 'WEB',
        name: 'World English Bible',
        language: 'English',
      ),
    ];
  }

  static Future<List<Book>> getBooks(String translation) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$translation/books.json'),
      );

      print('=== BOOKS API DEBUG ===');
      print('URL: $baseUrl/$translation/books.json');
      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        print('Decoded data type: ${data.runtimeType}');

        // Print the full structure to understand what we're getting
        print('Full response structure:');
        if (data is Map) {
          final Map<String, dynamic> dataMap = _convertToStringMap(data);
          dataMap.forEach((key, value) {
            print('Key: $key');
            if (value is List) {
              print('Value type: List with ${value.length} items');
              if (value.isNotEmpty && value[0] is Map) {
                print('First item keys: ${(value[0] as Map).keys}');
                print('First item values: ${(value[0] as Map).values}');
              }
            } else {
              print('Value: $value');
            }
          });
        }

        // Handle both List and Map responses
        if (data is List) {
          print('Books list length: ${data.length}');
          final books = data.map((json) => Book.fromJson(json)).toList();
          return books;
        } else if (data is Map) {
          // Convert to Map<String, dynamic>
          final Map<String, dynamic> dataMap = _convertToStringMap(data);
          print('Map keys: ${dataMap.keys}');

          // If the API returns a map, convert it to a list
          if (dataMap.containsKey('books')) {
            final booksData = dataMap['books'] as List;
            print('Books from "books" key: ${booksData.length}');
            final books = booksData.map((json) => Book.fromJson(json)).toList();
            return books;
          } else {
            // If it's a map but doesn't have 'books' key, try to parse it as a single book
            print('Treating map as single book');
            return [Book.fromJson(dataMap)];
          }
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load books: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading books: $e');
      throw Exception('Failed to load books: $e');
    }
  }

  static Future<Chapter> getChapter(
    String translation,
    String book,
    int chapter,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$translation/$book/$chapter.json'),
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        // Convert to Map<String, dynamic>
        final Map<String, dynamic> dataMap = _convertToStringMap(data);
        return Chapter.fromJson(dataMap);
      } else {
        throw Exception('Failed to load chapter: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load chapter: $e');
    }
  }

  static Future<List<Commentary>> getAvailableCommentaries() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/available_commentaries.json'),
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        // Handle both List and Map responses
        if (data is List) {
          return data.map((json) => Commentary.fromJson(json)).toList();
        } else if (data is Map) {
          // Convert to Map<String, dynamic>
          final Map<String, dynamic> dataMap = _convertToStringMap(data);

          // If the API returns a map, convert it to a list
          if (dataMap.containsKey('commentaries')) {
            final commentariesData = dataMap['commentaries'] as List;
            return commentariesData
                .map((json) => Commentary.fromJson(json))
                .toList();
          } else {
            // If it's a map but doesn't have 'commentaries' key, try to parse it as a single commentary
            return [Commentary.fromJson(dataMap)];
          }
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load commentaries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load commentaries: $e');
    }
  }

  static Future<List<Book>> getCommentaryBooks(String commentary) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/c/$commentary/books.json'),
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        // Handle both List and Map responses
        if (data is List) {
          return data.map((json) => Book.fromJson(json)).toList();
        } else if (data is Map) {
          // Convert to Map<String, dynamic>
          final Map<String, dynamic> dataMap = _convertToStringMap(data);

          // If the API returns a map, convert it to a list
          if (dataMap.containsKey('books')) {
            final booksData = dataMap['books'] as List;
            return booksData.map((json) => Book.fromJson(json)).toList();
          } else {
            // If it's a map but doesn't have 'books' key, try to parse it as a single book
            return [Book.fromJson(dataMap)];
          }
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception(
          'Failed to load commentary books: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to load commentary books: $e');
    }
  }

  static Future<CommentaryChapter> getCommentaryChapter(
    String commentary,
    String book,
    int chapter,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/c/$commentary/$book/$chapter.json'),
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        // Convert to Map<String, dynamic>
        final Map<String, dynamic> dataMap = _convertToStringMap(data);
        return CommentaryChapter.fromJson(dataMap);
      } else {
        throw Exception(
          'Failed to load commentary chapter: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to load commentary chapter: $e');
    }
  }

  // Enhanced search functionality with better error handling
  static Future<List<Map<String, dynamic>>> searchVerses(
    String query,
    String translation,
  ) async {
    try {
      // Since the API documentation doesn't show a search endpoint,
      // we'll implement a basic client-side search using the available data
      // In a real implementation, you might want to use a different approach

      // For now, return an empty list since we don't have a proper search endpoint
      // You could implement this by downloading the entire translation and searching locally
      // or by using a different Bible API that supports search

      return [];
    } catch (e) {
      throw Exception('Search not available: $e');
    }
  }

  // Helper method to debug API responses
  static Future<void> debugApiResponse(String endpoint) async {
    try {
      final response = await http.get(Uri.parse(endpoint));
      print('=== API DEBUG ===');
      print('Endpoint: $endpoint');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('Response Type: ${response.body.runtimeType}');

      final decoded = json.decode(response.body);
      print('Decoded Type: ${decoded.runtimeType}');
      if (decoded is Map) {
        print('Map Keys: ${decoded.keys}');
      }
      print('=================');
    } catch (e) {
      print('Debug error: $e');
    }
  }

  // Helper function to convert Map<dynamic, dynamic> to Map<String, dynamic>
  static Map<String, dynamic> _convertToStringMap(dynamic json) {
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
}

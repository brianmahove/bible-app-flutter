import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../providers/bible_provider.dart';
import 'translation_screen.dart';
import 'book_screen.dart';
import 'chapter_screen.dart';
import 'search_screen.dart';
import 'bookmarks_screen.dart';
import 'commentary_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BibleProvider>(context, listen: false);
      provider.loadTranslations();
      provider.loadCommentaries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bible App'),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BookmarksScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchScreen()),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              final provider = Provider.of<BibleProvider>(
                context,
                listen: false,
              );
              switch (value) {
                case 'commentary':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CommentaryScreen()),
                  );
                  break;
                case 'dark_mode':
                  provider.toggleDarkMode();
                  break;
                case 'refresh':
                  provider.loadTranslations();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'commentary',
                child: Row(
                  children: [
                    Icon(Icons.menu_book),
                    SizedBox(width: 8),
                    Text('Commentaries'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'dark_mode',
                child: Row(
                  children: [
                    Icon(Icons.dark_mode),
                    SizedBox(width: 8),
                    Text('Toggle Dark Mode'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<BibleProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.translations.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          if (provider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      provider.loadTranslations();
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Selection Section
              _buildSelectionSection(provider),
              Divider(),

              // Commentary Toggle
              if (provider.commentaries.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text('Show Commentary'),
                      Switch(
                        value: provider.showCommentary,
                        onChanged: (value) {
                          provider.toggleCommentary();
                        },
                      ),
                      if (provider.selectedCommentary != null)
                        Expanded(
                          child: Text(
                            provider.selectedCommentary!.name,
                            textAlign: TextAlign.right,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),

              // Content Section
              Expanded(child: _buildContentSection(provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectionSection(BibleProvider provider) {
    return Column(
      children: [
        ListTile(
          title: Text('Translation'),
          subtitle: Text(
            provider.selectedTranslation?.name ?? 'Select Translation',
          ),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TranslationScreen()),
            );
          },
        ),
        Divider(),

        ListTile(
          title: Text('Book'),
          subtitle: Text(provider.selectedBook?.name ?? 'Select Book'),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: provider.selectedTranslation != null
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BookScreen()),
                  );
                }
              : null,
        ),
        Divider(),

        ListTile(
          title: Text('Chapter'),
          subtitle: Text(
            provider.selectedChapter?.toString() ?? 'Select Chapter',
          ),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: provider.selectedBook != null
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChapterScreen()),
                  );
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildContentSection(BibleProvider provider) {
    if (provider.currentChapter == null) {
      return Center(
        child: Text(
          'Select a translation, book, and chapter to start reading',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    if (provider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return DefaultTabController(
      length: provider.showCommentary ? 2 : 1,
      child: Column(
        children: [
          if (provider.showCommentary)
            TabBar(
              tabs: [
                Tab(text: 'Bible'),
                Tab(text: 'Commentary'),
              ],
            ),
          Expanded(
            child: provider.showCommentary
                ? TabBarView(
                    children: [
                      _buildBibleContent(provider),
                      _buildCommentaryContent(provider),
                    ],
                  )
                : _buildBibleContent(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildBibleContent(BibleProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: provider.currentChapter!.verses.length,
        itemBuilder: (context, index) {
          final verse = provider.currentChapter!.verses[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: GestureDetector(
              onLongPress: () {
                _showVerseOptions(provider, verse.verse);
              },
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(
                      text: '${verse.verse} ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    TextSpan(text: verse.text),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommentaryContent(BibleProvider provider) {
    if (provider.currentCommentary == null) {
      return Center(
        child: Text(
          'No commentary available for this chapter',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Markdown(
        data: provider.currentCommentary!.content,
        styleSheet: MarkdownStyleSheet(p: TextStyle(fontSize: 16, height: 1.5)),
      ),
    );
  }

  void _showVerseOptions(BibleProvider provider, int verse) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.bookmark),
              title: Text('Bookmark Verse'),
              onTap: () {
                provider.addBookmark(verse);
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Verse bookmarked')));
              },
            ),
            ListTile(
              leading: Icon(Icons.share),
              title: Text('Share Verse'),
              onTap: () {
                // Implement share functionality
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}

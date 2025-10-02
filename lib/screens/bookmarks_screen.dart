import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bible_provider.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BibleProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Bookmarks')),
      body: provider.bookmarks.isEmpty
          ? Center(
              child: Text(
                'No bookmarks yet',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: provider.bookmarks.length,
              itemBuilder: (context, index) {
                final bookmark = provider.bookmarks[index];
                return Dismissible(
                  key: Key(bookmark.id.toString()),
                  background: Container(color: Colors.red),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    provider.removeBookmark(bookmark.id!);
                  },
                  child: ListTile(
                    title: Text(
                      '${bookmark.book} ${bookmark.chapter}:${bookmark.verse}',
                    ),
                    subtitle: bookmark.note.isNotEmpty
                        ? Text(bookmark.note)
                        : Text(bookmark.translation),
                    trailing: Text(
                      '${bookmark.createdAt.day}/${bookmark.createdAt.month}/${bookmark.createdAt.year}',
                      style: TextStyle(color: Colors.grey),
                    ),
                    onTap: () {
                      provider.loadChapter(
                        bookmark.translation,
                        bookmark.book,
                        bookmark.chapter,
                      );
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                  ),
                );
              },
            ),
    );
  }
}

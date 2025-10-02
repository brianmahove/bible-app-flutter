import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bible_provider.dart';

class ChapterScreen extends StatelessWidget {
  const ChapterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BibleProvider>(context);
    final book = provider.selectedBook;

    if (book == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Select Chapter')),
        body: Center(child: Text('No book selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Select Chapter - ${book.name}')),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: book.chapters,
        itemBuilder: (context, index) {
          final chapterNumber = index + 1;
          return InkWell(
            onTap: () {
              provider.loadChapter(
                provider.selectedTranslation!.code,
                book.id,
                chapterNumber,
              );
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                color: provider.selectedChapter == chapterNumber
                    ? Colors.blue
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  chapterNumber.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: provider.selectedChapter == chapterNumber
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

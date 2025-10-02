import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import '../models/bible_models.dart';
import '../providers/bible_provider.dart';
import '../services/bible_api.dart';
import '../services/download_service.dart';

class BookDownloadScreen extends StatelessWidget {
  final String translation;

  const BookDownloadScreen({super.key, required this.translation});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BibleProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Download Books - $translation')),
      body: FutureBuilder(
        future: BibleApi.getBooks(translation),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading books'));
          }

          final books = snapshot.data as List<Book>;

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              final downloadKey = '$translation-${book.id}';
              final isDownloading = provider.downloadProgress.containsKey(
                downloadKey,
              );
              // Check if the translation is in the downloaded list AND if the specific book is downloaded
              return FutureBuilder<bool>(
                future: DownloadService().isBookDownloaded(
                  translation,
                  book.id,
                ),
                builder: (context, bookDownloadedSnapshot) {
                  final isBookAlreadyDownloaded =
                      bookDownloadedSnapshot.data ?? false;
                  return ListTile(
                    title: Text(book.name),
                    subtitle: Text('${book.chapters} chapters'),
                    trailing: isDownloading
                        ? _buildDownloadProgress(
                            provider.downloadProgress[downloadKey]!,
                          )
                        : isBookAlreadyDownloaded
                        ? Icon(Icons.check_circle, color: Colors.green)
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.download),
                                onPressed: () {
                                  provider.downloadBook(translation, book.id);
                                },
                              ),
                            ],
                          ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDownloadProgress(DownloadProgress progress) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${progress.currentChapter}/${progress.totalChapters}',
          style: TextStyle(fontSize: 12),
        ),
        SizedBox(height: 4),
        SizedBox(
          width: 60,
          height: 4,
          child: LinearProgressIndicator(value: progress.progress),
        ),
        IconButton(
          icon: Icon(Icons.cancel, size: 16),
          onPressed: () {
            // Cancel download
            Provider.of<BibleProvider>(
              context as BuildContext,
              listen: false,
            ).cancelDownload(progress.translation, progress.book);
          },
        ),
      ],
    );
  }
}

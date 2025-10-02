import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bible_models.dart';
import '../providers/bible_provider.dart';

class DownloadManagerScreen extends StatelessWidget {
  const DownloadManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BibleProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Download Manager'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Available'),
              Tab(text: 'Downloaded'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAvailableTranslations(provider),
            _buildDownloadedContent(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableTranslations(BibleProvider provider) {
    return ListView.builder(
      itemCount: provider.translations.length,
      itemBuilder: (context, index) {
        final translation = provider.translations[index];
        final isDownloading = provider.downloadProgress.containsKey(
          translation.code,
        );
        final isDownloaded = provider.downloadedTranslations.any(
          (t) => t.code == translation.code,
        );

        return ListTile(
          title: Text(translation.name),
          subtitle: Text('${translation.language} - ${translation.code}'),
          trailing: isDownloading
              ? _buildDownloadProgress(
                  provider.downloadProgress[translation.code]!,
                )
              : isDownloaded
              ? Icon(Icons.check_circle, color: Colors.green)
              : IconButton(
                  icon: Icon(Icons.download),
                  onPressed: () {
                    provider.downloadTranslation(translation.code);
                  },
                ),
        );
      },
    );
  }

  Widget _buildDownloadedContent(BibleProvider provider) {
    if (provider.downloadedTranslations.isEmpty) {
      return Center(
        child: Text(
          'No downloaded content',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: provider.downloadedTranslations.length,
      itemBuilder: (context, index) {
        final translation = provider.downloadedTranslations[index];
        final sizeInMB = translation.totalSize / (1024 * 1024);

        return ListTile(
          title: Text(translation.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${translation.downloadedBooks}/${translation.totalBooks} books',
              ),
              Text('${sizeInMB.toStringAsFixed(2)} MB'),
              Text('Downloaded: ${_formatDate(translation.downloadedAt)}'),
            ],
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _showDeleteDialog(context, provider, translation.code);
            },
          ),
        );
      },
    );
  }

  Widget _buildDownloadProgress(DownloadProgress progress) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (progress.book.isNotEmpty)
          Text(
            '${progress.book} ${progress.currentChapter}/${progress.totalChapters}',
            style: TextStyle(fontSize: 12),
          ),
        SizedBox(height: 4),
        SizedBox(
          width: 60,
          height: 4,
          child: LinearProgressIndicator(value: progress.progress),
        ),
      ],
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    BibleProvider provider,
    String translation,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Translation?'),
        content: Text(
          'This will remove all downloaded content for $translation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteTranslation(translation);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bible_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BibleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Reading History'),
      ),
      body: provider.readingHistory.isEmpty
          ? Center(
              child: Text(
                'No reading history yet',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: provider.readingHistory.length,
              itemBuilder: (context, index) {
                final history = provider.readingHistory[index];
                final date = DateTime.fromMillisecondsSinceEpoch(history['lastRead'] as int);
                
                return ListTile(
                  title: Text('${history['book']} ${history['chapter']}'),
                  subtitle: Text(history['translation']),
                  trailing: Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    provider.loadChapter(
                      history['translation'],
                      history['book'],
                      history['chapter'],
                    );
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                );
              },
            ),
    );
  }
}
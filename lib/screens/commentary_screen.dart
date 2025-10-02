import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bible_provider.dart';

class CommentaryScreen extends StatelessWidget {
  const CommentaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BibleProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Select Commentary')),
      body: provider.commentaries.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: provider.commentaries.length,
              itemBuilder: (context, index) {
                final commentary = provider.commentaries[index];
                return ListTile(
                  title: Text(commentary.name),
                  subtitle: Text(commentary.description),
                  trailing: provider.selectedCommentary?.id == commentary.id
                      ? Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    provider.setSelectedCommentary(commentary);
                    Navigator.pop(context);
                  },
                );
              },
            ),
    );
  }
}

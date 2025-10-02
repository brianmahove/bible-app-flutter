import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bible_provider.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({super.key});

  @override
  _BookScreenState createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<BibleProvider>(context, listen: false);
    if (provider.selectedTranslation != null && provider.books.isEmpty) {
      provider.loadBooks(provider.selectedTranslation!.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BibleProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Select Book')),
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: provider.books.length,
              itemBuilder: (context, index) {
                final book = provider.books[index];
                return ListTile(
                  title: Text(book.name),
                  subtitle: Text('${book.chapters} chapters'),
                  trailing: provider.selectedBook?.id == book.id
                      ? Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    provider.setSelectedBook(book);
                    Navigator.pop(context);
                  },
                );
              },
            ),
    );
  }
}

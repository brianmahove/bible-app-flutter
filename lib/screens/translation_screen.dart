import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bible_provider.dart';

class TranslationScreen extends StatelessWidget {
  const TranslationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BibleProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Select Translation')),
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: provider.translations.length,
              itemBuilder: (context, index) {
                final translation = provider.translations[index];
                return ListTile(
                  title: Text(translation.name),
                  subtitle: Text(
                    '${translation.language} - ${translation.code}',
                  ),
                  trailing:
                      provider.selectedTranslation?.code == translation.code
                      ? Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    provider.setSelectedTranslation(translation);
                    provider.loadBooks(translation.code);
                    Navigator.pop(context);
                  },
                );
              },
            ),
    );
  }
}

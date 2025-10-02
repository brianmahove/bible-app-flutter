import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bible_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.length >= 3) {
        Provider.of<BibleProvider>(context, listen: false).searchVerses(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BibleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search Bible...',
            border: InputBorder.none,
          ),
          onChanged: _onSearchChanged,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              FocusScope.of(context).unfocus();
            },
          ),
        ],
      ),
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator())
          : _searchController.text.length < 3
          ? Center(
              child: Text(
                'Enter at least 3 characters to search',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : provider.searchResults.isEmpty
          ? Center(
              child: Text(
                'No results found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: provider.searchResults.length,
              itemBuilder: (context, index) {
                final result = provider.searchResults[index];
                return ListTile(
                  title: Text(result['text'] ?? ''),
                  subtitle: Text(
                    '${result['book']} ${result['chapter']}:${result['verse']}',
                  ),
                  onTap: () {
                    // Navigate to the verse
                    provider.loadChapter(
                      result['translation'] ?? 'BSB',
                      result['book'] ?? 'GEN',
                      result['chapter'] ?? 1,
                    );
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                );
              },
            ),
    );
  }
}

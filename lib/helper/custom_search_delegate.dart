import 'package:flutter/material.dart';

class CustomSearchDelegate extends SearchDelegate {
  final List<Map<String, String>> favorites;
  final Function(List<Map<String, String>>) onUpdateFavorites;

  CustomSearchDelegate({required this.favorites, required this.onUpdateFavorites});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = favorites
        .where((favorite) =>
    favorite["quote"]!.toLowerCase().contains(query.toLowerCase()) ||
        favorite["owner"]!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return _buildResultList(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = favorites
        .where((favorite) =>
    favorite["quote"]!.toLowerCase().contains(query.toLowerCase()) ||
        favorite["owner"]!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return _buildResultList(suggestions);
  }

  Widget _buildResultList(List<Map<String, String>> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final favorite = items[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Card(
              color: Colors.tealAccent.withOpacity(0.7),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 16.0,
                ),
                title: Text(
                  favorite["quote"] ?? "",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    "- ${favorite["owner"] ?? "Unknown"}",
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ),
                onTap: () {
                  onUpdateFavorites(items);
                  close(context, null);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

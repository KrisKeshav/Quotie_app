import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:quotie/helper/custom_search_delegate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map<String, String>> favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString('favorites') ?? '[]';

    try {
      final List<dynamic> decodedFavorites = jsonDecode(favoritesJson);

      // Convert List<dynamic> to List<Map<String, String>>
      final List<Map<String, String>> loadedFavorites = decodedFavorites.map((item) {
        if (item is Map<String, dynamic>) {
          return Map<String, String>.from(item.map((key, value) => MapEntry(key, value.toString())));
        } else {
          return <String, String>{};
        }
      }).toList();

      setState(() {
        favorites = loadedFavorites;
      });
    } catch (e) {
      print('Error loading favorites: $e');
      setState(() {
        favorites = [];
      });
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = jsonEncode(favorites);
    await prefs.setString('favorites', favoritesJson);
  }

  void _addFavorite(Map<String, String> newFavorite) {
    final isDuplicate = favorites.any((favorite) =>
    favorite["quote"] == newFavorite["quote"] &&
        favorite["owner"] == newFavorite["owner"]);

    if (!isDuplicate) {
      setState(() {
        favorites.add(newFavorite);
      });
      _saveFavorites();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This quote is already in favorites!')),
      );
    }
  }

  void _removeFavorite(int index) {
    setState(() {
      favorites.removeAt(index);
    });
    _saveFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.tealAccent.withOpacity(0.8),
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.4),
        title: const Text(
          "Favorites",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        titleSpacing: mq.size.width * 0.06,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(
                  favorites: favorites,
                  onUpdateFavorites: (updatedFavorites) {
                    setState(() {
                      favorites = updatedFavorites;
                    });
                    _saveFavorites();
                  },
                ),
              );
            },
            color: Colors.white,
            tooltip: "Search",
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.tealAccent.withOpacity(0.9),
                Colors.teal.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        padding: const EdgeInsets.all(12.0),
        child: favorites.isEmpty
            ? Center(
          child: Text(
            "No favorites added yet!",
            style: TextStyle(
              color: Colors.tealAccent.withOpacity(0.7),
              fontSize: 22,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
          ),
        )
            : ListView.builder(
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final favorite = favorites[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Slidable(
                key: Key(favorite["quote"] ?? ''),
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (_) {
                        _removeFavorite(index);
                      },
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: Card(
                  color: Colors.white.withOpacity(0.85),
                  elevation: 10,
                  shadowColor: Colors.black.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 18.0,
                      horizontal: 20.0,
                    ),
                    title: Text(
                      favorite["quote"] ?? "",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "- ${favorite["owner"] ?? "Unknown"}",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    trailing: const Icon(
                      Icons.favorite,
                      color: Colors.redAccent,
                      size: 30,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

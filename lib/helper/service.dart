import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorites';

  Future<void> saveFavorites(List<Map<String, String>> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonFavorites = jsonEncode(favorites);
    await prefs.setString(_favoritesKey, jsonFavorites);
  }

  Future<List<Map<String, String>>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonFavorites = prefs.getString(_favoritesKey);
    if (jsonFavorites != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonFavorites);
        return decoded.map((e) => Map<String, String>.from(e as Map)).toList();
      } catch (e) {
        print('Error decoding favorites: $e');
        return [];
      }
    }
    return [];
  }


}

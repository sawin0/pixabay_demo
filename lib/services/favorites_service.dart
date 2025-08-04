import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/pixabay_image.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorites_list';

  static Future<List<PixabayImage>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesJson = prefs.getString(_favoritesKey);

    if (favoritesJson == null) {
      return [];
    }

    final List<dynamic> favoritesList = json.decode(favoritesJson);
    return favoritesList.map((json) => PixabayImage.fromJson(json)).toList();
  }

  static Future<void> saveFavorites(List<PixabayImage> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final String favoritesJson = json.encode(
      favorites.map((image) => image.toJson()).toList(),
    );
    await prefs.setString(_favoritesKey, favoritesJson);
  }

  static Future<void> addToFavorites(PixabayImage image) async {
    final favorites = await getFavorites();
    if (!favorites.any((fav) => fav.id == image.id)) {
      favorites.add(image);
      await saveFavorites(favorites);
    }
  }

  static Future<void> removeFromFavorites(PixabayImage image) async {
    final favorites = await getFavorites();
    favorites.removeWhere((fav) => fav.id == image.id);
    await saveFavorites(favorites);
  }

  static Future<bool> isFavorite(PixabayImage image) async {
    final favorites = await getFavorites();
    return favorites.any((fav) => fav.id == image.id);
  }
}

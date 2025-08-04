import 'package:flutter_test/flutter_test.dart';
import 'package:pixabay_app/models/pixabay_image.dart';
import 'package:pixabay_app/services/favorites_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PixabayImage Tests', () {
    test('should format image size correctly', () {
      // Test sizes under 1K
      var image = PixabayImage(
        id: 1,
        webformatURL: 'test.jpg',
        tags: 'test',
        imageSize: 550,
        views: 100,
        downloads: 50,
        user: 'testuser',
      );
      expect(image.getFormattedSize(), '550');

      // Test sizes in K range
      image = PixabayImage(
        id: 2,
        webformatURL: 'test.jpg',
        tags: 'test',
        imageSize: 950 * 1024,
        views: 100,
        downloads: 50,
        user: 'testuser',
      );
      expect(image.getFormattedSize(), '950.0K');

      // Test sizes in M range
      image = PixabayImage(
        id: 3,
        webformatURL: 'test.jpg',
        tags: 'test',
        imageSize: (2.3 * 1024 * 1024).round(),
        views: 100,
        downloads: 50,
        user: 'testuser',
      );
      expect(image.getFormattedSize(), '2.3M');

      // Test sizes in GB range
      image = PixabayImage(
        id: 4,
        webformatURL: 'test.jpg',
        tags: 'test',
        imageSize: (1.2 * 1024 * 1024 * 1024).round(),
        views: 100,
        downloads: 50,
        user: 'testuser',
      );
      expect(image.getFormattedSize(), '1.2GB');
    });

    test('should format views and downloads correctly', () {
      var image = PixabayImage(
        id: 1,
        webformatURL: 'test.jpg',
        tags: 'test',
        imageSize: 1000,
        views: 500,
        downloads: 1500,
        user: 'testuser',
      );
      expect(image.getFormattedViewsOrDownloads(), '500');
      expect(image.getFormattedViewsOrDownloads(), '1.5K');

      image = PixabayImage(
        id: 2,
        webformatURL: 'test.jpg',
        tags: 'test',
        imageSize: 1000,
        views: 2500000,
        downloads: 750000,
        user: 'testuser',
      );
      expect(image.getFormattedViewsOrDownloads(), '2.5M');
      expect(image.getFormattedViewsOrDownloads(), '750.0K');
    });

    test('should handle user field correctly', () {
      var image = PixabayImage(
        id: 1,
        webformatURL: 'test.jpg',
        tags: 'nature',
        imageSize: 1000,
        views: 100,
        downloads: 50,
        user: 'Josch13',
      );
      expect(image.user, 'Josch13');

      // Test JSON serialization with user field
      final json = image.toJson();
      expect(json['user'], 'Josch13');

      // Test JSON deserialization with user field
      final reconstructed = PixabayImage.fromJson(json);
      expect(reconstructed.user, 'Josch13');
    });

    test('should handle missing user field in JSON', () {
      final jsonWithoutUser = {
        'id': 1,
        'webformatURL': 'test.jpg',
        'tags': 'nature',
        'imageSize': 1000,
        'views': 100,
        'downloads': 50,
        // 'user' field is missing
      };

      final image = PixabayImage.fromJson(jsonWithoutUser);
      expect(image.user, 'Unknown');
    });
  });

  group('FavoritesService Tests', () {
    setUp(() {
      // Initialize shared preferences with in-memory implementation for testing
      SharedPreferences.setMockInitialValues({});
    });

    test('should add and retrieve favorites correctly', () async {
      final testImage = PixabayImage(
        id: 123,
        webformatURL: 'https://test.com/image.jpg',
        tags: 'nature, landscape',
        imageSize: 1024 * 1024,
        views: 1000,
        downloads: 500,
        user: 'TestPhotographer',
      );

      // Initially should be empty
      var favorites = await FavoritesService.getFavorites();
      expect(favorites.isEmpty, true);

      // Add to favorites
      await FavoritesService.addToFavorites(testImage);

      // Should now contain the image
      favorites = await FavoritesService.getFavorites();
      expect(favorites.length, 1);
      expect(favorites.first.id, 123);
      expect(favorites.first.tags, 'nature, landscape');
      expect(favorites.first.user, 'TestPhotographer');

      // Should be marked as favorite
      final isFavorite = await FavoritesService.isFavorite(testImage);
      expect(isFavorite, true);

      // Remove from favorites
      await FavoritesService.removeFromFavorites(testImage);

      // Should be empty again
      favorites = await FavoritesService.getFavorites();
      expect(favorites.isEmpty, true);

      // Should not be marked as favorite
      final isStillFavorite = await FavoritesService.isFavorite(testImage);
      expect(isStillFavorite, false);
    });

    test('should not add duplicate favorites', () async {
      final testImage = PixabayImage(
        id: 456,
        webformatURL: 'https://test.com/image2.jpg',
        tags: 'mountains',
        imageSize: 2 * 1024 * 1024,
        views: 5000,
        downloads: 1200,
        user: 'MountainLover',
      );

      // Add to favorites twice
      await FavoritesService.addToFavorites(testImage);
      await FavoritesService.addToFavorites(testImage);

      // Should only contain one instance
      final favorites = await FavoritesService.getFavorites();
      expect(favorites.length, 1);
      expect(favorites.first.id, 456);
    });

    test('should persist favorites across service calls', () async {
      final testImage1 = PixabayImage(
        id: 111,
        webformatURL: 'https://test.com/image1.jpg',
        tags: 'sunset',
        imageSize: 1024 * 1024,
        views: 800,
        downloads: 300,
        user: 'SunsetPhotographer',
      );

      final testImage2 = PixabayImage(
        id: 222,
        webformatURL: 'https://test.com/image2.jpg',
        tags: 'ocean',
        imageSize: 2 * 1024 * 1024,
        views: 1500,
        downloads: 750,
        user: 'OceanExplorer',
      );

      // Add multiple favorites
      await FavoritesService.addToFavorites(testImage1);
      await FavoritesService.addToFavorites(testImage2);

      // Should contain both
      var favorites = await FavoritesService.getFavorites();
      expect(favorites.length, 2);

      // Remove one
      await FavoritesService.removeFromFavorites(testImage1);

      // Should contain only one
      favorites = await FavoritesService.getFavorites();
      expect(favorites.length, 1);
      expect(favorites.first.id, 222);
      expect(favorites.first.user, 'OceanExplorer');
    });
  });
}

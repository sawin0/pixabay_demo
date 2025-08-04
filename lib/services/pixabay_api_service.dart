import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/pixabay_image.dart';

class PixabayApiService {
  static String get _apiKey => dotenv.env['PIXABAY_API_KEY'] ?? '';
  static const String _baseUrl = 'https://pixabay.com/api/';

  static Future<List<PixabayImage>> searchImages(
    String query, {
    int page = 1,
    int perPage = 20,
  }) async {
    final url = Uri.parse(
      '$_baseUrl?key=$_apiKey&q=$query&image_type=photo&per_page=$perPage&page=$page',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> hits = data['hits'];

        return hits.map((json) => PixabayImage.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load images: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching images: $e');
    }
  }
}

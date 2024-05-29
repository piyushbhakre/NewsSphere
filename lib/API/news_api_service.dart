import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsApiService {
  final String apiKey;

  NewsApiService({required this.apiKey});

  Future<List<dynamic>> fetchNews({List<String>? categories}) async {
    if (categories == null || categories.isEmpty) {
      final response = await http.get(Uri.parse('https://newsapi.org/v2/top-headlines?country=in&apiKey=$apiKey'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['articles'];
      } else {
        throw Exception('Failed to load news');
      }
    } else {
      List<dynamic> allArticles = [];
      for (String category in categories) {
        final response = await http.get(Uri.parse('https://newsapi.org/v2/top-headlines?country=in&category=$category&apiKey=$apiKey'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          allArticles.addAll(data['articles']);
        } else {
          throw Exception('Failed to load news for category $category');
        }
      }
      return allArticles;
    }
  }
}

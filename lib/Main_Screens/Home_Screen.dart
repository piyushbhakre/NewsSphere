import 'package:flutter/material.dart';
import 'package:newssphere/API/news_api_service.dart';
import 'package:newssphere/API/preferences_service.dart';
import 'package:newssphere/Main_Screens/settings_page.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class SwipeCardPage extends StatefulWidget {
  final String apiKey;

  SwipeCardPage({required this.apiKey});

  @override
  _SwipeCardPageState createState() => _SwipeCardPageState();
}

class _SwipeCardPageState extends State<SwipeCardPage> with SingleTickerProviderStateMixin {
  late Future<List<dynamic>> _newsFuture;
  Map<String, bool> _categories = {
    'business': true,
    'entertainment': true,
    'general': true,
    'health': true,
    'science': true,
    'sports': true,
    'technology': true,
  };
  final PreferencesService _preferencesService = PreferencesService();
  Timer? _timer;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _startNewsUpdateTimer();

    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final categories = await _preferencesService.getCategoryPreferences();
    setState(() {
      _categories = categories;
    });
    _fetchNews();
  }

  void _fetchNews() {
    final selectedCategories = _categories.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    setState(() {
      _newsFuture = NewsApiService(apiKey: widget.apiKey).fetchNews(categories: selectedCategories);
    });
  }

  void _startNewsUpdateTimer() {
    _timer = Timer.periodic(Duration(minutes: 5), (timer) {
      _fetchNews();
    });
  }

  void _openSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SettingsDialog(
          categories: _categories,
          onSave: (updatedCategories) {
            setState(() {
              _categories = updatedCategories;
            });
            _preferencesService.saveCategoryPreferences(updatedCategories);
            _fetchNews();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'NewsSphere',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Image.asset(
              "assets/Icon/cATEGORIES.png",
              width: 34.0,
              height: 34.0,
            ),
            onPressed: _openSettingsDialog,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.yellowAccent, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<dynamic>>(
          future: _newsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.white),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'No news available',
                  style: TextStyle(color: Colors.white),
                ),
              );
            } else {
              final newsArticles = snapshot.data!;
              return AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return PageView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: newsArticles.length,
                    itemBuilder: (context, index) {
                      return FadeTransition(
                        opacity: _animation,
                        child: buildCard(newsArticles[index]),
                      );
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget buildCard(dynamic article) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final publishedAt = article['publishedAt'] != null
        ? dateFormat.format(DateTime.parse(article['publishedAt']))
        : 'Unknown date';
    final sourceName = article['source']['name'] ?? 'Unknown source';
    final authorName = article['author'] ?? 'Unknown author';

    return Card(
      elevation: 12,
      shadowColor: Colors.black45,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              article['urlToImage'] ?? 'https://via.placeholder.com/400x300',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article['title'] ?? 'No title',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: 'RobotoMono',
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  article['description'] ?? 'No description',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black54,
                    fontFamily: 'RobotoMono',
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Author: $authorName',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black54,
                    fontFamily: 'RobotoMono',
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Source: $sourceName',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black54,
                        fontFamily: 'RobotoMono',
                      ),
                    ),
                    Text(
                      'Date: $publishedAt',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black54,
                        fontFamily: 'RobotoMono',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

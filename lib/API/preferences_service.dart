import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  Future<void> saveCategoryPreferences(Map<String, bool> categories) async {
    final prefs = await SharedPreferences.getInstance();
    categories.forEach((key, value) {
      prefs.setBool(key, value);
    });
  }

  Future<Map<String, bool>> getCategoryPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final categories = {
      'business': prefs.getBool('business') ?? true,
      'entertainment': prefs.getBool('entertainment') ?? true,
      'general': prefs.getBool('general') ?? true,
      'health': prefs.getBool('health') ?? true,
      'science': prefs.getBool('science') ?? true,
      'sports': prefs.getBool('sports') ?? true,
      'technology': prefs.getBool('technology') ?? true,
    };
    return categories;
  }
}

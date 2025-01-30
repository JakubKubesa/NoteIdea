import 'package:shared_preferences/shared_preferences.dart';

List<String> categories = [];

Future<void> loadCategories() async {
  final prefs = await SharedPreferences.getInstance();
  categories = prefs.getStringList('categories') ?? ['Work', 'Personal', 'Ideas', 'Other'];
}

Future<void> saveCategories() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('categories', categories);
}

void addCategory(String category) {
  if (!categories.contains(category)) {
    categories.add(category);
    saveCategories();
  }
}

void removeCategory(String category) {
  categories.remove(category);
  saveCategories();
}

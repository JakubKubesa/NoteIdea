import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'note_idea_home_page.dart';
import 'additional_files/bottom_menu.dart';
import 'additional_files/color.dart';
import 'settings.dart';
import 'additional_files/category_list.dart';
import '../models/note.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadNotes();
  }

  Future<void> _loadCategories() async {
    await loadCategories();
    setState(() {});
  }

  Future<void> _loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedNotes = prefs.getString('notes');

    if (savedNotes != null) {
      List<dynamic> decodedNotes = jsonDecode(savedNotes);
      setState(() {
        notes = decodedNotes.map((note) => Note.fromJson(note)).toList();
      });
    }
  }

  void _addCategory() {
    TextEditingController categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(
          controller: categoryController,
          decoration: const InputDecoration(
            hintText: 'Enter category name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (categoryController.text.trim().isNotEmpty) {
                setState(() {
                  addCategory(categoryController.text.trim());
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  //delete category with vertification
  void _deleteCategory(String category) {
    bool isCategoryUsed = notes.any((note) => note.category == category);

    if (isCategoryUsed) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cannot Delete Category'),
          content: const Text('This category is assigned to a note and cannot be deleted.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        removeCategory(category);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //header
      appBar: AppBar(
        backgroundColor: headerBackground,
        automaticallyImplyLeading: false,
        title: const Text(
          'Categories',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: _addCategory,
            ),
          ),
        ],
      ),
      //body
      body: Container(
        color: bodyBackground,
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                title: Text(
                  categories[index],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _deleteCategory(categories[index]);
                  },
                ),
              ),
            );
          },
        ),
      ),
      //menu
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomMenu(
        currentIndex: 1,
        onItemSelected: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const NoteIdeaHomePage()),
              );
              break;
            case 1:
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
              break;
          }
        },
      ),
    );
  }
}

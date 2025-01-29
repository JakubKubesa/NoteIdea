import 'package:flutter/material.dart';
import 'note_idea_home_page.dart';
import 'new_note_page.dart';
import 'additional_files/bottom_menu.dart';
import 'additional_files/color.dart';
import '../models/note.dart';
import 'settings.dart';



// Page for categories
class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Custom Header
      body: Container(
        color: bodyBackground, // Nastavení barvy pozadí
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              width: double.infinity,
              color: headerBackground,
              child: const Padding(
                padding: EdgeInsets.only(top: 28, left: 10),
                child: Text(
                  'Category',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            const Expanded(
              child: SizedBox(), // Zajištění, že zbývající prostor má barvu pozadí
            ),
          ],
        ),
      ),
      // Menu
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomMenu(
        currentIndex: 1,
        onItemSelected: (index) async {
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
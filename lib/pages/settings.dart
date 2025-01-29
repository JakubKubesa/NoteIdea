import 'package:flutter/material.dart';
import 'note_idea_home_page.dart';
import 'new_note_page.dart';
import 'category.dart';
import 'additional_files/bottom_menu.dart';
import 'additional_files/color.dart';
import '../models/note.dart';


// Page for settings notes

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Custom Header
      body: Container(
        color: bodyBackground,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              width: double.infinity,
              color: headerBackground,
              child: const Padding(
                padding: EdgeInsets.only(top: 28, left: 10),
                child: Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            const Expanded(
              child: SizedBox(),
            ),
          ],
        ),
      ),
      // menu
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomMenu(
        currentIndex: 2,
        onItemSelected: (index) async {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NoteIdeaHomePage()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CategoryPage()),
              );
              break;
            case 2:
              break;
          }
        },
      ),
    );
  }
}

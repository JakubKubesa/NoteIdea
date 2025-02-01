import 'package:flutter/material.dart';
import 'note_idea_home_page.dart';
import 'new_note_page.dart';
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
      // Header
      appBar: AppBar(
        backgroundColor: headerBackground,
        title: const Text('Settings'),
      ),
      body: const Center(
        child: Text('Tady bude nastavení'),
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
              final newNote = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewNotePage()),
              );
              if (newNote != null && newNote is Note) {
                Navigator.pop(context, newNote);
              }
              break;
            case 2:
              break;
          }
        },
      ),
    );
  }
}

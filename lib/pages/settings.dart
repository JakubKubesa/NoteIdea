import 'package:flutter/material.dart';
import 'note_idea_home_page.dart';
import 'new_note_page.dart';
import 'bottom_menu.dart';
import 'color.dart';

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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomMenu(
        currentIndex: 2,
        onItemSelected: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const NoteIdeaHomePage()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const NewNotePage()),
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

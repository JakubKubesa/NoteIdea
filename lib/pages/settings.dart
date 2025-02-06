import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'note_idea_home_page.dart';
import 'category.dart';
import 'additional_files/bottom_menu.dart';
import 'additional_files/color.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  Color _headerColor = headerBackground;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
      _headerColor = Color(prefs.getInt('header_color') ?? headerBackground.value);
    });
  }

  // Set dark mode
  Future<void> _toggleDarkMode(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
    setState(() {
      _isDarkMode = value;
    });
  }

  // Set header
  Future<void> _setHeaderColor(Color color) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('header_color', color.value);
    setState(() {
      _headerColor = color;
    });
  }

  //choose color of header dialog
  void _showHeaderColorPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Choose color of header"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [              
              _buildColorOption("Red", headerRed),
              _buildColorOption("Dark Red", headerRedDark),
              _buildColorOption("Green", headerGreen),
              _buildColorOption("Dark Green", headerGreenDark),
              _buildColorOption("Tyrkys", headerTyrkys),
              _buildColorOption("Blue", headerBlue),
              _buildColorOption("Dark Blue", headerBlueDark),
              _buildColorOption("Pink", headerPink),
              _buildColorOption("Dark Purple", headerPurple),
              _buildColorOption("Brown", headerBrown),
              _buildColorOption("Black", headerBlack),
            ],
          ),
        );
      },
    );
  }

  //widget for choose color of header dialog
  Widget _buildColorOption(String label, Color color) {
    return ListTile(
      title: Text(label),
      trailing: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black),
        ),
      ),
      onTap: () {
        _setHeaderColor(color);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _headerColor,
        automaticallyImplyLeading: false,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        color: _isDarkMode ? Colors.black : bodyBackground,
        child: ListView(
          children: [
            //set dark mode
            ListTile(
              title: Text(
                "Dark Mode",
                style: TextStyle(
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              trailing: Switch(
                value: _isDarkMode,
                onChanged: _toggleDarkMode,
              ),
            ),
            //set color of header
            ListTile(
              title: Text(
                "Color of header",
                style: TextStyle(
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              trailing: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _headerColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black),
                ),
              ),
              onTap: _showHeaderColorPicker,
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomMenu(
        currentIndex: 2,
        isDarkMode: _isDarkMode,
        onItemSelected: (index) async {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const NoteIdeaHomePage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
              );
              break;
            case 1:
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const CategoryPage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
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
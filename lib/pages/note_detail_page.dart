import 'package:flutter/material.dart';
import 'additional_files/color.dart';
import '../models/note.dart';
import 'new_note_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Page to view note details
class NoteDetailPage extends StatefulWidget {
  final Note note;
  final VoidCallback onDelete;
  final ValueChanged<Note> onUpdate;

  const NoteDetailPage({
    Key? key,
    required this.note,
    required this.onDelete,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  bool _isDarkMode = false;
  Color _headerColor = headerBackground;

  @override
  void initState() {
    super.initState();
    _loadDarkModePreference();
  }

  Future<void> _loadDarkModePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
      _headerColor = Color(prefs.getInt('header_color') ?? headerBackground.value);
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Header
      appBar: AppBar(
        backgroundColor: _isDarkMode ? greyDark : _headerColor,
        title: Text(
          widget.note.title,
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          // Icon for delete
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              widget.onDelete();
              Navigator.pop(context);
            },
          ),
          // Icon for edit
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              final updatedNote = await Navigator.push<Note>(
                context,
                MaterialPageRoute(
                  builder: (context) => NewNotePage(existingNote: widget.note),
                ),
              );

              if (updatedNote != null) {
                widget.onUpdate(updatedNote);
                Navigator.pop(context, updatedNote);
              }
            },
          ),
        ],
      ),
      body: Container(
        color: _isDarkMode ? Colors.black : white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  color: _isDarkMode ? Colors.black : Colors.white,
                  width: double.infinity,
                  child: Text(
                    widget.note.content,
                    style: TextStyle(
                      fontSize: 16,
                      color: _isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            // Category
            if (widget.note.category != null && widget.note.category!.isNotEmpty)
              Container(
                color: _isDarkMode ? greyDark : noteCategoryBackground,
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    'Category: ${widget.note.category}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
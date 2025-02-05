import 'package:flutter/material.dart';
import 'additional_files/color.dart';
import 'additional_files/notification_service.dart';
import 'note_idea_home_page.dart';
import 'additional_files/bottom_menu.dart';
import '../models/note.dart';
import 'additional_files/category_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Page for adding/editing notes
class NewNotePage extends StatefulWidget {
  final Note? existingNote;

  const NewNotePage({super.key, this.existingNote});

  @override
  _NewNotePageState createState() => _NewNotePageState();
}

class _NewNotePageState extends State<NewNotePage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _passwordController;
  DateTime? _reminder;
  String? _selectedCategory;
  bool _isDarkMode = false;
  Color _headerColor = headerBackground;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.existingNote?.title ?? '');
    _contentController =
        TextEditingController(text: widget.existingNote?.content ?? '');
    _passwordController =
        TextEditingController(text: widget.existingNote?.password ?? '');
    _reminder = widget.existingNote?.reminder;
    _selectedCategory = widget.existingNote?.category;
    NotificationService.init();
    _loadDarkModePreference();
  }

  // Function for picking time for notification
  Future<void> _pickReminder() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _reminder ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_reminder ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          _reminder = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  // Function to save the note
  void _saveNote() {
    final updatedNote = Note(
      title: _titleController.text,
      content: _contentController.text,
      password: _passwordController.text.isNotEmpty
          ? _passwordController.text
          : null,
      reminder: _reminder,
      category: _selectedCategory,
    );

    if (_reminder != null) {
      NotificationService.scheduleNotification(
        updatedNote.hashCode,
        updatedNote.title,
        updatedNote.content,
        _reminder!,
      );
    }

    Navigator.pop(context, updatedNote);
  }

  // Load dark mode preference
  Future<void> _loadDarkModePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
      _headerColor = Color(prefs.getInt('header_color') ?? headerBackground.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.black : white,
      // Header
      appBar: AppBar(
        backgroundColor: _isDarkMode ? Colors.black : _headerColor,
        title: const Text(
          'Edit Note',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _saveNote,
          ),
        ],
      ),
      // Body (add/edit page)
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // For title
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: _isDarkMode ? Colors.grey[900] : Colors.white,
                ),
                style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 16),
              // For your note
              TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  hintText: 'Enter your note here...',
                  hintStyle: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: _isDarkMode ? Colors.grey[900] : Colors.white,
                ),
                style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                maxLines: null,
                minLines: 10,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 16),
              // Select category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: Text(
                  'Select Category',
                  style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                ),
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(
                      category,
                      style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                dropdownColor: _isDarkMode ? Colors.grey[900] : Colors.white,
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: _isDarkMode ? Colors.grey[900] : Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              // For password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password (optional)',
                  labelStyle: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: _isDarkMode ? Colors.grey[900] : Colors.white,
                ),
                style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 16),
              // For notice settings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _reminder != null
                        ? 'Reminder: ${_reminder!.toLocal()}'.split(' ')[0]
                        : 'No reminder set',
                    style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                  ),
                  TextButton.icon(
                    onPressed: _pickReminder,
                    icon: Icon(Icons.alarm, color: _isDarkMode ? Colors.white : Colors.black),
                    label: Text(
                      'Set Reminder',
                      style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
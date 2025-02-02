import 'package:flutter/material.dart';
import 'additional_files/color.dart';
import 'additional_files/notification_service.dart'; 
import 'note_idea_home_page.dart';
import 'additional_files/bottom_menu.dart';
import '../models/note.dart';
import 'additional_files/category_list.dart';

//page for adding/editing notes

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
  }

  //function for pick time for notification
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //header
      appBar: AppBar(
        backgroundColor: headerBackground,
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
      //body (add/edit page)
      body: SingleChildScrollView(  
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //for title
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              //for your note
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'Enter your note here...',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                minLines: 10,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 16),
              //Select category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: const Text('Select Category'),
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              //for password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              //for notice settings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _reminder != null
                        ? 'Reminder: \${_reminder!.toLocal()}'.split(' ')[0]
                        : 'No reminder set',
                  ),
                  TextButton.icon(
                    onPressed: _pickReminder,
                    icon: const Icon(Icons.alarm),
                    label: const Text('Set Reminder'),
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

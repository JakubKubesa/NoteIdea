import 'package:flutter/material.dart';
import 'additional_files/color.dart';
import 'additional_files/notification_service.dart'; 
import 'note_idea_home_page.dart';
import 'settings.dart';
import 'additional_files/bottom_menu.dart';
import '../models/note.dart';

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
        title: const Text('Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      //body (add/edit page)
      body: SingleChildScrollView(  
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              //for title
              TextField(                          
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
              ),
              //for password
              const SizedBox(height: 16),
              TextField(                          
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password (optional)',
                ),
                obscureText: true,
              ),
              //for your note
              const SizedBox(height: 16),
              TextField(                          
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'Enter your note here...',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
              //for notice settings
              const SizedBox(height: 16),
              Row(          
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _reminder != null
                        ? 'Reminder: ${_reminder!.toLocal()}'
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
      //menu
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomMenu(
        currentIndex: 1,
        onItemSelected: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NoteIdeaHomePage()),
              );
              break;
            case 1:
              break;
            case 2:
              Navigator.push(
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
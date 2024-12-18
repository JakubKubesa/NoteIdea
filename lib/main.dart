import 'package:flutter/material.dart';
import 'dart:convert'; // Pro práci s JSON
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const NoteIdeaHomePage(),
    );
  }
}

class NoteIdeaHomePage extends StatefulWidget {
  const NoteIdeaHomePage({super.key});

  @override
  _NoteIdeaHomePageState createState() => _NoteIdeaHomePageState();
}

class _NoteIdeaHomePageState extends State<NoteIdeaHomePage> {
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes(); // Načtení poznámek při spuštění aplikace
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNotes = prefs.getString('notes');
    if (savedNotes != null) {
      final List<dynamic> decodedNotes = jsonDecode(savedNotes);
      setState(() {
        notes = decodedNotes
            .map((note) => Note.fromJson(note as Map<String, dynamic>))
            .toList();
      });
    }
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedNotes = jsonEncode(notes.map((note) => note.toJson()).toList());
    await prefs.setString('notes', encodedNotes);
  }

  void addNewNote(Note note) {
    setState(() {
      notes.add(note);
    });
    _saveNotes();
  }

  void updateNote(int index, Note updatedNote) {
    setState(() {
      notes[index] = updatedNote;
    });
    _saveNotes();
  }

  void deleteNote(int index) {
    setState(() {
      notes.removeAt(index);
    });
    _saveNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0, top: 7),
            child: GestureDetector(
              onTap: () async {
                final newNote = await Navigator.push<Note>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewNotePage(),
                  ),
                );
                if (newNote != null) {
                  addNewNote(newNote);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  size: 30,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.15,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade700, Colors.blue.shade500],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: const Center(
              child: Text(
                'Note Idea',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  String shortContent = notes[index].content.length > 30
                      ? notes[index].content.substring(0, 30) + '...'
                      : notes[index].content;

                  return Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        notes[index].title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        shortContent,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      onTap: () async {
                        final updatedNote = await Navigator.push<Note>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NoteDetailPage(
                              note: notes[index],
                              onDelete: () => deleteNote(index),
                              onUpdate: (updatedNote) =>
                                  updateNote(index, updatedNote),
                            ),
                          ),
                        );

                        if (updatedNote != null) {
                          updateNote(index, updatedNote);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Note {
  final String title;
  final String content;

  Note({
    required this.title,
    required this.content,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      title: json['title'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
    };
  }
}

class NewNotePage extends StatefulWidget {
  final Note? existingNote;

  const NewNotePage({super.key, this.existingNote});

  @override
  _NewNotePageState createState() => _NewNotePageState();
}

class _NewNotePageState extends State<NewNotePage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.existingNote?.title ?? '');
    _contentController =
        TextEditingController(text: widget.existingNote?.content ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: const Text('Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              final updatedNote = Note(
                title: _titleController.text,
                content: _contentController.text,
              );
              Navigator.pop(context, updatedNote);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              maxLines: 19,
            ),
          ],
        ),
      ),
    );
  }
}

class NoteDetailPage extends StatelessWidget {
  final Note note;
  final VoidCallback onDelete;
  final ValueChanged<Note> onUpdate;

  const NoteDetailPage({
    super.key,
    required this.note,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: Text(note.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              onDelete();
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updatedNote = await Navigator.push<Note>(
                context,
                MaterialPageRoute(
                  builder: (context) => NewNotePage(existingNote: note),
                ),
              );

              if (updatedNote != null) {
                onUpdate(updatedNote);
                Navigator.pop(context, updatedNote);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(note.content),
      ),
    );
  }
}

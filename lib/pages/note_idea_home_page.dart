import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';
import 'new_note_page.dart';
import 'note_detail_page.dart';

class NoteIdeaHomePage extends StatefulWidget {
  const NoteIdeaHomePage({super.key});

  @override
  _NoteIdeaHomePageState createState() => _NoteIdeaHomePageState();
}

class _NoteIdeaHomePageState extends State<NoteIdeaHomePage> {
  List<Note> notes = [];
  List<Note> filteredNotes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
    filteredNotes = notes; // Default to showing all notes
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
        filteredNotes = List.from(notes); // Synchronizace filtrovaných poznámek
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
      filteredNotes = List.from(notes); // Aktualizace filtrovaného seznamu
    });
    _saveNotes();
  }

  void updateNote(int index, Note updatedNote) {
    setState(() {
      notes[index] = updatedNote;
      filteredNotes = List.from(notes); // Aktualizace filtrovaného seznamu
    });
    _saveNotes();
  }

  void deleteNote(int index) {
    setState(() {
      notes.removeAt(index);
      filteredNotes = List.from(notes); // Aktualizace filtrovaného seznamu
    });
    _saveNotes();
  }

  void updateFilteredNotes(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredNotes = List.from(notes); // Zobraz všechny poznámky
      } else {
        filteredNotes = notes
            .where((note) =>
                note.title.toLowerCase().contains(query.toLowerCase()) ||
                note.content.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

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
          // Nadpis a dekorace (zabírá 22 % výšky obrazovky)
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
              child: Padding(
                padding: EdgeInsets.only(top: 16.0),
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
          ),
          // Vyhledávací pole
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (query) {
                updateFilteredNotes(query); // Aktualizuje filtrované poznámky
              },
            ),
          ),
          // Seznam poznámek
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView.builder(
                itemCount: filteredNotes.length,
                itemBuilder: (context, index) {
                  String shortContent = filteredNotes[index].content.length > 30
                      ? filteredNotes[index].content.substring(0, 30) + '...'
                      : filteredNotes[index].content;

                  return Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        const BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        filteredNotes[index].title,
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
                              note: filteredNotes[index],
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

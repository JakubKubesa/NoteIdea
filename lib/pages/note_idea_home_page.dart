import 'package:flutter/material.dart';
import 'additional_files/color.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'additional_files/bottom_menu.dart';
import '../models/note.dart';
import 'new_note_page.dart';
import 'note_detail_page.dart';
import 'settings.dart';
import 'category.dart';

//main page

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
    filteredNotes = notes; 
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
        filteredNotes = List.from(notes); 
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
      filteredNotes = List.from(notes); 
    });
    _saveNotes();
  }

  void updateNote(int index, Note updatedNote) {
    setState(() {
      notes[index] = updatedNote;
      filteredNotes = List.from(notes); 
    });
    _saveNotes();
  }

  void deleteNote(int index) {
    setState(() {
      notes.removeAt(index);
      filteredNotes = List.from(notes); 
    });
    _saveNotes();
  }

  void updateFilteredNotes(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredNotes = List.from(notes); 
      } else {
        filteredNotes = notes
            .where((note) =>
                note.title.toLowerCase().contains(query.toLowerCase()) ||
                note.content.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  //validate access for note detail
  Future<void> _showPasswordDialog(Note note, int index) async {
    final controller = TextEditingController();
    bool isAuthenticated = false;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Password'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'Password'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (note.password == controller.text) {
                isAuthenticated = true;
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Incorrect password')),
                );
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (isAuthenticated) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NoteDetailPage(
            note: note,
            onDelete: () => deleteNote(index),
            onUpdate: (updatedNote) => updateNote(index, updatedNote),
          ),
        ),
      );
    }
  }

  //change the order in the list of notes
  void reorderNotes(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = notes.removeAt(oldIndex);
      notes.insert(newIndex, item);
      filteredNotes = List.from(notes); 
    });
    _saveNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          //header
          Container(
            height: MediaQuery.of(context).size.height * 0.20,
            decoration: BoxDecoration(
              color: headerBackground
            ),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 50.0),
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

          
          //search engine
          Container(
            color: bodyBackground,
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
                updateFilteredNotes(query);
              },
            ),
          ),
          //body - list of notes
          Expanded(
            child: Container(
              color: bodyBackground
              ,
              child: ReorderableListView(
                onReorder: reorderNotes,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                children: List.generate(
                  filteredNotes.length,
                  (index) {
                    return Container(
                      key: ValueKey(filteredNotes[index].title),
                      margin:
                          const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
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
                          filteredNotes[index].title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          if (filteredNotes[index].password != null) {
                            _showPasswordDialog(filteredNotes[index], index);
                          } else {
                            Navigator.push(
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
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      //bottom menu
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomMenu(
        currentIndex: 0,
        onItemSelected: (index) async {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CategoryPage()),
              );
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
      //button add note
      floatingActionButton: Stack(
        children: [
          Positioned(
            top: 105,
            right: 1,
            child: FloatingActionButton(
              onPressed: () async {
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
              backgroundColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.add,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

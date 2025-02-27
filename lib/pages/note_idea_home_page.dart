import 'package:flutter/material.dart';
import 'additional_files/color.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'additional_files/bottom_menu.dart';
import 'additional_files/category_list.dart';
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
  bool _isDarkMode = false;
  Color _headerColor = headerBackground;
  String? selectedCategory;  

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _loadCategories();
    _loadDarkModePreference();
    filteredNotes = notes; 
  }

  Future<void> _loadCategories() async {
    await loadCategories();
    setState(() {});
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
      filteredNotes = notes.where((note) {
        final matchesQuery = note.title.toLowerCase().contains(query.toLowerCase());
        final matchesCategory = selectedCategory == null || note.category == selectedCategory;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  //Dark mode + header
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
            onPressed: () async {
              if (note.password == controller.text) {
                isAuthenticated = true;
  
                FocusScope.of(context).unfocus();
  
                await Future.delayed(const Duration(milliseconds: 300));
  
                if (context.mounted) Navigator.pop(context);
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
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => NoteDetailPage(
            note: note,
            onDelete: () => deleteNote(index),
            onUpdate: (updatedNote) => updateNote(index, updatedNote),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child;
          },
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
              color: _headerColor,
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
          ),// search and category filter
          Container(
            color: _isDarkMode ? Colors.black : bodyBackground,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Search field
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      fillColor: _isDarkMode ? filterBackgroundDark : filterBackground,
                      filled: true,
                      hintText: 'Search notes...',
                      hintStyle: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.grey,
                      ),
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                    onChanged: (query) {
                      updateFilteredNotes(query);
                    },
                  ),
                ),
                SizedBox(width: 8),
                //category filter
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: _isDarkMode ?  categoryBackgroundDark : categoryBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      hint: Row(
                        children: [
                          Icon(Icons.filter_list, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            'Select Category',
                            style: TextStyle(
                              color: _isDarkMode ? Colors.white : Colors.black, 
                            ),
                          ),
                        ],
                      ),
                      icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                      dropdownColor: _isDarkMode ? Colors.black : Colors.white,
                      style: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black,
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                          updateFilteredNotes('');
                        });
                      },
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text(
                            'Select Category',
                            style: TextStyle(
                              color: _isDarkMode ? Colors.white : Colors.black, 
                            ),
                          ),
                        ),
                        ...categories.map<DropdownMenuItem<String>>((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(
                              category,
                              style: TextStyle(
                                color: _isDarkMode ? Colors.white : Colors.black,  
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: _isDarkMode ? Colors.black : bodyBackground,
              child: ReorderableListView(
                onReorder: reorderNotes,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                children: List.generate(
                  filteredNotes.length,
                  (index) {
                    return Container(
                      key: ValueKey(filteredNotes[index].title),
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      decoration: BoxDecoration(
                        color: _isDarkMode ? listBackgroundDart : Colors.white,
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
                        contentPadding: const EdgeInsets.all(12),
                        title: Text(
                          filteredNotes[index].title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        trailing: filteredNotes[index].password != null
                            ? Icon(Icons.lock, color: Colors.grey)
                            : null,
                        onTap: () {
                          if (filteredNotes[index].password != null) {
                            _showPasswordDialog(filteredNotes[index], index);
                          } else {Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => NoteDetailPage(
                                  note: filteredNotes[index],
                                  onDelete: () => deleteNote(index),
                                  onUpdate: (updatedNote) => updateNote(index, updatedNote),
                                ),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return child; // Žádná animace
                                },
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
        isDarkMode: _isDarkMode,
        currentIndex: 0,
        onItemSelected: (index) async {
          switch (index) {
            case 0:
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
            Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const SettingsPage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
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

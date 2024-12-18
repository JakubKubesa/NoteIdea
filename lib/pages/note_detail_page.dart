import 'package:flutter/material.dart';
import '../models/note.dart';
import 'new_note_page.dart';

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
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Text(
            note.content,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

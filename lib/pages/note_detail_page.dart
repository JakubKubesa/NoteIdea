import 'package:flutter/material.dart';
import 'additional_files/color.dart';
import '../models/note.dart';
import 'new_note_page.dart';

//page to view note details

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
      //header
      appBar: AppBar(
        backgroundColor: headerBackground,
        title: Text(
          note.title,
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
              onDelete();
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
      body: Container(
        color: white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  color: Colors.white,
                  width: double.infinity,
                  child: Text(
                    note.content,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            if (note.category != null && note.category!.isNotEmpty)
              Container(
                color: noteCategoryBackground,
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    'Category: ${note.category}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

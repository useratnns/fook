import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../models/note_model.dart';
import 'note_editor_screen.dart';
import 'package:intl/intl.dart';
import 'package:showcaseview/showcaseview.dart';
import '../providers/settings_provider.dart';
import 'settings_view_screen.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => NoteListScreenState();
}

class NoteListScreenState extends State<NoteListScreen> {
  final GlobalKey _addNoteKey = GlobalKey();
  final GlobalKey _notesListKey = GlobalKey();
  final GlobalKey _editNoteKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  void startGuide() {
    if (!mounted) return;
    final settings = context.read<SettingsProvider>();
    ShowCaseWidget.of(context).startShowCase([_addNoteKey, _notesListKey, _editNoteKey]);
    settings.setGuideSeen('notesGuideSeen');
  }

  @override
  Widget build(BuildContext context) {
    final noteProvider = context.watch<NoteProvider>();
    final notes = noteProvider.notes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notepad'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsViewScreen()),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: (value) => noteProvider.setSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ),
      body: notes.isEmpty
          ? Showcase(
              key: _notesListKey,
              description: 'All your notes appear here',
              tooltipBackgroundColor: const Color(0xFF004D40),
              textColor: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.note_alt_outlined, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text('No notes found', style: TextStyle(color: Colors.grey[600], fontSize: 18)),
                  ],
                ),
              ),
            )
          : Showcase(
              key: _notesListKey,
              description: 'All your notes appear here',
              tooltipBackgroundColor: const Color(0xFF004D40),
              textColor: Colors.white,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  final listItem = Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    color: Color(note.color).withOpacity(0.9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)),
                      ),
                      title: Text(
                        note.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            note.content,
                            style: const TextStyle(color: Colors.black54),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            DateFormat('MMM dd, yyyy • HH:mm').format(note.updatedAt),
                            style: const TextStyle(fontSize: 10, color: Colors.black38),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.black45),
                        onPressed: () => _confirmDelete(context, noteProvider, note),
                      ),
                    ),
                  );

                  if (index == 0) {
                    return Showcase(
                      key: _editNoteKey,
                      description: 'Tap a note to edit it',
                      tooltipBackgroundColor: const Color(0xFF004D40),
                      textColor: Colors.white,
                      child: listItem,
                    );
                  }
                  return listItem;
                },
              ),
            ),
      floatingActionButton: Showcase(
        key: _addNoteKey,
        description: 'Tap here to create a new note',
        tooltipBackgroundColor: const Color(0xFF004D40),
        textColor: Colors.white,
        child: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
          ),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, NoteProvider provider, Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              provider.deleteNote(note.id!);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../database/db_helper.dart';

class NoteProvider with ChangeNotifier {
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  String _searchQuery = '';

  List<Note> get notes => _searchQuery.isEmpty ? _notes : _filteredNotes;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> loadNotes() async {
    _notes = await _dbHelper.getNotes();
    _filterNotes();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _filterNotes();
    notifyListeners();
  }

  void _filterNotes() {
    if (_searchQuery.isEmpty) {
      _filteredNotes = [];
    } else {
      _filteredNotes = _notes
          .where((note) =>
              note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              note.content.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  Future<void> addNote(Note note) async {
    final id = await _dbHelper.insertNote(note);
    _notes.insert(0, note.copyWith(id: id));
    _filterNotes();
    notifyListeners();
  }

  Future<void> updateNote(Note note) async {
    await _dbHelper.updateNote(note);
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      _filterNotes();
      notifyListeners();
    }
  }

  Future<void> deleteNote(int id) async {
    await _dbHelper.deleteNote(id);
    _notes.removeWhere((n) => n.id == id);
    _filterNotes();
    notifyListeners();
  }

  Future<void> clearAllNotes() async {
    await _dbHelper.clearAllNotes();
    _notes = [];
    _filteredNotes = [];
    notifyListeners();
  }
}

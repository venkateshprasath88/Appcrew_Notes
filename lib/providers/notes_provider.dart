import 'package:flutter/material.dart';
import '../models/note_model.dart';

class NotesProvider extends ChangeNotifier {
  List<NoteModel> _allNotes = [];
  List<NoteModel> filteredNotes = [];

  void setNotes(List<NoteModel> notes) {
    _allNotes = notes;
    filteredNotes = notes;
    notifyListeners();
  }

  void search(String query) {
    filteredNotes = _allNotes
        .where((n) =>
        n.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
    notifyListeners();
  }
}

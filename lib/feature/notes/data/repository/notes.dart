import 'package:kayko_challenge/feature/notes/data/model/notes.dart';

abstract class NoteRepository {
  Future<void> addNote(NoteModel note);
  Future<List<NoteModel>> getNotes();
  Future<void> deleteNote(String id);
  Future<void> updateNote(NoteModel note);
  Future<void> syncNotes();
}

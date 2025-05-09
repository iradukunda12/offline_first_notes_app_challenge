import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_ce/hive.dart';
import 'package:kayko_challenge/feature/notes/data/model/notes.dart';
import 'package:kayko_challenge/feature/notes/data/repository/notes.dart';

class NoteRepositoryImpl implements NoteRepository {
  final Box<NoteModel> noteBox;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  NoteRepositoryImpl(this.noteBox);

  @override
  Future<void> addNote(NoteModel note) async {
    await noteBox.put(note.id, note);

    await firestore.collection('notes').doc(note.id).set(note.toMap());
  }

  @override
  Future<void> deleteNote(String id) async {
    await noteBox.delete(id);

    await firestore.collection('notes').doc(id).delete();
  }

  @override
  Future<List<NoteModel>> getNotes() async {
    return noteBox.values.toList();
  }

  @override
  Future<void> updateNote(NoteModel note) async {
    await note.save();

    await firestore.collection('notes').doc(note.id).update(note.toMap());
  }

  @override
  Future<void> syncNotes() async {
    final localNotes = noteBox.values.toList();

    for (var note in localNotes) {
      try {
        final firebaseNote =
            await firestore.collection('notes').doc(note.id).get();

        if (!firebaseNote.exists) {
          await firestore.collection('notes').doc(note.id).set(note.toMap());
        }

        final updatedNote = note.copyWith(syncStatus: SyncStatus.synced);
        await noteBox.put(note.id, updatedNote);
      } catch (e) {
        final failedNote = note.copyWith(syncStatus: SyncStatus.failed);
        await noteBox.put(note.id, failedNote);
      }
    }
  }
}

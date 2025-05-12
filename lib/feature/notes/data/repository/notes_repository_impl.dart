import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_ce/hive.dart';
import 'package:kayko_challenge/feature/notes/data/repository/notes.dart';

import '../model/notes.dart';

class NoteRepositoryImpl implements NoteRepository {
  final Box<NoteModel> noteBox;
  late final FirebaseFirestore firestore = FirebaseFirestore.instance;

  NoteRepositoryImpl(this.noteBox);

  @override
  Future<NoteModel> addNote(NoteModel note) async {
    await noteBox.put(note.id, note);

    try {
      await firestore
          .collection('notes')
          .doc(note.id)
          .set(note.toEncryptedMap());
      final syncedNote = note.copyWith(syncStatus: SyncStatus.synced);
      await noteBox.put(note.id, syncedNote);
      return syncedNote;
    } catch (e) {
      final failedNote = note.copyWith(syncStatus: SyncStatus.failed);
      await noteBox.put(note.id, failedNote);
      print('Failed to sync note: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    final note = noteBox.get(id);
    if (note == null) return;

    // Mark as pending deletion if offline
    if (note.syncStatus == SyncStatus.pending) {
      await noteBox.put(id, note.copyWith(syncStatus: SyncStatus.pending));
    } else {
      try {
        await firestore.collection('notes').doc(id).delete();
        await noteBox.delete(id);
      } catch (e) {
        // Keep the note but mark as failed
        await noteBox.put(id, note.copyWith(syncStatus: SyncStatus.failed));
        rethrow;
      }
    }
  }

  @override
  Future<NoteModel?> getNoteById(String id) async {
    return noteBox.get(id);
  }

  @override
  Future<List<NoteModel>> getNotes() async {
    return noteBox.values.toList();
  }

  @override
  Future<void> updateNote(NoteModel note) async {
    await noteBox.put(note.id, note);

    if (note.syncStatus == SyncStatus.pending) {
      try {
        await firestore
            .collection('notes')
            .doc(note.id)
            .set(note.toEncryptedMap(), SetOptions(merge: true));
        await noteBox.put(
            note.id, note.copyWith(syncStatus: SyncStatus.synced));
      } catch (e) {
        await noteBox.put(
            note.id, note.copyWith(syncStatus: SyncStatus.failed));
        rethrow;
      }
    }
  }

  @override
  Future<void> syncNotes() async {
    final pendingNotes = noteBox.values
        .where((note) => note.syncStatus == SyncStatus.pending)
        .toList();

    for (var note in pendingNotes) {
      try {
        if (noteBox.get(note.id) == null) {
          await firestore.collection('notes').doc(note.id).delete();
        } else {
          final doc = await firestore.collection('notes').doc(note.id).get();
          if (doc.exists) {
            await doc.reference.update(note.toMap());
          } else {
            await doc.reference
                .set(note.toEncryptedMap(), SetOptions(merge: true));
          }
          await noteBox.put(
              note.id, note.copyWith(syncStatus: SyncStatus.synced));
        }
      } catch (e) {
        await noteBox.put(
            note.id, note.copyWith(syncStatus: SyncStatus.failed));
      }
    }
  }
}

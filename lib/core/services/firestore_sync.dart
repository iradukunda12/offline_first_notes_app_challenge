import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kayko_challenge/feature/notes/data/model/notes.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sync offline notes with Firestore
  Future<void> syncOfflineNotes() async {
    // Retrieve offline notes from your local storage 
    final offlineNotes = await _getOfflineNotes();

    for (var note in offlineNotes) {
      try {
        await _firestore.collection('notes').add(note.toMap());
      } catch (e) {
        throw Exception("Failed to sync note: $e");
      }
    }
  }

  // Method to retrieve offline notes 
  Future<List<NoteModel>> _getOfflineNotes() async {
    
    return []; 
  }
}

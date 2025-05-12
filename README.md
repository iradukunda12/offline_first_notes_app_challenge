# offline_first_notes_app_challenge
Build a simple notes app in Flutter that works seamlessly offline and syncs when the device goes back online.

## Getting Started

Follow these steps to run the app locally:

### 1. Clone the Repository

```bash
git clone https://github.com/iradukunda12/offline_first_notes_app_challenge.git
cd kayko_challenge
```
### 2. Install Dependencies

```bash
flutter pub get
```
## Code Sreucture
    lib/
    ├── core/
    │ ├── bloc/ # ConnectivityCubit
    │ ├── services/ # Encryption, Firestore
    │ └── models/ # Base models
    │
    ├── features/
    │ └── notes/
    │ ├── data/
    │ │ ├── models/ # NoteModel
    │ │ └── repository/ # NoteRepositoryImpl, NoteRepository
    │ │
    │ └── presentation/
    │ ├── bloc/ # NoteBloc
    │ ├── screens/ # Full pages
    │ └── widgets/ # Reusable components
   
## Features
- 📶 **Offline-first architecture** - Full functionality without/with internet
- 🔄 **Automatic synchronization** - Seamless sync when connection restored
- 🔒 **End-to-end encryption** - Secure cloud synchronization
- 🌐 **Connection awareness** - Visual network status indicators
- ♻️ **Conflict resolution** - Smart merge for concurrent edits

## Table of Contents
- [Architecture](#architecture)
- [Offline/Online Logic](#offlineonline-logic)
- [Sync Strategy](#sync-strategy)
- [Installation](#installation)
- [Testing Sync](#testing-sync)
- [Code Structure](#code-structure)
- [Screenshots](#screenshots)

## Offline/Online Logic

### Connectivity Monitoring
```bash
// Connectivity Cubit
class ConnectivityCubit extends Cubit<ConnectivityState> {
  Future<void> _handleConnectivityChange(results) async {
    final isOnline = results.any((r) != ConnectivityResult.none);
    isOnline ? await _syncNotes() : emit(ConnectivityState.offline());
  }
  
  Future<void> _syncNotes() async {
    emit(ConnectivityState.syncing());
    await _firestoreService.syncOfflineNotes();
    emit(ConnectivityState.synced());
  }
}
```
### State Management
  ```bash
// Connectivity States
class ConnectivityState {
  final bool isOnline;
  final bool isSyncing;
  // Visual indicators
  final Color color;
  final IconData icon;
  
  const ConnectivityState.online()
      : this._(isOnline: true, color: Colors.green, icon: Icons.cloud_done);
}
```

## Sync Strategy

### Repository Implementation

```bash
class NoteRepositoryImpl implements NoteRepository {
  Future<NoteModel> addNote(NoteModel note) async {
    // 1. Local save first
    await noteBox.put(note.id, note.copyWith(syncStatus: SyncStatus.pending));
    
    // 2. Conditional cloud sync
    if (connectivityCubit.state.isOnline) {
      try {
        await firestore.doc(note.id).set(note.toEncryptedMap());
        return note.copyWith(syncStatus: SyncStatus.synced);
      } catch (e) {
        return note.copyWith(syncStatus: SyncStatus.failed);
      }
    }
    return note;
  }
  
  Future<void> syncNotes() async {
    final pendingNotes = noteBox.values.where((n) => n.syncStatus == SyncStatus.pending);
    for (var note in pendingNotes) {
      await firestore.doc(note.id).set(note.toEncryptedMap());
      await noteBox.put(note.id, note.copyWith(syncStatus: SyncStatus.synced));
    }
  }
}
```
### Encryption
```bash
// Secure data transfer
Map<String, dynamic> toEncryptedMap() {
  return {
    'title': EncryptionService.encryptText(title),
    'description': EncryptionService.encryptText(description),
    'syncStatus': syncStatus.name
  };
}
```
## Screenshoot


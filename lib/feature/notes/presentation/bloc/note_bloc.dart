import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kayko_challenge/core/services/bloc/connectivity_cubit.dart';
import 'package:kayko_challenge/feature/notes/data/model/notes.dart';
import 'package:kayko_challenge/feature/notes/data/repository/notes.dart';

import 'note_event.dart';
import 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final NoteRepository repository;
  final ConnectivityCubit connectivityCubit;
  StreamSubscription? _connectivitySubscription;

  NoteBloc(this.repository, this.connectivityCubit) : super(NoteInitial()) {
    on<AddNoteEvent>(_onAddNote);
    on<DeleteNoteEvent>(_onDeleteNote);
    on<UpdateNoteEvent>(_onUpdateNote);
    on<LoadNotesEvent>(_onLoadNotes);
    on<SyncNotesEvent>(_onSyncNotes);

    _connectivitySubscription = connectivityCubit.stream.listen((state) {
      if (state.isOnline && !state.isSyncing) {
        add(SyncNotesEvent());
      }
    });
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadNotes(
      LoadNotesEvent event, Emitter<NoteState> emit) async {
    emit(NoteLoading());
    try {
      final notes = await repository.getNotes();
      emit(NotesLoaded(notes));
    } catch (e) {
      emit(NoteFailure("Failed to load notes: ${e.toString()}"));
    }
  }

  Future<void> _onAddNote(AddNoteEvent event, Emitter<NoteState> emit) async {
    emit(NoteLoading());
    try {
      final note = NoteModel(
        id: event.title + DateTime.now().millisecondsSinceEpoch.toString(),
        title: event.title,
        description: event.description,
        imagePath: event.imagePath,
       
        syncStatus: SyncStatus.pending,
      );

      await repository.addNote(note);

      
      final updatedNote = await repository.addNote(note);
      if (updatedNote.syncStatus == SyncStatus.synced) {
        emit(NoteSuccess("Note saved and synced"));
      } else {
        emit(NoteSuccess("Note saved locally. Will sync when online"));
      }

      add(LoadNotesEvent());
    } catch (e) {
      emit(NoteFailure("Failed to add note: ${e.toString()}"));
    }
  }

  Future<void> _onDeleteNote(
      DeleteNoteEvent event, Emitter<NoteState> emit) async {
    emit(NoteLoading());
    try {
      await repository.deleteNote(event.id);

      if (!connectivityCubit.state.isOnline) {
        emit(NoteSuccess("Note deleted locally. Will sync when online"));
      } else {
        emit(NoteSuccess("Note deleted and synced"));
      }

      add(LoadNotesEvent());
    } catch (e) {
      emit(NoteFailure("Failed to delete note: ${e.toString()}"));
    }
  }

  Future<void> _onUpdateNote(
      UpdateNoteEvent event, Emitter<NoteState> emit) async {
    emit(NoteLoading());
    try {
      final updatedNote = NoteModel(
        id: event.id,
        title: event.title,
        description: event.description,
        imagePath: event.imagePath,
        syncStatus: connectivityCubit.state.isOnline
            ? SyncStatus.synced
            : SyncStatus.pending,
      );

      await repository.updateNote(updatedNote);

      if (!connectivityCubit.state.isOnline) {
        emit(NoteSuccess("Note updated locally. Will sync when online"));
      } else {
        emit(NoteSuccess("Note updated and synced"));
      }

      add(LoadNotesEvent());
    } catch (e) {
      emit(NoteFailure("Failed to update note: ${e.toString()}"));
    }
  }

  Future<void> _onSyncNotes(
      SyncNotesEvent event, Emitter<NoteState> emit) async {
    try {
      await repository.syncNotes();
      add(LoadNotesEvent());
    } catch (e) {
      emit(NoteFailure("Sync failed: ${e.toString()}"));
    }
  }
}

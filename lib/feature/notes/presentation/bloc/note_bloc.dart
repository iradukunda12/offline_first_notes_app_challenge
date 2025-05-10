import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kayko_challenge/feature/notes/data/model/notes.dart';
import 'package:kayko_challenge/feature/notes/data/repository/notes.dart';

import 'note_event.dart';
import 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final NoteRepository repository;

  NoteBloc(this.repository) : super(NoteInitial()) {
    on<AddNoteEvent>(_onAddNote);
    on<DeleteNoteEvent>(_onDeleteNote);
    on<UpdateNoteEvent>(_onUpdateNote);
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

      emit(NoteSuccess());
    } catch (e) {
      emit(NoteFailure("Failed to add note: ${e.toString()}"));
    }
  }

  Future<void> _onDeleteNote(
      DeleteNoteEvent event, Emitter<NoteState> emit) async {
    emit(NoteLoading());

    try {
      await repository.deleteNote(event.id);

      emit(NoteSuccess());
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
        syncStatus: SyncStatus.pending, // set to pending if it's being edited
      );

      await repository.updateNote(updatedNote);

      emit(NoteSuccess());
    } catch (e) {
      emit(NoteFailure("Failed to update note: ${e.toString()}"));
      print(e.toString());
    }
  }
}

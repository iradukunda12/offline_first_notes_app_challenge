import 'package:equatable/equatable.dart';
import 'package:kayko_challenge/feature/notes/data/model/notes.dart';



abstract class NoteState extends Equatable {
  const NoteState();

  @override
  List<Object> get props => [];
}

class NoteInitial extends NoteState {}

class NoteLoading extends NoteState {}

class NoteSuccess extends NoteState {
  final String? message;

  const NoteSuccess([this.message]);

  @override
  List<Object> get props => [message ?? ''];
}

class NoteFailure extends NoteState {
  final String error;

  const NoteFailure(this.error);

  @override
  List<Object> get props => [error];
}

class NotesLoaded extends NoteState {
  final List<NoteModel> notes;

  const NotesLoaded(this.notes);

  @override
  List<Object> get props => [notes];
}

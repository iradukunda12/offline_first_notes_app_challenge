import 'package:equatable/equatable.dart';

abstract class NoteEvent extends Equatable {
  const NoteEvent();

  @override
  List<Object> get props => [];
}

class AddNoteEvent extends NoteEvent {
  final String title;
  final String description;
  final String? imagePath;

  const AddNoteEvent({
    required this.title,
    required this.description,
    this.imagePath,
  });

  @override
  List<Object> get props => [title, description];
}

class DeleteNoteEvent extends NoteEvent {
  final String id;

  DeleteNoteEvent({required this.id});
}

class UpdateNoteEvent extends NoteEvent {
  final String id;
  final String title;
  final String description;
  final String? imagePath;

  const UpdateNoteEvent({
    required this.id,
    required this.title,
    required this.description,
    this.imagePath,
  });

  @override
  List<Object> get props => [id, title, description];
}

// New events
class LoadNotesEvent extends NoteEvent {}

class SyncNotesEvent extends NoteEvent {}

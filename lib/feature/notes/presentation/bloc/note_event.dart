abstract class NoteEvent {}

class AddNoteEvent extends NoteEvent {
  final String title;
  final String description;
  final String? imagePath;

  AddNoteEvent({
    required this.title,
    required this.description,
    this.imagePath,
  });
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

  UpdateNoteEvent({
    required this.id,
    required this.title,
    required this.description,
    this.imagePath,
  });
}

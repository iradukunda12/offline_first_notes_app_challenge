import 'package:hive_ce/hive.dart';
import 'package:kayko_challenge/feature/notes/data/model/notes.dart';

class NoteModelAdapter extends TypeAdapter<NoteModel> {
  @override
  final int typeId = 0;

  @override
  NoteModel read(BinaryReader reader) {
    return NoteModel(
      id: reader.readString(),
      title: reader.readString(),
      description: reader.readString(),
      imagePath: reader.readString(),
      syncStatus: SyncStatus.values[reader.readInt()],
    );
  }

  @override
  void write(BinaryWriter writer, NoteModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.description);
    writer.writeString(obj.imagePath ?? '');
    writer.writeInt(obj.syncStatus.index);
  }
}

import 'package:hive_ce/hive.dart';

enum SyncStatus { synced, pending, failed }

@HiveType(typeId: 0)
class NoteModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String? imagePath;

  @HiveField(4)
  final SyncStatus syncStatus;

  NoteModel({
    required this.id,
    required this.title,
    required this.description,
    this.imagePath,
    this.syncStatus = SyncStatus.pending,
  });

   @override
  String toString() {
    return 'NoteModel(id: $id, title: $title, description: $description, imagePath: $imagePath, syncStatus: $syncStatus)';
  }

  // For Firebase sync
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imagePath': imagePath,
      'syncStatus': syncStatus.name,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      imagePath: map['imagePath'],
      syncStatus: SyncStatus.values.firstWhere(
        (e) => e.name == map['syncStatus'],
        orElse: () => SyncStatus.synced,
      ),
    );
  }
  NoteModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imagePath,
    SyncStatus? syncStatus,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}

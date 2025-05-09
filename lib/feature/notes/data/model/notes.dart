import 'package:hive_ce/hive.dart';

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
  final bool
      isSynced; 

  NoteModel({
    required this.id,
    required this.title,
    required this.description,
    this.imagePath,
    this.isSynced = false,
  });

  // For Firebase sync
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imagePath': imagePath,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      imagePath: map['imagePath'],
      isSynced: true,
    );
  }
}

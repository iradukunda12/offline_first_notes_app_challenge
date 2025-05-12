import 'package:hive_ce/hive.dart';
import 'package:kayko_challenge/core/services/encryption.dart';

enum SyncStatus { synced, pending, failed, notSynced }

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

  Map<String, dynamic> toEncryptedMap() {
    return {
      'id': id,
      'title': EncryptionService.encryptText(title),
      'description': EncryptionService.encryptText(description),
      'imagePath':
          imagePath != null ? EncryptionService.encryptText(imagePath!) : null,
      'syncStatus': syncStatus.name,
    };
  }

  static NoteModel fromEncryptedMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'],
      title: EncryptionService.decryptText(map['title']),
      description: EncryptionService.decryptText(map['description']),
      imagePath: map['imagePath'] != null
          ? EncryptionService.decryptText(map['imagePath'])
          : null,
      syncStatus: SyncStatus.values.firstWhere(
        (e) => e.name == map['syncStatus'],
        orElse: () => SyncStatus.synced,
      ),
    );
  }
}

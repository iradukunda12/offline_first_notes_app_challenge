import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ImageHelper {
  // Pick image from gallery and copy it to the app's document directory
  static Future<File?> pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final tempImage = File(pickedFile.path);

      // Get app's document directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = basename(pickedFile.path);

      // Copy image to local storage so it persists
      final savedImage = await tempImage.copy('${appDir.path}/$fileName');

      return savedImage;
    } else {
      return null;
    }
  }

  // Upload image and save note to Firestore
  static Future<void> saveNoteWithImage(
      String title, String description, File imageFile) async {
    try {
      final fileName = basename(imageFile.path);
      final storageRef =
          FirebaseStorage.instance.ref().child('note_images/$fileName');

      // Upload the image file
      final uploadTask = await storageRef.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Save note to Firestore
      await FirebaseFirestore.instance.collection('notes').add({
        'title': title,
        'description': description,
        'imageURL': downloadUrl,
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to save note with image: $e');
    }
  }
}

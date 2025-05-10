import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kayko_challenge/core/utils/image_helper.dart';

class CustomBottomNav extends StatefulWidget {
  final void Function({
    required String title,
    required String description,
    String? imagePath,
  }) onSave;
  final String? initialTitle;
  final String? initialDescription;
  final String? initialImagePath;
  const CustomBottomNav({super.key, required this.onSave, this.initialImagePath, this.initialTitle, this.initialDescription});

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  final textController = TextEditingController();
  final descriptionController = TextEditingController();

  File? selectedImage;
 @override
  void initState() {
    super.initState();

    if (widget.initialImagePath != null) {
      final file = File(widget.initialImagePath!);
      if (file.existsSync()) {
        selectedImage = file;
      }
    }

    textController.text = widget.initialTitle ?? '';
    descriptionController.text = widget.initialDescription ?? '';
  }


  Future<void> pickImage() async {
    final pickedImage = await ImageHelper.pickImageFromGallery();
    if (pickedImage != null) {
      setState(() {
        selectedImage = pickedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 30.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selectedImage != null)
            CircleAvatar(
              radius: 40,
              backgroundImage: FileImage(selectedImage!),
            ),
          TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'Title',
              hintStyle: TextStyle(fontSize: 16, color: Colors.black54),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black45),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black54),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Description',
                    hintStyle: TextStyle(fontSize: 16, color: Colors.black54),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black45),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.upload_file, color: Colors.white),
                label: const Text("Upload"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: ElevatedButton(
              onPressed: () {
                final title = textController.text.trim();
                final description = descriptionController.text.trim();
                final imagePath = selectedImage?.path;

                if (title.isEmpty || description.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Title and description are required")),
                  );
                  return;
                }

                widget.onSave(
                  title: title,
                  description: description,
                  imagePath: imagePath,
                );

                // Clear fields
                textController.clear();
                descriptionController.clear();
                setState(() => selectedImage = null);
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Save",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

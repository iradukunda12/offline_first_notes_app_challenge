import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  const CustomBottomNav(
      {super.key,
      required this.onSave,
      this.initialImagePath,
      this.initialTitle,
      this.initialDescription});

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
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 30.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selectedImage != null)
            CircleAvatar(
              radius: 40.r,
              backgroundImage: FileImage(selectedImage!),
            ),
          TextField(
            controller: textController,
            decoration: InputDecoration(
              hintText: 'Title',
              hintStyle: TextStyle(fontSize: 16.sp, color: Colors.black54),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black45),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black54),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Description',
                    hintStyle:
                        TextStyle(fontSize: 16.sp, color: Colors.black54),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black45),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              ElevatedButton.icon(
                onPressed: pickImage,
                icon: Icon(Icons.upload_file, color: Colors.white, size: 20.sp),
                label: Text(
                  "Upload",
                  style: TextStyle(fontSize: 14.sp),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 50.w),
            child: ElevatedButton(
              onPressed: () {
                final title = textController.text.trim();
                final description = descriptionController.text.trim();
                final imagePath = selectedImage?.path;

                if (title.isEmpty || description.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Title and description are required"),
                    ),
                  );
                  return;
                }

                widget.onSave(
                  title: title,
                  description: description,
                  imagePath: imagePath,
                );

                textController.clear();
                descriptionController.clear();
                setState(() => selectedImage = null);
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 80.w, vertical: 12.h),
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                "Save",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';

import 'package:blog_app_v1/features/blogs/models/blog_model.dart';
import 'package:blog_app_v1/features/blogs/services/blogs_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateBlogScreen extends StatefulWidget {
  const CreateBlogScreen({super.key});

  @override
  State<CreateBlogScreen> createState() => _CreateBlogScreenState();
}

class _CreateBlogScreenState extends State<CreateBlogScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  File? _imageFile;
  String? fileName;

  //Pick image
  Future pickImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
        fileName = image.name;
      });
    }
  }

  void createBlog() async {
    try {
      BlogsService blogsService = BlogsService();
      Blog blog = Blog(
        title: _titleController.text,
        content: _contentController.text,
      );
      await blogsService.createBlog(blog, _imageFile, fileName);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Blog created successfully")));
      Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Blog created successfully")));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Blog"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Title"),
                SizedBox(height: 10),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: "Enter title",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Title field is required";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                Text("Content"),
                SizedBox(height: 10),
                TextFormField(
                  controller: _contentController,
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText: "Enter content",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                if (_imageFile != null) SizedBox(height: 10),
                if (_imageFile != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(_imageFile!),
                  ),
                IconButton(onPressed: pickImage, icon: Icon(Icons.add_a_photo)),
                FilledButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      createBlog();
                    }
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: Size(double.infinity, 40),
                  ),
                  child: Text("Create"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

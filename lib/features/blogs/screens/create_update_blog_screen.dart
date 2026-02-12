import 'dart:io';
import 'package:blog_app_v1/components/loading_spinner.dart';
import 'package:blog_app_v1/features/auth/services/auth_service.dart';
import 'package:blog_app_v1/features/blogs/models/blog_model.dart';
import 'package:blog_app_v1/features/blogs/services/blogs_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateUpdateBlogScreen extends StatefulWidget {
  const CreateUpdateBlogScreen({super.key, this.blog});

  final Blog? blog;

  @override
  State<CreateUpdateBlogScreen> createState() => _CreateBlogScreenState();
}

class _CreateBlogScreenState extends State<CreateUpdateBlogScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  File? _imageFile;
  String? fileName;
  String? _networkImageUrl;
  String? oldImagePath;
  String? blogId;
  bool _removedImage = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.blog?.title ?? '');
    _contentController = TextEditingController(
      text: widget.blog?.content ?? '',
    );

    _networkImageUrl = widget.blog?.signedUrl;

    oldImagePath = widget.blog?.imagePath;
    blogId = widget.blog?.id;
  }

  //Pick image
  Future pickImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
        fileName = image.name;
        _networkImageUrl = null;
        _removedImage = false;
      });
    }
  }

  void createBlog() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Title field is required"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = AuthService().getCurrentUser();
      if (currentUser == null) {
        throw Exception("User not logged in");
      }
      BlogsService blogsService = BlogsService();

      Blog blog = Blog(
        id: '',
        authorId: currentUser.id,
        title: _titleController.text,
        content: _contentController.text,
      );

      await blogsService.createBlog(blog.toMap(), _imageFile, fileName);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Blog created successfully")));
      Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to create blog: ${error.toString()}"),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void updateBlog() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Title field is required"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }

    setState(() {
      _isLoading = true;
    });

    try {
      BlogsService blogsService = BlogsService();
      Blog blog = Blog(
        id: blogId!,
        authorId: widget.blog!.authorId,
        title: _titleController.text,
        content: _contentController.text,
        imagePath: oldImagePath,
      );
      if (_removedImage) {
        blog.imagePath = null;
      }
      await blogsService.updateBlog(
        blog.toMap(includeId: true),
        _imageFile,
        fileName,
        oldImagePath,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Blog updated successfully")));
      Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update blog: ${error.toString()}"),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      appBar: AppBar(
        title: Text(widget.blog != null ? "Update Blog" : "Create Blog"),
        centerTitle: true,
      ),
      body: _isLoading
          ? LoadingSpinner()
          : Padding(
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
                      if (_imageFile != null || _networkImageUrl != null) ...[
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Stack(
                            children: [
                              _imageFile != null
                                  ? Image.file(_imageFile!)
                                  : Image.network(
                                      _networkImageUrl!,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Text(
                                                'Failed to load image',
                                              ),
                                    ),

                              Positioned(
                                top: 6,
                                right: 6,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _imageFile = null;
                                      _networkImageUrl = null;
                                      fileName = null;
                                      _removedImage = true;
                                    });
                                  },
                                  child: IconButtonTheme(
                                    data: IconButtonThemeData(),
                                    child: Icon(Icons.cancel),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      IconButton(
                        onPressed: pickImage,
                        icon: Icon(Icons.add_a_photo),
                      ),
                      FilledButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (widget.blog != null) {
                              updateBlog();
                            } else {
                              createBlog();
                            }
                          }
                        },
                        style: FilledButton.styleFrom(
                          minimumSize: Size(double.infinity, 40),
                        ),
                        child: Text(widget.blog != null ? "Update" : "Create"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

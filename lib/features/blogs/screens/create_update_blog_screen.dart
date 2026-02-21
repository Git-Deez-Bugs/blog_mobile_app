import 'dart:typed_data';
import 'package:blog_app_v1/components/loading_spinner.dart';
import 'package:blog_app_v1/features/auth/services/auth_service.dart';
import 'package:blog_app_v1/features/blogs/models/blog_model.dart';
import 'package:blog_app_v1/features/blogs/models/image_model.dart';
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
  List<Uint8List> _imageFiles = [];
  List<String> fileNames = [];
  List<BlogImage> _networkImages = [];
  List<BlogImage> _removedImages = [];
  String? blogId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.blog?.title ?? '');
    _contentController = TextEditingController(
      text: widget.blog?.content ?? '',
    );

    _networkImages = widget.blog?.images ?? [];
    blogId = widget.blog?.id;
  }

  //Pick image
  Future pickImages() async {
    final ImagePicker picker = ImagePicker();

    final List<XFile>? images = await picker.pickMultiImage();

    if (images != null) {
      List<Uint8List> fileBytesList = [];
      List<String> nameList = [];

      for (final image in images) {
        fileBytesList.add(await image.readAsBytes());
        nameList.add(image.name);
      }

      setState(() {
        _imageFiles = [..._imageFiles, ...fileBytesList];
        fileNames = [...fileNames, ...nameList];
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

      final newBlog = await blogsService.createBlog(
        blog: blog.toMap(),
        files: _imageFiles,
        fileNames: fileNames,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Blog created successfully")));
      Navigator.pop(context, newBlog);
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
      );
      final updatedBlog = await blogsService.updateBlog(
        blog: blog.toMap(includeId: true),
        files: _imageFiles,
        fileNames: fileNames,
        removedImages: _removedImages,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Blog updated successfully")));
      Navigator.pop(context, updatedBlog);
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
    final screenWidth = MediaQuery.of(context).size.width;
    final double buttonHeight = screenWidth < 600 ? 40 : 56;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.blog != null ? "Update Blog" : "Create Blog"),
        centerTitle: true,
      ),
      body: _isLoading
          ? LoadingSpinner()
          : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600),
                child: Padding(
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

                          if (_imageFiles.isNotEmpty ||
                              _networkImages.isNotEmpty) ...[
                            SizedBox(height: 10),
                            SizedBox(
                              height: 500,
                              child: GridView.builder(
                                shrinkWrap: true,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 10,
                                      crossAxisSpacing: 10,
                                      childAspectRatio: 1,
                                    ),
                                itemCount:
                                    _networkImages.length + _imageFiles.length,
                                itemBuilder: (context, index) {
                                  final bool isNetwork =
                                      index < _networkImages.length;
                                  final Widget imageWidget = isNetwork
                                      ? Image.network(
                                          _networkImages[index].signedUrl!,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.memory(
                                          _imageFiles[index -
                                              _networkImages.length],
                                          fit: BoxFit.cover,
                                        );

                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Stack(
                                      children: [
                                        Positioned.fill(child: imageWidget),
                                        Positioned(
                                          top: 6,
                                          right: 6,
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                if (isNetwork) {
                                                  _removedImages.add(
                                                    _networkImages[index],
                                                  );
                                                  _networkImages.removeAt(
                                                    index,
                                                  );
                                                } else {
                                                  _imageFiles.removeAt(
                                                    index -
                                                        _networkImages.length,
                                                  );
                                                  fileNames.removeAt(
                                                    index -
                                                        _networkImages.length,
                                                  );
                                                }
                                              });
                                            },
                                            child: Icon(
                                              Icons.cancel,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],

                          IconButton(
                            onPressed: pickImages,
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
                              minimumSize: Size(double.infinity, buttonHeight),
                            ),
                            child: Text(
                              widget.blog != null ? "Update" : "Create",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

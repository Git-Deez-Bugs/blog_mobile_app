import 'dart:typed_data';
import 'package:blog_app_v1/components/loading_spinner.dart';
import 'package:blog_app_v1/features/auth/services/auth_service.dart';
import 'package:blog_app_v1/features/blogs/models/comment_model.dart';
import 'package:blog_app_v1/features/blogs/models/image_model.dart';
import 'package:blog_app_v1/features/blogs/services/blogs_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CommentForm extends StatefulWidget {
  const CommentForm({
    super.key,
    required this.blogId,
    this.onComment,
    this.comment,
    required this.canceUpdate,
  });

  final String blogId;
  final VoidCallback? onComment;
  final Comment? comment;
  final VoidCallback canceUpdate;

  @override
  State<CommentForm> createState() => _CommentFormState();
}

class _CommentFormState extends State<CommentForm> {
  late final TextEditingController _textController;
  List<Uint8List> _imageFiles = [];
  List<String> _fileNames = [];
  List<BlogImage> _networkImages = [];
  List<BlogImage> _removedImages = [];
  late final String _blogId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController(
      text: widget.comment?.textContent ?? '',
    );

    _networkImages = widget.comment?.images ?? [];

    _blogId = widget.blogId;
  }

  Future<void> pickImage() async {
    final List<XFile>? images = await ImagePicker().pickMultiImage();

    if (images != null) {
      List<Uint8List> fileBytes = [];
      List<String> nameList = [];

      for (final image in images) {
        fileBytes.add(await image.readAsBytes());
        nameList.add(image.name);
      }

      setState(() {
        _imageFiles = [..._imageFiles, ...fileBytes];
        _fileNames = [..._fileNames, ...nameList];
      });
    }
  }

  Future<void> createComment() async {
    if (_textController.text.trim().isEmpty && _imageFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Comment cannot be empty. add text or an image.'),
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
      Comment comment = Comment(
        id: '',
        blogId: _blogId,
        authorId: currentUser.id,
        textContent: _textController.text,
      );
      await blogsService.createComment(
        comment: comment.toMap(),
        blogId: widget.blogId,
        files: _imageFiles,
        fileNames: _fileNames,
      );
      if (widget.onComment != null) {
        widget.onComment!();
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Comment created successfully')));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create comment: ${error.toString()}'),
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

  Future<void> updateComment() async {
    if (_textController.text.trim().isEmpty &&
        (_imageFiles.isEmpty && _networkImages.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Comment cannot be empty. add text or an image.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }

    setState(() {
      _isLoading = true;
    });

    try {
      BlogsService blogsService = BlogsService();
      Comment comment = Comment(
        id: widget.comment!.id,
        blogId: _blogId,
        authorId: widget.comment!.authorId,
        textContent: _textController.text,
      );
      await blogsService.updateComment(
        comment: comment.toMap(includeId: true),
        files: _imageFiles,
        fileNames: _fileNames,
        removedImages: _removedImages,
      );
      if (widget.onComment != null) {
        widget.onComment!();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment updated successfully')),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update comment: ${error.toString()}'),
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
    super.dispose();
    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return _isLoading
        ? LoadingSpinner()
        : Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              color: Theme.of(context).colorScheme.surface,
              child: Stack(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: TextField(
                            controller: _textController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'Comment here',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      if (_imageFiles.isNotEmpty ||
                          _networkImages.isNotEmpty) ...[
                        SizedBox(height: 10),
                        SizedBox(
                          height: 500,
                          width: screenWidth < 600
                              ? screenWidth * 0.5
                              : screenWidth * 0.2,
                          child: GridView.builder(
                            shrinkWrap: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: screenWidth > 600 ? 2 : 1,
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
                                              _networkImages.removeAt(index);
                                            } else {
                                              _imageFiles.removeAt(
                                                index - _networkImages.length,
                                              );
                                              _fileNames.removeAt(
                                                index - _networkImages.length,
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

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: pickImage,
                            icon: Icon(Icons.add_a_photo),
                          ),
                          IconButton(
                            onPressed: widget.comment != null
                                ? updateComment
                                : createComment,
                            icon: Icon(Icons.send),
                          ),
                        ],
                      ),
                    ],
                  ),

                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      onPressed: widget.canceUpdate,
                      icon: Icon(
                        Icons.cancel,
                        color: Theme.of(context).colorScheme.inverseSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

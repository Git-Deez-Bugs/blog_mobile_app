import 'dart:typed_data';
import 'package:blog_app_v1/components/loading_spinner.dart';
import 'package:blog_app_v1/features/auth/services/auth_service.dart';
import 'package:blog_app_v1/features/blogs/models/comment_model.dart';
import 'package:blog_app_v1/features/blogs/services/blogs_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CommentForm extends StatefulWidget {
  const CommentForm({
    super.key,
    required this.blogId,
    this.onComment,
    this.comment,
  });

  final String blogId;
  final VoidCallback? onComment;
  final Comment? comment;

  @override
  State<CommentForm> createState() => _CommentFormState();
}

class _CommentFormState extends State<CommentForm> {
  late final TextEditingController _textController;
  Uint8List? _imageFile;
  String? _fileName;
  String? _networkImageUrl;
  String? _oldImagePath;
  late final String _blogId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController(
      text: widget.comment?.textContent ?? '',
    );

    _networkImageUrl = widget.comment?.signedUrl;
    _oldImagePath = widget.comment?.imagePath;

    _blogId = widget.blogId;
  }

  Future<void> pickImage() async {
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      final Uint8List fileBytes = await image.readAsBytes();
      setState(() {
        _imageFile = fileBytes;
        _fileName = image.name;
      });
    }
  }

  Future<void> createComment() async {
    if (_textController.text.trim().isEmpty && _imageFile == null) {
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
      AuthService authService = AuthService();
      BlogsService blogsService = BlogsService();
      Comment comment = Comment(
        id: '',
        blogId: _blogId,
        authorId: authService.getCurrentUser()!.id,
        textContent: _textController.text,
      );
      if (_imageFile == null) {
        comment.imagePath = null;
      }
      await blogsService.createComment(
        comment: comment.toMap(),
        blogId: widget.blogId,
        file: _imageFile,
        fileName: _fileName,
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
        (_imageFile == null && _networkImageUrl != null)) {
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
      AuthService authService = AuthService();
      BlogsService blogsService = BlogsService();
      Comment comment = Comment(
        id: widget.comment!.id,
        blogId: _blogId,
        authorId: authService.getCurrentUser()!.id,
        textContent: _textController.text,
        imagePath: _oldImagePath,
      );
      if ((_oldImagePath != null && _networkImageUrl == null) &&
          (_imageFile == null)) {
        comment.imagePath = null;
      }
      await blogsService.updateComment(
        comment: comment.toMap(includeId: true),
        file: _imageFile,
        fileName: _fileName,
        oldImagePath: _oldImagePath,
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
    return _isLoading
        ? LoadingSpinner()
        : Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              color: Theme.of(context).colorScheme.surface,
              child: Column(
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
                  if (_imageFile != null || _networkImageUrl != null)
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: _imageFile != null
                                ? Image.memory(_imageFile!)
                                : Image.network(_networkImageUrl!),
                          ),
                          Positioned(
                            right: 0,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _imageFile = null;
                                  _fileName = null;
                                  _networkImageUrl = null;
                                });
                              },
                              icon: const Icon(
                                Icons.cancel,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

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
            ),
          );
  }
}

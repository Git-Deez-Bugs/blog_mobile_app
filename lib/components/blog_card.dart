import 'package:blog_app_v1/components/comment_card.dart';
import 'package:blog_app_v1/components/comment_form.dart';
import 'package:blog_app_v1/components/image_layout.dart';
import 'package:blog_app_v1/components/more_options.dart';
import 'package:blog_app_v1/features/auth/services/auth_service.dart';
import 'package:blog_app_v1/features/blogs/models/blog_model.dart';
import 'package:blog_app_v1/features/blogs/models/comment_model.dart';
import 'package:blog_app_v1/features/blogs/screens/blog_screen.dart';
import 'package:blog_app_v1/features/blogs/screens/create_update_blog_screen.dart';
import 'package:blog_app_v1/features/blogs/services/blogs_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BlogCard extends StatefulWidget {
  const BlogCard({
    super.key,
    required this.blog,
    required this.disablePush,
    required this.onChanged,
    required this.onUpdate,
    required this.onDelete,
  });

  final Blog blog;
  final bool disablePush;
  final VoidCallback onChanged;
  final Function(Blog blog) onUpdate;
  final Function(String blogId) onDelete;

  @override
  State<BlogCard> createState() => _BlogCardState();
}

class _BlogCardState extends State<BlogCard> {
  bool toComment = false;
  String? commentToEdit;
  late List<Comment> _comments;
  late int _commentsCount;

  @override
  void initState() {
    super.initState();
    _comments = List.from(widget.blog.comments?.reversed ?? []);
    _commentsCount = widget.blog.commentsCount ?? _comments.length;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () async {
          if (!widget.disablePush) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlogScreen(
                  blogId: widget.blog.id,
                  onChanged: () {
                    widget.onChanged.call();
                  },
                  onUpdate: widget.onUpdate,
                  onDelete: widget.onDelete,
                ),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            //Email, Date, and MoreOptions
            Padding(
              padding: EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: widget.blog.author?.signedUrl != null
                              ? NetworkImage(widget.blog.author!.signedUrl!)
                              : AssetImage('assets/images/user.png'),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (widget.blog.author?.name ??
                                  widget.blog.author?.email ??
                                  'Unknown Author'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              DateFormat(
                                'MMM d, yyyy',
                              ).format(widget.blog.createdAt!),
                              style: TextStyle(color: Colors.blueGrey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  //MoreOptions
                  if (AuthService().getCurrentUser()?.id ==
                      widget.blog.authorId)
                    MoreOptions(
                      onUpdate: () async {
                        final updatedBlog = await Navigator.push<Blog>(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CreateUpdateBlogScreen(blog: widget.blog),
                          ),
                        );
                        if (updatedBlog != null) {
                          widget.onUpdate(updatedBlog);
                        }
                      },
                      onDelete: () async {
                        BlogsService blogsService = BlogsService();
                        await blogsService.deleteBlog(
                          blog: widget.blog,
                          haveComments: widget.disablePush,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Blog Deleted Successfully')),
                        );
                        widget.onDelete(widget.blog.id);
                        if (widget.disablePush) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                ],
              ),
            ),
            //Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  widget.blog.title!,
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
            if (widget.blog.content != null && widget.blog.content!.isNotEmpty) ...[
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    widget.blog.content!,
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
            ],
            //Images
            if (widget.blog.images!.isNotEmpty) ...[
              SizedBox(height: 15),
              ImageLayout(
                images: widget.blog.images!,
                listView: widget.disablePush,
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Text(_commentsCount.toString()),
                  SizedBox(width: 10),
                  widget.disablePush
                      ? IconButton(
                          onPressed: () {
                            toComment = !toComment;
                            setState(() {});
                          },
                          icon: Icon(Icons.comment, size: 18),
                        )
                      : Icon(Icons.comment, size: 18),
                ],
              ),
            ),
            if (toComment)
              CommentForm(
                blogId: widget.blog.id,
                onComment: (comment) {
                  setState(() {
                    _comments.insert(0, comment);
                    _commentsCount++;
                    toComment = false;
                  });
                  widget.onChanged();
                },
                canceUpdate: () {
                  setState(() {
                    toComment = false;
                  });
                },
              ),
            if (_comments.isNotEmpty) ...[
              for (var comment in _comments)
                if (commentToEdit == comment.id)
                  CommentForm(
                    blogId: widget.blog.id,
                    comment: comment,
                    onComment: (updated) {
                      setState(() {
                        final index = _comments.indexWhere(
                          (c) => c.id == updated.id,
                        );
                        if (index != -1) _comments[index] = updated;
                        commentToEdit = null;
                      });
                      widget.onChanged();
                    },
                    canceUpdate: () {
                      setState(() {
                        commentToEdit = null;
                      });
                    },
                  )
                else
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: CommentCard(
                        key: ValueKey(comment.id),
                        comment: comment,
                        onUpdate: () {
                          setState(() {
                            commentToEdit = comment.id;
                          });
                        },
                        onDelete: () {
                          setState(() {
                            _comments.removeWhere((c) => c.id == comment.id);
                            _commentsCount--;
                          });
                          widget.onChanged();
                        },
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}

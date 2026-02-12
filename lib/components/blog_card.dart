import 'package:blog_app_v1/components/comment_card.dart';
import 'package:blog_app_v1/components/comment_form.dart';
import 'package:blog_app_v1/components/more_options.dart';
import 'package:blog_app_v1/features/auth/services/auth_service.dart';
import 'package:blog_app_v1/features/blogs/models/blog_model.dart';
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
  });

  final Blog blog;
  final bool disablePush;
  final VoidCallback onChanged;

  @override
  State<BlogCard> createState() => _BlogCardState();
}

class _BlogCardState extends State<BlogCard> {
  bool toComment = false;
  String? commentToEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          if (!widget.disablePush) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlogScreen(blogId: widget.blog.id, onChanged: () => widget.onChanged.call(),),
              ),
            );
          }
        },
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
                  if (AuthService().getCurrentUser()?.id ==
                      widget.blog.authorId)
                    MoreOptions(
                      onUpdate: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CreateUpdateBlogScreen(blog: widget.blog),
                          ),
                        );
                        widget.onChanged.call();
                      },
                      onDelete: () async {
                        BlogsService blogsService = BlogsService();
                        await blogsService.deleteBlog(
                          widget.blog.toMap(includeId: true),
                        );
                        widget.onChanged.call();
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
            if (widget.blog.content != null) SizedBox(height: 10),
            if (widget.blog.content != null)
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
            if (widget.blog.signedUrl != null) SizedBox(height: 10),
            if (widget.blog.signedUrl != null)
              Image.network(widget.blog.signedUrl!),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Text(widget.blog.commentsCount.toString()),
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
                onComment: () {
                  widget.onChanged.call();
                  setState(() {
                    toComment = !toComment;
                  });
                },
              ),
            if (widget.blog.comments != null) ...[
              for (var comment in widget.blog.comments!)
                if (commentToEdit == comment.id)
                  CommentForm(
                    blogId: widget.blog.id,
                    comment: comment,
                    onComment: () => {
                      widget.onChanged.call(),
                      setState(() {
                        commentToEdit = null;
                      }),
                    },
                  )
                else
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: CommentCard(
                        comment: comment,
                        onUpdate: () {
                          setState(() {
                            commentToEdit = comment.id;
                          });
                        },
                        onDelete: () {
                          widget.onChanged.call();
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

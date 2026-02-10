import 'package:blog_app_v1/components/comment_card.dart';
import 'package:blog_app_v1/components/more_options.dart';
import 'package:blog_app_v1/features/auth/services/auth_service.dart';
import 'package:blog_app_v1/features/blogs/models/blog_model.dart';
import 'package:blog_app_v1/features/blogs/screens/blog_screen.dart';
import 'package:blog_app_v1/features/blogs/screens/create_update_blog_screen.dart';
import 'package:blog_app_v1/features/blogs/services/blogs_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BlogCard extends StatelessWidget {
  const BlogCard({super.key, required this.blog, required this.disablePush});

  final Blog blog;
  final bool disablePush;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          if (!disablePush) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlogScreen(blogId: blog.id!),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          blog.authorEmail!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          DateFormat('MMM d, yyyy').format(blog.createdAt!),
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ],
                    ),
                  ),
                  if (AuthService().getCurrentUser()?.id == blog.authorId)
                    MoreOptions(
                      onUpdate: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CreateUpdateBlogScreen(blog: blog),
                          ),
                        );
                      },
                      onDelete: () async {
                        BlogsService blogsService = BlogsService();
                        await blogsService.deleteBlog(blog);
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
                  blog.title!,
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
            if (blog.content != null) SizedBox(height: 10),
            if (blog.content != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(blog.content!, textAlign: TextAlign.justify),
                ),
              ),
            if (blog.signedUrl != null) SizedBox(height: 10),
            if (blog.signedUrl != null) Image.network(blog.signedUrl!),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Text(blog.commentsCount.toString()),
                  SizedBox(width: 10),
                  Icon(Icons.comment, size: 18),
                ],
              ),
            ),
            if (blog.comments != null) ...[
              for (var comment in blog.comments!)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: CommentCard(comment: comment),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:blog_app_v1/components/more_options.dart';
import 'package:blog_app_v1/features/auth/services/auth_service.dart';
import 'package:blog_app_v1/features/blogs/models/comment_model.dart';
import 'package:blog_app_v1/features/blogs/services/blogs_service.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CommentCard extends StatelessWidget {
  const CommentCard({
    super.key,
    required this.comment,
    required this.onUpdate,
    required this.onDelete,
  });

  final Comment comment;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;
  Future<void> deleteComment(BuildContext context) async {
    try {
      BlogsService blogsService = BlogsService();
      await blogsService.deleteComment(comment: comment);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Comment deleted successfully')));
      onDelete.call();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete comment: ${error.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (AuthService().getCurrentUser()?.id != comment.author!.id)
              SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: comment.author?.signedUrl != null
                              ? NetworkImage(comment.author!.signedUrl!)
                              : AssetImage('assets/images/user.png'),
                          radius: 15,
                        ),
                        SizedBox(width: 10),
                        Text(
                          comment.author?.name ?? comment.author!.email,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                if (AuthService().getCurrentUser()?.id == comment.author!.id)
                  MoreOptions(
                    onUpdate: onUpdate,
                    onDelete: () async {
                      final confirm = await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Delete Comment'),
                            content: Text(
                              'Are you sure you want to delete this comment?',
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                child: Text("Cancel"),
                              ),
                              FilledButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                child: Text("Delete"),
                              ),
                            ],
                          );
                        },
                      );
                      if (confirm != true) return;
                      deleteComment(context);
                    },
                  ),
              ],
            ),
            (() {
              final images = comment.images;

              if (comment.images != null && comment.images!.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: CarouselSlider(
                      items: images!.map((image) {
                        return Builder(
                          builder: (context) {
                            return Container(
                              width: screenWidth < 600 ? 400 : 600,
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              child: Image.network(
                                image.signedUrl!,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        );
                      }).toList(),
                      options: CarouselOptions(
                        height: screenWidth < 600 ? 200 : 300,
                        enableInfiniteScroll: false,
                      ),
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            })(),
            comment.textContent != null &&
                    comment.textContent!.trim().isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(comment.textContent!),
                  )
                : SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}

import 'package:blog_app_v1/components/more_options.dart';
import 'package:blog_app_v1/features/auth/services/auth_service.dart';
import 'package:blog_app_v1/features/blogs/models/comment_model.dart';
import 'package:flutter/material.dart';

class CommentCard extends StatelessWidget {
  const CommentCard({super.key, required this.comment});

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (AuthService().getCurrentUser()?.id != comment.authorId) SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text(
                    comment.authorEmail!,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (AuthService().getCurrentUser()?.id == comment.authorId) MoreOptions(onUpdate: () {}, onDelete: () {}),
              ],
            ),
            if (comment.signedUrl != null) ...[
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(10),
                  child: Image.network(comment.signedUrl!),
                ),
              ),
            ],
            if (comment.textContent != null) ...[
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(comment.textContent!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

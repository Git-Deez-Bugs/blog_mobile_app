import 'package:blog_app_v1/components/more_options.dart';
import 'package:flutter/material.dart';

class BlogCard extends StatelessWidget {
  const BlogCard({
    super.key,
    required this.id,
    this.author,
    required this.createdAt,
    required this.title,
    this.textContent,
    this.commentsCount,
    this.imagePath,
    this.imageContent,
  });

  final String id;
  final String? author;
  final String createdAt;
  final String title;
  final String? textContent;
  final int? commentsCount;
  final String? imagePath;
  final String? imageContent;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {},
        child: Column(
          children: [
            //Email and Date
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(author!, style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(createdAt),
                  MoreOptions(id: id, imagePath: imagePath,)
                ],
              ),
            ),
            //Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  title,
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (textContent != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(textContent!, textAlign: TextAlign.justify),
                ),
              ),
            if (imageContent != null) SizedBox(height: 10),
            if (imageContent != null) Image.network(imageContent!),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Text(commentsCount.toString()),
                  SizedBox(width: 10),
                  Icon(Icons.comment, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

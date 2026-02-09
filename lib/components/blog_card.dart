import 'package:flutter/material.dart';

class BlogCard extends StatelessWidget {
  const BlogCard({
    super.key,
    this.author,
    required this.createdAt,
    required this.title,
    this.textContent,
    this.commentsCount,
    this.imageContent,
  });

  final String? author;
  final String createdAt;
  final String title;
  final String? textContent;
  final int? commentsCount;
  final String? imageContent;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {},
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text(author!, style: TextStyle(fontWeight: FontWeight.bold)), Text(createdAt)],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                child: Text(title, textAlign: TextAlign.justify, style: TextStyle(fontWeight: FontWeight.bold),),
              ),
            ),
            SizedBox(height: 10),
            if (textContent != null) Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(textContent!, textAlign: TextAlign.justify),
            ),
            SizedBox(height: 10),
            if (imageContent != null) Image.network(imageContent!),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Text(commentsCount.toString()),
                  SizedBox(width: 10),
                  Icon(Icons.comment, size: 20,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:blog_app_v1/features/blogs/models/image_model.dart';
import 'package:flutter/material.dart';

class ImageLayout extends StatelessWidget {
  const ImageLayout({super.key, required this.images, required this.listView});

  final List<BlogImage> images;
  final bool listView;

  @override
  Widget build(BuildContext context) {
    if (listView) {
      return Column(
        children: images.map((image) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: SizedBox(width: double.infinity, child: Image.network(image.signedUrl!, fit: BoxFit.cover)),
          );
        }).toList(),
      );
    }

    final int count = images.length;

    if (count == 1) {
      return SizedBox(
        width: double.infinity,
        child: Image.network(images.first.signedUrl!, fit: BoxFit.cover),
      );
    }

    if (count == 2 || count == 3) {
      return SizedBox(
        height: 600,
        width: double.infinity,
        child: Row(
          spacing: 5,
          children: images.map((image) {
            return Expanded(
              child: SizedBox(
                height: double.infinity,
                child: Image.network(image.signedUrl!, fit: BoxFit.cover),
              ),
            );
          }).toList(),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
        ),
        itemCount: count > 4 ? 4 : count,
        itemBuilder: (context, index) {
          final moreCount = count - 4;

          if (index < 3) {
            return Image.network(images[index].signedUrl!, fit: BoxFit.cover);
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              Image.network(images[index].signedUrl!, fit: BoxFit.cover),
              if (moreCount > 0) ...[
                Container(
                  color: Colors.black54,
                  alignment: Alignment.center,
                  child: Text(
                    '${moreCount.toString()}+',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

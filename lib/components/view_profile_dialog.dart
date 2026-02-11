import 'package:blog_app_v1/features/profile/model/user_model.dart';
import 'package:flutter/material.dart';

class ViewProfileDialog extends StatelessWidget {
  const ViewProfileDialog({super.key, required this.currentUser});

  final User currentUser;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: EdgeInsets.zero,
                child: Stack(
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 100,
                        backgroundImage: currentUser.signedUrl != null
                            ? NetworkImage(currentUser.signedUrl!)
                            : AssetImage('assets/images/user.png')
                                  as ImageProvider,
                      ),
                    ),

                    Positioned(
                      top: 40,
                      left: 5,
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.white, size: 30),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: Text('View Profile'),
      ),
    );
  }
}

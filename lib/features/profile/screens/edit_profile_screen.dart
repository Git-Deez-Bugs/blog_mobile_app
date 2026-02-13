import 'dart:typed_data';
import 'package:blog_app_v1/features/profile/model/user_model.dart';
import 'package:blog_app_v1/features/profile/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.currentUser});

  final User currentUser;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  Uint8List? _imageFile;
  String? _fileName;
  String? _networkImageUrl;
  String? _oldImagePath;

  @override
  void initState() {
    super.initState();
    _networkImageUrl = widget.currentUser.signedUrl;
    _oldImagePath = widget.currentUser.profilePath;
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
        _networkImageUrl = null;
      });
    }
  }

  Future<void> updateProfile() async {
    try {
      ProfileService profileService = ProfileService();
      User user = User(
        id: widget.currentUser.id,
        email: widget.currentUser.email,
        createdAt: widget.currentUser.createdAt,
        name: widget.currentUser.name
      );
      if ((_oldImagePath != null && _networkImageUrl == null) && _imageFile == null) {
        user.profilePath = null;
      }
      await profileService.updateProfile(
        user: user.toMap(),
        file: _imageFile,
        fileName: _fileName,
        oldImagePath: _oldImagePath,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Profile'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 100,
              backgroundImage: _imageFile != null
                  ? MemoryImage(_imageFile!)
                  : _networkImageUrl != null
                  ? NetworkImage(_networkImageUrl!)
                  : AssetImage('assets/images/user.png'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(onPressed: pickImage, icon: Icon(Icons.add_a_photo)),
                if (_networkImageUrl != null || _imageFile != null)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _imageFile = null;
                        _networkImageUrl = null;
                        _fileName = null;
                      });
                    },
                    icon: Icon(Icons.delete),
                  ),
              ],
            ),
            if (_imageFile != null || (_oldImagePath != null && _networkImageUrl == null))
              FilledButton(
                onPressed: updateProfile,
                child: Text('Upload Image'),
              ),
          ],
        ),
      ),
    );
  }
}

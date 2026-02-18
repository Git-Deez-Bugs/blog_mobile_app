import 'package:blog_app_v1/features/profile/model/user_model.dart';
import 'package:blog_app_v1/features/profile/services/profile_service.dart';
import 'package:flutter/material.dart';

class EditNameScreen extends StatefulWidget {
  const EditNameScreen({super.key, required this.currentUser});

  final User currentUser;

  @override
  State<EditNameScreen> createState() => _EditNameScreenState();
}

class _EditNameScreenState extends State<EditNameScreen> {
  late final TextEditingController _nameController;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentUser.name);
    _nameController.addListener(() {
      setState(() {
        _showButton = _nameController.text.trim().isNotEmpty;
      });
    },);
  }

  Future<void> updateName() async {
    try {
      ProfileService profileService = ProfileService();
      User user = User(
        id: widget.currentUser.id,
        email: widget.currentUser.email,
        createdAt: widget.currentUser.createdAt,
        name: _nameController.text,
        profilePath: widget.currentUser.profilePath
      );
      await profileService.updateName(user: user.toMap());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name updated successfully')),
      );
      Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update name')),
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    final double buttonHeight = screenWidth < 600 ? 40 : 56;
    final double sbSize = screenWidth < 600 ? 10 : 20;

    return Scaffold(
      appBar: AppBar(title: Text('Update Name'), centerTitle: true),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Name",
                      hintText: "What's your name?",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  if (_showButton) ...[
                    SizedBox(height: sbSize,),
                    FilledButton(onPressed: updateName, style: FilledButton.styleFrom(minimumSize: Size(double.infinity, buttonHeight)), child: Text('Update Name'),),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

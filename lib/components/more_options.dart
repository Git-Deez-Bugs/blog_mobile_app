import 'package:flutter/material.dart';

class MoreOptions extends StatelessWidget {
  const MoreOptions({
    super.key,
    required this.onUpdate,
    required this.onDelete,
  });

  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_Action>(
      icon: Icon(Icons.more_horiz),
      onSelected: (value) {
        switch (value) {
          case _Action.update:
            onUpdate();
            break;
          case _Action.delete:
            onDelete();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _Action.update,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text('Update'),
            ],
          ),
        ),
        PopupMenuItem(
          value: _Action.delete,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }
}

enum _Action { update, delete }

import 'package:flutter/material.dart';

class AddPostScreen extends StatefulWidget {
  final Function(String, String) onPostAdded;

  const AddPostScreen({super.key, required this.onPostAdded});

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  void _cancelPost() {
    Navigator.pop(context);
  }

  void _postContent() {
    final name = _nameController.text;
    final description = _descriptionController.text;

    widget.onPostAdded(name, description); // Call the callback to add the post
    Navigator.pop(context); // Close the screen after posting
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: TextButton(
          onPressed: _cancelPost,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero, // Remove default padding
          ),
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _postContent,
            child: Text(
              'Post',
              style: TextStyle(
                color: Colors.red[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, color: Colors.grey[600]),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Name',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
            Divider(height: 1),
            TextField(
              controller: _descriptionController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Describe your post...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

// This screen allows users to add a post with their name and a description
class AddPostScreen extends StatefulWidget {
  final Function(String, String) onPostAdded; // Callback function to handle post addition

  const AddPostScreen({super.key, required this.onPostAdded});

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  // Controllers to manage the input fields for name and description
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Function to handle canceling the post; it simply closes the screen
  void _cancelPost() {
    Navigator.pop(context);
  }

  // Function to handle posting content
  void _postContent() {
    final name = _nameController.text; // Retrieve text from name input field
    final description = _descriptionController.text; // Retrieve text from description input field

    widget.onPostAdded(name, description); // Call the callback to add
    widget.onPostAdded(name, description); // Call the callback to add the post with name and description to the feeds
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
          onPressed: _cancelPost, // Call _cancelPost function when "Cancel" is pressed
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero, // Remove default padding for alignment
          ),
          child: Text(
            'Cancel', // Label for cancel button
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _postContent, // Call _postContent function when "Post" is pressed
            child: Text( 
              'Post', // Label for post button
              style: TextStyle(
                color: Color(0xFF8B0000), // Style to indicate post action
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
                  backgroundColor: Colors.grey[300], // Placeholder profile icon
                  child: Icon(Icons.person, color: Colors.grey[600]),
                ),
                SizedBox(width: 10), // Space between avatar and name input
                Expanded(
                  child: TextField(
                    controller: _nameController, // Link TextField to _nameController
                    decoration: InputDecoration(
                      hintText: 'Name', // Placeholder text for name input
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
            Divider(height: 1), // Divider between name input and description
            TextField(
              controller: _descriptionController, // Link TextField to _descriptionController
              maxLines: null, // Allow multiline for description input
              decoration: InputDecoration(
                hintText: 'Describe your post...', // Placeholder for description
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
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class AddPostScreen extends StatefulWidget {
  final Function(String, String, String?) onPostAdded;

  const AddPostScreen({Key? key, required this.onPostAdded}) : super(key: key);

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _descriptionController = TextEditingController();
  String? _imageUrl;
  String? _username;

  @override
  void initState() {
    super.initState();
    _fetchUsername(); // Fetch username on screen load
  }

  Future<void> _fetchUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _username = userDoc.data()?['username'];
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.camera);

    if (file != null) {
      await _uploadImage(file);
    } else {
      print("No image selected");
    }
  }

  Future<void> _uploadImage(XFile pickedFile) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('posts/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = storageRef.putFile(File(pickedFile.path));
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _imageUrl = downloadUrl;
      });
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  void _postContent() {
    final description = _descriptionController.text;
    final photoUrl = _imageUrl;

    if (_username == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Username not found')),
      );
      return;
    }

    widget.onPostAdded(_username!, description, photoUrl);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
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
            onPressed: _postContent,
            child: const Text(
              'Post',
              style: TextStyle(
                color: Color(0xFF8B0000),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _descriptionController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Describe your post...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt, color: Colors.blue),
                label: const Text(
                  'Upload Photo',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              const SizedBox(height: 8),
              if (_imageUrl != null)
                Image.network(
                  _imageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200, // Added fixed height for consistency
                ),
            ],
          ),
        ),
      ),
    );
  }
}

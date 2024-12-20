import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'studentfeedpage.dart';

class AddPostScreen extends StatefulWidget {
  final Function(String username, String description, String? photoUrl, String category) onPostAdded;

  const AddPostScreen({Key? key, required this.onPostAdded}) : super(key: key);

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _descriptionController = TextEditingController();
  String? _imageUrl;
  String? _username;
  bool _isLoading = false;
  String? _selectedCategory;

  final List<String> _categories = [
    'Animal Encounter',
    'Theft',
    'Fire Emergency',
    'Road Closure',
    'Power Outage',
    'Lost Item',
    'Medical Emergency',
    'Transportation Incident',
    'Infrastructure Failure',
    'Property Damage'
  ];

  @override
  void initState() {
    super.initState();
    _fetchUsername(); 
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

    // Show a dialog with options
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Capture Photo'),
              onTap: () async {
                Navigator.pop(context); // Close the bottom sheet
                final XFile? file = await picker.pickImage(source: ImageSource.camera);
                if (file != null) {
                  await _uploadImage(file);
                } else {
                  print("No image selected from camera");
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context); // Close the bottom sheet
                final XFile? file = await picker.pickImage(source: ImageSource.gallery);
                if (file != null) {
                  await _uploadImage(file);
                } else {
                  print("No image selected from gallery");
                }
              },
            ),
          ],
        );
      },
    );
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
    final description = _descriptionController.text.trim();
    final photoUrl = _imageUrl;

    // Check if the description or category is empty and show an error if true
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description')),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    if (_username == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Username not found')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Call the provided onPostAdded function with the description, category, and photoUrl
    widget.onPostAdded(_username!, description, photoUrl, _selectedCategory!).then((_) {
      setState(() {
        _isLoading = false;
      });

      // Close the screen and go back to the FeedPage
      Navigator.pop(context);
    }).catchError((e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error posting. Please try again')),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FeedPage()),
              );
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
            ),
            child: Text(
              'Cancel', // Label for cancel button
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
        actions: [
          TextButton(
            onPressed: _postContent, // Trigger the post action
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
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: const Text('Select Category'),
                items: _categories
                    .map((category) => DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _pickImage, // Trigger the image picker
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
              if (_isLoading) // Show loading indicator while posting
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
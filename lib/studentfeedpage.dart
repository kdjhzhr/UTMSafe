import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'addpost.dart';
import 'sospage.dart';

// Main FeedPage where students can view posts and add new ones
class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  int _selectedIndex = 0; // Track the selected item in the bottom navigation bar
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance for database operations

  // Stream to listen for updates to posts in Firestore, sorted by timestamp in descending order
  Stream<List<Post>> _fetchPosts() {
    return _firestore
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      // Map Firestore documents to a list of Post objects
      return snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
    });
  }

  // Method to add a new post to Firestore with name, description, and timestamp
  Future<void> _addPost(String name, String description) async {
    try {
      await _firestore.collection('posts').add({
        'name': name,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(), // Auto-generated server timestamp
        'userType': 'student', // Label posts from students
      });
      print("Post added successfully!"); // Debug log for successful post addition
    } catch (e) {
      print("Error adding post: $e"); // Debug log for errors
    }
  }

  // Method to show a dialog for adding a new post
  void _showAddPostDialog() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPostScreen(
          onPostAdded: _addPost, // Pass _addPost function to handle new posts
        ),
      ),
    );
  }

  // Handle taps on bottom navigation items
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update selected index
    });
    if (_selectedIndex == 1) {
      // Navigate to SosPage when "Emergency" tab is selected
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SosPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'UTMSafe', 
          style: TextStyle(
            color: const Color(0xFF8B0000),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFFF5E9D4), // Background color for app bar
        automaticallyImplyLeading: false, // Remove default back button
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: const Color(0xFF8B0000)),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst); // Logout action
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Post>>(
        stream: _fetchPosts(), // Stream of posts from Firestore
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Show loading indicator
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No posts available.")); // Show message if no posts
          }

          final posts = snapshot.data!;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: EdgeInsets.all(8),
                  title: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[300], // Placeholder avatar for each post
                        child: Icon(Icons.person, color: Colors.grey[600]),
                      ),
                      SizedBox(width: 8),
                      Text(
                        post.name, // Display the post author's name
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 8),
                      // Display formatted timestamp next to name
                      Text(
                        post.timestamp != null
                            ? _formatTimestamp(post.timestamp!)
                            : '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Text(post.description), // Display post description
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton(
          onPressed: _showAddPostDialog, // Show dialog to add new post
          child: Icon(Icons.add, color: Colors.white),
          backgroundColor: const Color(0xFF8B0000),
          tooltip: 'Add Post', // Tooltip for button
          elevation: 4.0,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFF5E9D4), // Color for navigation bar
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF8B0000),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Feed', // Label for Feed tab
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'Emergency', // Label for Emergency tab
          ),
        ],
      ),
    );
  }

  // Helper function to format timestamp to a readable format
  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
  }
}

// Class to represent each post item
class Post {
  final String name; // Name of post author
  final String description; // Description content of post
  final Timestamp? timestamp; // Timestamp of post creation

  Post({required this.name, required this.description, this.timestamp});

  // Factory constructor to create a Post instance from Firestore data
  factory Post.fromFirestore(DocumentSnapshot doc) {
    return Post(
      name: doc['name'],
      description: doc['description'],
      timestamp: doc['timestamp'], // Get timestamp from Firestore document
    );
  }
}
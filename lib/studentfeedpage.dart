import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'addpost.dart';
import 'emergency.dart';

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  int _selectedIndex = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Track if a post is currently being added to prevent duplicates
  bool _isPosting = false;

  Stream<List<Post>> _fetchPosts() {
    return _firestore
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
    });
  }

  // Modify the method to add a new post with a check for duplicate calls
  Future<void> _addPost(String name, String description) async {
    if (_isPosting) return; // Prevent multiple posts from being added at once
    setState(() {
      _isPosting = true;
    });
    
    try {
      await _firestore.collection('posts').add({
        'name': name,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
        'userType': 'student',
      });
      print("Post added successfully!");
    } catch (e) {
      print("Error adding post: $e");
    } finally {
      setState(() {
        _isPosting = false; // Reset posting state after completion
      });
    }
  }

  // Show dialog to add a new post
  void _showAddPostDialog() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPostScreen(
          onPostAdded: _addPost,
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (_selectedIndex == 1) {
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
        backgroundColor: const Color(0xFFF5E9D4),
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: const Color(0xFF8B0000)),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Post>>(
        stream: _fetchPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No posts available."));
          }

          final posts = snapshot.data!;
          debugPrint("Fetched ${posts.length} posts from Firestore."); // Debug print to track the number of posts
          
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
                        backgroundColor: Colors.grey[300],
                        child: Icon(Icons.person, color: Colors.grey[600]),
                      ),
                      SizedBox(width: 8),
                      Text(
                        post.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 8),
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
                      Text(post.description),
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
          onPressed: _showAddPostDialog,
          child: Icon(Icons.add, color: Colors.white),
          backgroundColor: const Color(0xFF8B0000),
          tooltip: 'Add Post',
          elevation: 4.0,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFF5E9D4),
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF8B0000),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'Emergency',
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
  }
}

class Post {
  final String name;
  final String description;
  final Timestamp? timestamp;

  Post({required this.name, required this.description, this.timestamp});

  factory Post.fromFirestore(DocumentSnapshot doc) {
    return Post(
      name: doc['name'],
      description: doc['description'],
      timestamp: doc['timestamp'],
    );
  }
}

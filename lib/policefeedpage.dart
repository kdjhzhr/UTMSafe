import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'report.dart';
import 'package:intl/intl.dart';

class PoliceInterface extends StatefulWidget {
  const PoliceInterface({super.key});

  @override
  _PoliceInterfaceState createState() => _PoliceInterfaceState();
}

class _PoliceInterfaceState extends State<PoliceInterface> {
  int _selectedIndex = 0;

  // List of pages for navigation
  final List<Widget> _pages = [
    const FeedScreen(), // Feed screen with Firestore integration
    const Report(), // Report screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5E9D4),
        centerTitle: true,
        title: const Text(
          'UTMSafe',
          style: TextStyle(
            color: Color(0xFF8B0000),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: _selectedIndex == 0
            ? [
                IconButton(
                  icon: const Icon(Icons.logout),
                  color: const Color(0xFF8B0000),
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),
              ]
            : [],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFF5E9D4),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Report'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF8B0000),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

// FeedScreen displays posts from Firestore
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  // Stream to listen for posts from Firestore
  Stream<List<Post>> _fetchPosts() {
    return FirebaseFirestore.instance
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
    });
  }

  // Format timestamp to a human-readable format
  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Post>>(
      stream: _fetchPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              "No posts yet",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }

        final posts = snapshot.data!;
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                contentPadding: const EdgeInsets.all(8),
                title: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(Icons.person, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      post.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Display timestamp next to the name
                    Text(
                      post.timestamp != null
                          ? _formatTimestamp(post.timestamp!)
                          : '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                subtitle: Text(post.description),
              ),
            );
          },
        );
      },
    );
  }
}

// Define Post class to model Firestore data
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

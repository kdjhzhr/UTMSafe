import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'report.dart';

class PoliceInterface extends StatefulWidget {
  const PoliceInterface({super.key});

  @override
  _PoliceInterfaceState createState() => _PoliceInterfaceState();
}

class _PoliceInterfaceState extends State<PoliceInterface> {
  int _selectedIndex = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'UTMSafe',
          style: TextStyle(
            color: Color(0xFF8B0000),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFFF5E9D4),
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.logout, color: Color(0xFF8B0000)),
              onPressed: () async {
                try {
                  await _auth.signOut(); // Log out the user
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false); // Navigate to login
                } catch (e) {
                  print("Error during logout: $e");
                }
              },
            ),
        ],
      ),
      body: _selectedIndex == 0 ? const FeedScreen() : const Report(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFF5E9D4),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Report'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF8B0000),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

// FeedScreen displays posts from Firestore
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  Stream<List<Post>> _fetchPosts() async* {
    final snapshots = FirebaseFirestore.instance
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots();

    await for (var snapshot in snapshots) {
      List<Post> posts = [];
      for (var doc in snapshot.docs) {
        var post = Post.fromFirestore(doc);
        final commentsSnapshot = await doc.reference
            .collection('comments')
            .orderBy('timestamp')
            .get();
        post.comments = commentsSnapshot.docs.map((commentDoc) {
          return Comment.fromFirestore(commentDoc);
        }).toList();
        posts.add(post);
      }
      yield posts;
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    final formatter = DateFormat('dd/MM/yyyy  HH:mm');
    return formatter.format(dateTime);
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
          return const Center(child: Text("No posts available."));
        }

        final posts = snapshot.data!;
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                    const SizedBox(height: 8),
                    Text(post.description),
                    if (post.photoUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Image.network(post.photoUrl!),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.favorite_border),
                          color: Colors.red,
                          tooltip: 'Like',
                        ),
                        Text(post.likes.toString()),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.comment),
                          color: Colors.grey,
                          tooltip: 'Comments',
                        ),
                        Text(post.comments.isEmpty
                            ? '0'
                            : post.comments.length.toString()),
                      ],
                    ),
                    if (post.comments.isNotEmpty) ...[
                      ExpansionTile(
                        title: const Text(
                          "View Comments",
                          style: TextStyle(color: Colors.grey),
                        ),
                        children: post.comments.map((comment) {
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey[300],
                              child: const Icon(Icons.person,
                                  color: Colors.grey),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  comment.userName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatTimestamp(comment.timestamp),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            subtitle: Text(comment.comment),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class Post {
  String id;
  String name;
  String description;
  String? photoUrl;
  int likes;
  List<Comment> comments;
  Timestamp timestamp;

  Post({
    required this.id,
    required this.name,
    required this.description,
    required this.likes,
    required this.comments,
    required this.timestamp,
    this.photoUrl,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      photoUrl: data['photoUrl'],
      likes: data['likes'] ?? 0,
      comments: [],
      timestamp: data['timestamp'],
    );
  }
}

class Comment {
  String comment;
  String userName;
  Timestamp timestamp;

  Comment({
    required this.comment,
    required this.userName,
    required this.timestamp,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      comment: data['comment'] ?? '',
      userName: data['userName'] ?? '',
      timestamp: data['timestamp'],
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'report.dart';

class PoliceInterface extends StatefulWidget {
  const PoliceInterface({Key? key}) : super(key: key);

  @override
  _PoliceInterfaceState createState() => _PoliceInterfaceState();
}

class _PoliceInterfaceState extends State<PoliceInterface> {
  int _selectedIndex = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _username;

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        final userDoc = await _firestore.collection('users').doc(uid).get();
        setState(() {
          _username = userDoc.data()?['username'] ?? 'Unknown';
        });
      }
    } catch (e) {
      print("Error fetching username: $e");
    }
  }

  // Function to fetch posts
Stream<List<Post>> _fetchPosts() {
  return _firestore
      .collection('posts')
      .orderBy('timestamp', descending: true)  // Order by timestamp in descending order
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
  });
}

  Future<void> _likePost(String postId, int currentLikes) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'likes': currentLikes + 1,
      });
    } catch (e) {
      print("Error liking post: $e");
    }
  }

  Future<void> _addComment(String postId, String comment) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add({
        'comment': comment,
        'userName': _username ?? 'Unknown',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding comment: $e");
    }
  }

  void _showAddCommentDialog(String postId) {
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Comment"),
          content: TextField(
            controller: commentController,
            decoration: const InputDecoration(hintText: "Write a comment..."),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final comment = commentController.text.trim();
                if (comment.isNotEmpty) {
                  _addComment(postId, comment);
                }
                Navigator.pop(context);
              },
              child: const Text("Post"),
            ),
          ],
        );
      },
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  String _getCategoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'fire emergency':
        return '🔥';
      case 'snake encounter':
        return '🐍';
      case 'monkey attack':
        return '🐒';
      case 'electric shock':
        return '⚡';
      case 'minor accident':
        return '🚗';
      default:
        return '⚠️';
    }
  }

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
                  await _auth.signOut();
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/', (route) => false);
                } catch (e) {
                  print("Error during logout: $e");
                }
              },
            ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Feed Page
          StreamBuilder<List<Post>>(
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
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              Text(
                                _formatTimestamp(post.timestamp),
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (post.category != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Text(
                                    _getCategoryEmoji(post.category!) + ' ',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  Text(
                                    '${post.category}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, color: Color(0xFF8B0000)),
                                  ),
                                ],
                              ),
                            ),
                          Text(post.description),
                          if (post.photoUrl != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Image.network(post.photoUrl!),
                            ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.favorite_border, color: Colors.red),
                                onPressed: () => _likePost(post.id, post.likes),
                              ),
                              Text(post.likes.toString()),
                              const SizedBox(width: 16),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.comment, color: Colors.grey),
                                    onPressed: () => _showAddCommentDialog(post.id),
                                  ),
                                  StreamBuilder<QuerySnapshot>(
                                    stream: _firestore
                                        .collection('posts')
                                        .doc(post.id)
                                        .collection('comments')
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      }
                                      final commentsCount = snapshot.data?.docs.length ?? 0;
                                      return Text('$commentsCount');
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // View comments dropdown
            StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('posts')
                    .doc(post.id)
                    .collection('comments')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  final commentsCount = snapshot.data?.docs.length ?? 0;

                  return commentsCount > 0
                      ? ExpansionTile(
                          title: const Text('View Comments'),
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: commentsCount,
                              itemBuilder: (context, index) {
                                final commentData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                                final commentId = snapshot.data!.docs[index].id;
                                final commentText = commentData['comment'] ?? '';
                                final userName = commentData['userName'] ?? 'Unknown';
                                final timestamp = commentData['timestamp'] as Timestamp?;
                                final formattedTime = timestamp != null ? _formatTimestamp(timestamp) : 'Unknown time';

                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                  leading: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey[300],
                                    child: const Icon(Icons.person, color: Colors.grey),
                                  ),
                                  title: Row(
                                    children: [
                                      Text(
                                        userName,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        formattedTime,
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  subtitle: Text(commentText),
                                );
                              },
                            ),
                          ],
                        )
                      : const SizedBox.shrink();
                },
              ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          // Report Page
          const Report(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFF5E9D4),
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF8B0000),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Report'),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

class Post {
  final String id;
  final String name;
  final String description;
  final String? photoUrl;
  final Timestamp timestamp;
  final int likes;
  final String? category;  // Added category field

  Post({
    required this.id,
    required this.name,
    required this.description,
    this.photoUrl,
    required this.timestamp,
    required this.likes,
    this.category,  // Added category field
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      name: data['name'] ?? 'Unknown',
      description: data['description'] ?? '',
      photoUrl: data['photoUrl'],
      timestamp: data['timestamp'] ?? Timestamp.now(),
      likes: data['likes'] ?? 0,
      category: data['category'],  // Extract category
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'addpost.dart';
import 'emergency.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  int _selectedIndex = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _username; 
  bool _isAddingPost = false;

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  // Fetch the username from Firestore using the logged-in user's UID
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

  Stream<List<Post>> _fetchPosts() async* {
    final snapshots = _firestore
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots();

    await for (var snapshot in snapshots) {
      List<Post> posts = [];
      for (var doc in snapshot.docs) {
        var post = Post.fromFirestore(doc);
        // Fetch comments for each post
        final commentsSnapshot = await doc.reference.collection('comments').orderBy('timestamp').get();
        post.comments = commentsSnapshot.docs.map((commentDoc) {
          return Comment.fromFirestore(commentDoc);
        }).toList();
        posts.add(post);
      }
      yield posts;
    }
  }

  Future<void> _addPost(String name, String description, String? photoUrl) async {
    if (_isAddingPost) return;

    setState(() {
      _isAddingPost = true;
    });

    try {
      await _firestore.collection('posts').add({
        'name': name,
        'description': description,
        'photoUrl': photoUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'userType': 'student',
        'likes': 0,
        'comments': [],
      });
      print("Post added successfully!");
    } catch (e) {
      print("Error adding post: $e");
    } finally {
      setState(() {
        _isAddingPost = false;
      });
    }
  }

  Future<void> _addCommentToPost(String postId, String comment) async {
    try {
      final timestamp = FieldValue.serverTimestamp();

      await _firestore.collection('posts').doc(postId).collection('comments').add({
        'comment': comment,
        'userName': _username ?? 'Unknown', // Use the fetched username
        'timestamp': timestamp,
      });

      print("Comment added successfully!");
      setState(() {}); // Refresh UI if necessary
    } catch (e) {
      print("Error adding comment: $e");
    }
  }

  void _addCommentDialog(String postId) {
    final _commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: TextField(
            controller: _commentController,
            decoration: const InputDecoration(hintText: "Enter your comment here"),
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
                final comment = _commentController.text.trim();
                if (comment.isNotEmpty) {
                  _addCommentToPost(postId, comment);
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

  Future<void> _incrementLikeCount(String postId, int newLikeCount) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'likes': newLikeCount, // Update the like count in Firestore
      });
      print("Like count updated successfully!");
    } catch (e) {
      print("Error updating like count: $e");
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
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF8B0000)),
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
                            onPressed: () async {
                              setState(() {
                                post.likes += 1; // Update the like count locally
                              });
                              await _incrementLikeCount(post.id, post.likes); // Update Firestore in the background
                            },
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
                          Text(post.comments.isEmpty ? '0' : post.comments.length.toString()),
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
                                child: const Icon(Icons.person, color: Colors.grey),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    comment.userName,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatTimestamp(comment.timestamp),
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              subtitle: Text(comment.comment),
                            );
                          }).toList(),
                        ),
                      ],
                      TextButton(
                        onPressed: () => _addCommentDialog(post.id),
                        child: const Text(
                          "Add Comment",
                          style: TextStyle(
                            color: Color(0xFF8B0000),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
          onPressed: () {
            // Navigate to AddPostScreen when the button is clicked
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddPostScreen(onPostAdded: _addPost),
              ),
            );
          },
          backgroundColor: const Color(0xFF8B0000),
          tooltip: 'Add Post',
          elevation: 8,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000);
    final formatter = DateFormat('yyyy-MM-dd HH:mm');
    return formatter.format(date);
  }
}

class Post {
  final String id;
  final String name;
  final String description;
  final String? photoUrl;
  final Timestamp timestamp;
  int likes;
  List<Comment> comments;

  Post({
    required this.id,
    required this.name,
    required this.description,
    this.photoUrl,
    required this.timestamp,
    required this.likes,
    required this.comments,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      photoUrl: data['photoUrl'],
      timestamp: data['timestamp'],
      likes: data['likes'] ?? 0,
      comments: [],
    );
  }
}

class Comment {
  final String userName;
  final String comment;
  final Timestamp timestamp;

  Comment({
    required this.userName,
    required this.comment,
    required this.timestamp,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      userName: data['userName'] ?? '',
      comment: data['comment'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
}

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

  String? _username;

  // Fetch the current logged-in user's username from Firestore
  Future<void> _fetchUsername() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Fetch user data from Firestore
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            _username = userDoc['username'] ?? 'Unknown'; // Set the username
          });
        }
      }
    } catch (e) {
      print("Error fetching username: $e");
    }
  }

  // Add comment to the post
  Future<void> _addCommentToPost(String postId, String comment) async {
    try {
      final timestamp = FieldValue.serverTimestamp();

      // Ensure username is fetched before adding the comment
      if (_username == null) {
        await _fetchUsername();
      }

      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add({
        'comment': comment,
        'userName': _username ?? 'Unknown',
        'timestamp': timestamp,
      });

      print("Comment added successfully!");
      setState(() {});
    } catch (e) {
      print("Error adding comment: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUsername(); // Fetch the username when the screen is initialized
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
                      context, '/login', (route) => false);
                } catch (e) {
                  print("Error during logout: $e");
                }
              },
            ),
        ],
      ),
      body: _selectedIndex == 0
          ? FeedScreen(onAddComment: _addCommentToPost)
          : const Report(),
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
  final Function(String postId, String comment) onAddComment; // Accept callback

  const FeedScreen({super.key, required this.onAddComment});

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

  // Function to handle likes
  Future<void> _likePost(String postId, int currentLikes) async {
    try {
      final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
      await postRef.update({
        'likes': currentLikes + 1, // Increment the likes
      });
    } catch (e) {
      print("Error updating likes: $e");
    }
  }

  void _addCommentDialog(BuildContext context, String postId) {
    final _commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: TextField(
            controller: _commentController,
            decoration:
                const InputDecoration(hintText: "Enter your comment here"),
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
                  onAddComment(postId, comment); // Use the callback to add comment
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

                    if (post.photoUrl != null && post.photoUrl!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Image.network(
                          post.photoUrl!,
                          fit: BoxFit.cover,
                          height: 200, // Adjust height as needed
                          width: double.infinity,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            _likePost(post.id, post.likes);
                          },
                          icon: const Icon(Icons.favorite_border),
                          color: Colors.red,
                          tooltip: 'Like',
                        ),
                        Text(post.likes.toString()),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: () {
                            _addCommentDialog(context, post.id); // Open comment dialog
                          },
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

                    // Add Comment Button below View Comments
                    TextButton(
                      onPressed: () => _addCommentDialog(context, post.id),
                      child: const Text(
                        "Add Comment",
                        style: TextStyle(
                          color: Color(0xFF8B0000),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    
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
  final String id;
  final String name;
  final String description;
  final String? photoUrl;
  final Timestamp? timestamp;
  final int likes;
  List<Comment> comments;

  Post({
    required this.id,
    required this.name,
    required this.description,
    this.photoUrl,
    this.timestamp,
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
  final String comment;
  final String userName;
  final Timestamp timestamp;

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
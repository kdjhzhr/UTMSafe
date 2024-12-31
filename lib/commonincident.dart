import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import your existing Post class from the feed page
import 'studentfeedpage.dart';

class FilteredPostsPage extends StatefulWidget {
  final String category;

  const FilteredPostsPage({Key? key, required this.category}) : super(key: key);

  @override
  _FilteredPostsPageState createState() => _FilteredPostsPageState();
}

class _FilteredPostsPageState extends State<FilteredPostsPage> {
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

  Stream<List<Post>> _fetchPostsByCategory() {
    return _firestore
        .collection('posts')
        .where('category', isEqualTo: widget.category)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList());
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

  Future<void> _addComment(String postId, String comment) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        final userDoc = await _firestore.collection('users').doc(uid).get();
        final role = userDoc.data()?['role'] ?? 'student';

        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .add({
          'comment': comment,
          'userName': _username ?? 'Unknown',
          'timestamp': FieldValue.serverTimestamp(),
          'role': role,
        });
      }
    } catch (e) {
      print("Error adding comment: $e");
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return DateFormat('dd/MM/yyyy  HH:mm').format(dateTime);
  }

  String _getCategoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'fire emergency':
        return '🔥';
      case 'animal encounter':
        return '🐾';
      case 'theft':
        return '🕵️‍♂️';
      case 'road closure':
        return '🚫';
      case 'power outage':
        return '🔌';
      case 'lost item':
        return '🔍';
      case 'medical emergency':
        return '🚑';
      case 'transportation incident':
        return '🚌';
      case 'infrastructure failure':
        return '⚙️';
      case 'property damage':
        return '🏚️';
      default:
        return '⚠️';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} Incidents'),
        backgroundColor: const Color(0xFFF5E9D4),
        foregroundColor: const Color(0xFF8B0000),
      ),
      body: StreamBuilder<List<Post>>(
        stream: _fetchPostsByCategory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No ${widget.category} incidents found',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
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
                      // User details row
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey[300],
                            child: const Icon(Icons.school, color: Colors.black),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            post.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatTimestamp(post.timestamp),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Category display
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
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF8B0000),
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Post description
                      Text(post.description),
                      // Post image
                      if (post.photoUrl != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Image.network(post.photoUrl!),
                        ),
                      // Interaction row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Like button
                          IconButton(
                            icon: const Icon(Icons.favorite_border, color: Colors.red),
                            onPressed: () => _likePost(post.id, post.likes),
                          ),
                          Text(post.likes.toString()),
                          const SizedBox(width: 16),
                          // Comment button
                          IconButton(
                            icon: const Icon(Icons.comment, color: Colors.grey),
                            onPressed: () => _showAddCommentDialog(post.id),
                          ),
                          // Comments count
                          StreamBuilder<QuerySnapshot>(
                            stream: _firestore
                                .collection('posts')
                                .doc(post.id)
                                .collection('comments')
                                .snapshots(),
                            builder: (context, snapshot) {
                              final commentsCount = snapshot.data?.docs.length ?? 0;
                              return Text('$commentsCount');
                            },
                          ),
                        ],
                      ),
                      // Comments section
                      StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection('posts')
                            .doc(post.id)
                            .collection('comments')
                            .orderBy('timestamp', descending: true)
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
                                        final commentData = snapshot.data!.docs[index].data()
                                            as Map<String, dynamic>;
                                        final userName = commentData['userName'] ?? 'Unknown';
                                        final commentText = commentData['comment'] ?? '';
                                        final timestamp = commentData['timestamp'] as Timestamp?;
                                        final userRole = commentData['role'] ?? 'student';

                                        return ListTile(
                                          leading: CircleAvatar(
                                            radius: 20,
                                            backgroundColor: Colors.grey[300],
                                            child: Icon(
                                              userRole == 'student' ? Icons.school : Icons.security,
                                              color: Colors.black,
                                            ),
                                          ),
                                          title: Row(
                                            children: [
                                              Text(
                                                userName,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              if (timestamp != null)
                                                Text(
                                                  _formatTimestamp(timestamp),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          subtitle: Text(
                                            commentText,
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 3,
                                          ),
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
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'addpost.dart';
import 'emergency.dart';
import 'banner.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  int _selectedIndex = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _username;
  String currentUserRole = ''; 

  @override
  void initState() {
    super.initState();
    _fetchUsername();
    getUserRole();
  }

  void _showUserDetailsDialog(String username) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Align(
            alignment: Alignment.center,
            child: const Text('User Details',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          content: FutureBuilder<DocumentSnapshot<Object?>?>(
            future: _firestore
                .collection('users')
                .where('username', isEqualTo: username)
                .limit(1) // Fetch only one document
                .get()
                .then((snapshot) => snapshot.docs.isNotEmpty
                    ? snapshot.docs[0]
                    : null), // Get the first document if it exists
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (!snapshot.hasData) {
                return const Text('User not found');
              }
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Username: $username',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  Text('Full Name: ${userData['full_name'] ?? 'N/A'}'),
                  Text('Phone: ${userData['phone'] ?? 'N/A'}'),
                  Text('Email: ${userData['email'] ?? 'N/A'}'),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

Future<void> getUserRole() async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId != null) {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    currentUserRole = userDoc['role']; // Assuming 'role' field stores 'student' or 'police'
  }
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

  Future<void> _addPost(String username, String description, String? photoUrl,
      String category) async {
    try {
      final postRef = _firestore.collection('posts').doc();
      await postRef.set({
        'name': username,
        'description': description,
        'photoUrl': photoUrl,
        'category': category,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
      });

      // Update the category count in the 'category_counts' collection
      final categoryRef =
          _firestore.collection('category_counts').doc(category);
      await _firestore.runTransaction((transaction) async {
        final categoryDoc = await transaction.get(categoryRef);
        if (categoryDoc.exists) {
          // If the category exists, increment its count
          final newCount = (categoryDoc['count'] as int) + 1;
          transaction.update(categoryRef, {'count': newCount});
        } else {
          // If the category does not exist, create it with a count of 1
          transaction.set(categoryRef, {'count': 1});
        }
      });
    } catch (e) {
      print("Error adding post: $e");
    }
  }

  Stream<List<Post>> _fetchPosts() {
    return _firestore
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList());
  }

  Future<void> _showEditPostDialog(Post post) async {
    if (post.name != _username) {
      // If the logged-in user is not the post owner, don't show the edit dialog
      return;
    }

    final descriptionController = TextEditingController(text: post.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Post"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(hintText: "Edit description"),
                maxLines: 3,
              ),
            ],
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
                final newDescription = descriptionController.text.trim();

                if (newDescription.isNotEmpty) {
                  _updatePost(post.id, newDescription);
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updatePost(String postId, String description) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'description': description,
      });
    } catch (e) {
      print("Error updating post: $e");
    }
  }

Future<void> _likePost(String postId, int currentLikes) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  if (userId == null) {
    print("User not logged in");
    return;
  }

  final postRef = _firestore.collection('posts').doc(postId);

  try {
    await _firestore.runTransaction((transaction) async {
      final postSnapshot = await transaction.get(postRef);

      if (!postSnapshot.exists) {
        print("Post does not exist");
        return;
      }

      bool isLiked = postSnapshot.data()?['likedUsers']?.contains(userId) ?? false;
      int updatedLikes = currentLikes;

      if (isLiked) {
        // Unlike the post
        updatedLikes--;
        transaction.update(postRef, {
          'likes': updatedLikes,
          'likedUsers': FieldValue.arrayRemove([userId]),
        });
      } else {
        // Like the post
        updatedLikes++;
        transaction.update(postRef, {
          'likes': updatedLikes,
          'likedUsers': FieldValue.arrayUnion([userId]),
        });
      }
    });
  } catch (e) {
    print("Error toggling like: $e");
  }
}

Future<void> _addComment(String postId, String comment) async {
  try {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final role = userDoc.data()?['role'] ?? 'student';  // Fetch the user's role

      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add({
        'comment': comment,
        'userName': _username ?? 'Unknown',
        'timestamp': FieldValue.serverTimestamp(),
        'role': role,  // Store the user's role in the comment
      });
    }
  } catch (e) {
    print("Error adding comment: $e");
  }
}

  Future<void> _updateComment(
      String postId, String commentId, String newComment) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .update({
        'comment': newComment,
        'timestamp': Timestamp.now(), // Optionally update the timestamp
      });
    } catch (e) {
      print("Error updating comment: $e");
    }
  }

  Future<void> _deletePost(String postId) async {
    try {
      // Delete the post document
      await _firestore.collection('posts').doc(postId).delete();

      // Optionally delete comments associated with the post
      final commentsCollection =
          _firestore.collection('posts').doc(postId).collection('comments');
      final commentsSnapshot = await commentsCollection.get();
      for (var commentDoc in commentsSnapshot.docs) {
        await commentDoc.reference.delete();
      }
    } catch (e) {
      print("Error deleting post: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete post')),
      );
    }
  }

  Future<void> _deleteComment(String postId, String commentId) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();
    } catch (e) {
      print("Error deleting comment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete comment')),
      );
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

  void _showEditCommentDialog(
      String postId, String commentId, String existingComment) {
    final _controller = TextEditingController(text: existingComment);
    final commentRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId);

    commentRef.get().then((commentSnapshot) {
      if (commentSnapshot.exists) {
        final commentData = commentSnapshot.data() as Map<String, dynamic>;
        final commentOwner = commentData['userName'];

        if (commentOwner != _username) {
          return;
        }

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Edit Comment'),
              content: TextField(
                controller: _controller,
                decoration:
                    const InputDecoration(hintText: 'Edit your comment'),
                maxLines: 3,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    _updateComment(postId, commentId, _controller.text);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      }
    });
  }

  void _showDeletePostDialog(String postId, String postOwner) {
    if (_username != postOwner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are not authorized to delete this post')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: const Text('Are you sure you want to delete this post?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deletePost(postId);
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteCommentDialog(
      String postId, String commentId, String commentOwner) {
    if (_username != commentOwner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You are not authorized to delete this comment')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Comment'),
          content: const Text('Are you sure you want to delete this comment?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteComment(postId, commentId);
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
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

  Stream<DocumentSnapshot> _fetchMostCommonCategory() {
    return _firestore
        .collection('category_counts')
        .orderBy('count', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      // If documents exist, return the first document
      return snapshot.docs.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'UTMSafe 🎓',
          style: TextStyle(
              color: Color(0xFF8B0000),
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
        backgroundColor: const Color(0xFFF5E9D4),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF8B0000)),
            onPressed: () async {
              // Show confirmation dialog
              bool? confirmLogout = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false); // User cancels logout
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true); // User confirms logout
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  );
                },
              );

              // Proceed with logout if confirmed
              if (confirmLogout ?? false) {
                try {
                  await _auth.signOut();
                  Navigator.pushNamedAndRemoveUntil(context, '/',
                      (route) => false); // Navigate to home screen after logout
                } catch (e) {
                  print("Error during logout: $e");
                }
              }
            },
          ),
        ],
      ),
      body: CustomScrollView(
          slivers: [
            const SliverAppBar(
              floating: false,
              expandedHeight: 150.0,
              flexibleSpace: FlexibleSpaceBar(
                background: SafetyBanner(),
              ),
            ),
            StreamBuilder<List<Post>>(
              stream: _fetchPosts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text("No posts available.")),
                  );
                }

                final posts = snapshot.data!;
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
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
                                  CircleAvatar(radius: 20, backgroundColor: Colors.grey[300],
                                    child: const Icon(Icons.school, color: Colors.black),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => _showUserDetailsDialog(post.name),
                                    child: Text(post.name,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(_formatTimestamp(post.timestamp),
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
                                Padding(padding: const EdgeInsets.only(top: 8.0), 
                                child: Image.network(post.photoUrl!),
                                ),
                              StreamBuilder<DocumentSnapshot>(
                                stream: _firestore.collection('posts').doc(post.id).snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.favorite_border, color: Colors.grey),
                                            onPressed: null,
                                          ),
                                           Text("0"),
                                        ],
                                      );
                                    }
                                  final data = snapshot.data!.data() as Map<String, dynamic>;
                                  final likesCount = data['likes'] ?? 0;
                                  final userId = FirebaseAuth.instance.currentUser?.uid;
                                  final isLiked = data['likedUsers']?.contains(userId) ?? false;

                                  return Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          isLiked ? Icons.favorite : Icons.favorite_border,
                                          color: isLiked ? Colors.red : Colors.grey,
                                        ),
                                        onPressed: () => _likePost(post.id, likesCount),
                                      ),
                                      Text(likesCount.toString()),
                                      const SizedBox(width: 16),
                                      IconButton(
                                        icon: const Icon(Icons.comment, color: Colors.grey),
                                        onPressed: () => _showAddCommentDialog(post.id),
                                      ),
                                      StreamBuilder<QuerySnapshot>(
                                        stream: _firestore
                                            .collection('posts').doc(post.id).collection('comments').snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return const CircularProgressIndicator();
                                          }
                                          final commentsCount = snapshot.data?.docs.length ?? 0;
                                          return Text('$commentsCount');
                                        },
                                      ),
                                      if (post.name == _username) ...[
                                        const SizedBox(width: 16),
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Color(0xFF1E3A8A)),
                                          onPressed: () => _showEditPostDialog(post),
                                        ),
                                        IconButton(icon: const Icon(Icons.delete, color: Color(0xFF8B0000)),
                                          onPressed: () => _showDeletePostDialog(post.id, post.name),
                                        ),
                                      ],
                                    ],
                                  );
                                },
                              ),
                              StreamBuilder<QuerySnapshot>(
                                stream: _firestore
                                    .collection('posts').doc(post.id).collection('comments').orderBy('timestamp', descending: true).snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  }
                                  final commentsCount = snapshot.data?.docs.length ?? 0;
                                  return commentsCount > 0
                                      ? ExpansionTile(
                                          title: const Text('View Comments'),
                                          children: [
                                            ListView.builder(shrinkWrap: true, itemCount: commentsCount,
                                              itemBuilder: (context, index) {
                                                final commentData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                                                final commentId = snapshot.data!.docs[index].id;
                                                final commentText = commentData['comment'] ?? '';
                                                final userName = commentData['userName'] ?? 'Unknown';
                                                final timestamp = commentData['timestamp'] as Timestamp?;
                                                final formattedTime = timestamp != null ? _formatTimestamp(timestamp) : 'Unknown time';
                                                final userRole = commentData['role'] ?? 'student';

                                                return ListTile(
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                                  leading: CircleAvatar(radius: 20, backgroundColor: Colors.grey[300],
                                                    child: Icon(userRole == 'student'
                                                          ? Icons.school : Icons.security, color: Colors.black,
                                                    ),
                                                  ),
                                                  title: Row(
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          userName,
                                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(formattedTime,
                                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                                      ),
                                                    ],
                                                  ),
                                                  subtitle: Text(commentText, softWrap: true, overflow: TextOverflow.ellipsis, maxLines: 3,
                                                  ),
                                                  trailing: _username == userName
                                                      ? PopupMenuButton<String>(
                                                          icon: const Icon(Icons.more_vert, size: 20),
                                                          onSelected: (value) {
                                                            if (value == 'edit') {
                                                              _showEditCommentDialog(post.id, commentId, commentText);
                                                            } else if (value == 'delete') {
                                                              _showDeleteCommentDialog(post.id, commentId, userName);
                                                            }
                                                          },
                                                          itemBuilder: (context) =>[
                                                            const PopupMenuItem(value: 'edit',
                                                              child: Row(children: [
                                                                  Icon(Icons.edit, size: 20, color: Color(0xFF1E3A8A)),
                                                                  SizedBox(width: 8), Text('Edit'),
                                                                ],
                                                              ),
                                                            ),
                                                            const PopupMenuItem(
                                                              value: 'delete',
                                                              child: Row(children: [
                                                                  Icon(Icons.delete, size: 20, color: Color(0xFF8B0000)),
                                                                  SizedBox(width: 8), Text('Delete'),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      : null,
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
                    childCount: posts.length,
                  ),
                );
              },
            ),
          ],
        ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push( context, MaterialPageRoute(
              builder: (context) => AddPostScreen(
                onPostAdded: (username, description, photoUrl, category) {
                  return _addPost(username, description, photoUrl, category);
                },
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF8B0000),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFF5E9D4),
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF8B0000),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'Emergency'),
        ],
        onTap: (index) {
          if (index == 1) {
            // Navigate to Emergency page
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SosPage()),
            );
          } else if (index == 0) {
            Navigator.pushNamedAndRemoveUntil(
              context, '/feed', (route) => false,
            );
          }
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
  final String? category; // Added category field

  Post({
    required this.id,
    required this.name,
    required this.description,
    this.photoUrl,
    required this.timestamp,
    required this.likes,
    this.category, // Added category field
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
      category: data['category'], // Extract category
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'report.dart';
import 'banner.dart';

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
        .orderBy('timestamp',
            descending: true) // Order by timestamp in descending order
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
    });
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
        final role =
            userDoc.data()?['role'] ?? 'student'; // Fetch the user's role

        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .add({
          'comment': comment,
          'userName': _username ?? 'Unknown',
          'timestamp': FieldValue.serverTimestamp(),
          'role': role, // Store the user's role in the comment
        });
      }
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
                if (comment.isNotEmpty) { _addComment(postId, comment);
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
        title: const Text(
          'UTMSafe 🛡️',
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
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (route) => false); // Navigate to home screen after logout
                  } catch (e) {
                    print("Error during logout: $e");
                  }
                }
              },
            ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Feed Page
          CustomScrollView(
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
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // User details row (username and timestamp)
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
                                          _getCategoryEmoji(post.category!) +
                                              ' ',
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                        Text('${post.category}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8B0000)),
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
                                    ],
                                  );
                                },
                              ),
                                // View comments dropdown
                                StreamBuilder<QuerySnapshot>(
                                  stream: _firestore
                                      .collection('posts')
                                      .doc(post.id)
                                      .collection('comments').orderBy('timestamp', descending: true)
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
                                              ListView.builder(shrinkWrap: true, itemCount: commentsCount,
                                                itemBuilder: (context, index) {
                                                  final commentData = snapshot .data!.docs[index] .data() as Map<String, dynamic>;
                                                  final commentText = commentData['comment'] ?? '';
                                                  final userName = commentData['userName'] ?? 'Unknown';
                                                  final timestamp = commentData['timestamp'] as Timestamp?;
                                                  final formattedTime = timestamp != null ? _formatTimestamp(timestamp) : 'Unknown time';
                                                  final userRole = commentData['role'] ?? 'student'; // Default to 'student' if role is missing

                                                  return ListTile(
                                                    contentPadding:
                                                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                                    leading: CircleAvatar(radius: 20, backgroundColor: Colors.grey[300],
                                                      child: Icon(
                                                        userRole == 'auxiliary_police' ? Icons.security : Icons.school,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    title: Row(
                                                      children: [
                                                        Text(userName,
                                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(formattedTime, style:
                                                              const TextStyle(fontSize: 12, color: Colors.grey),
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
                      childCount: posts.length,
                    ),
                  );
                },
              ),
            ],
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
          setState(() {_selectedIndex = index;
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
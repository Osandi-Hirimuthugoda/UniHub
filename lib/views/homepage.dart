import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = "Loading...";

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  Future<void> fetchUsername() async {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (uid.isEmpty) {
      setState(() => username = "Guest");
      return;
    }
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() => username = userDoc.exists ? userDoc.get('username') : "Unknown User");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(username, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () => Navigator.pushReplacementNamed(context, '/notifications'),
          ),
          IconButton(
            icon: Icon(Icons.chat_sharp, color: Colors.black),
            onPressed: () => Navigator.pushNamed(context, '/chat'),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              print('Error fetching posts: ${snapshot.error}');
              return Center(child: Text('Error loading posts: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No posts available. Add a new post!'));
            }

            final posts = snapshot.data!.docs.map((doc) => Post.fromDocument(doc)).toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 150,
                    width: MediaQuery.of(context).size.width,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.all(8),
                      children: [
                        bannerCard('ICE CREAM SALE', 'Get Now', 'https://cdn.pixabay.com/photo/2013/07/12/19/20/popsicle-154587_640.png'),
                        bannerCard('NSBM BANDS', 'Order now', 'https://cdn.pixabay.com/photo/2020/04/11/14/51/automatic-watch-5030726_640.jpg'),
                        bannerCard('NSBM BANDS', 'Order now', 'https://cdn.pixabay.com/photo/2020/04/11/14/51/automatic-watch-5030726_640.jpg'),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  ...posts.map((post) => PostWidget(post: post)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget bannerCard(String title, String buttonText, String imageUrl) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 200,
        decoration: BoxDecoration(color: Colors.purple, borderRadius: BorderRadius.circular(15)),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Image.network(imageUrl, height: 60, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(buttonText, style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Post {
  final String id;
  final String content;
  final String imagePath;
  final String userId;
  final String category;
  final String? subcategory;
  final DateTime timestamp;
  final int likesCount;
  final List<String> likedBy;
  final int commentsCount;

  Post({
    required this.id,
    required this.content,
    required this.imagePath,
    required this.userId,
    required this.category,
    this.subcategory,
    required this.timestamp,
    required this.likesCount,
    required this.likedBy,
    required this.commentsCount,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    var likesCountValue = data['likesCount'] ?? 0;
    int likesCount = likesCountValue is int ? likesCountValue : int.tryParse(likesCountValue.toString()) ?? 0;

    var commentsCountValue = data['commentsCount'] ?? 0;
    int commentsCount = commentsCountValue is int ? commentsCountValue : int.tryParse(commentsCountValue.toString()) ?? 0;

    String userId = data['userId'] ?? '';
    print('Post ${doc.id} userId: $userId');

    return Post(
      id: doc.id,
      content: data['caption'] ?? '',
      imagePath: data['imagePath'] ?? '',
      userId: userId,
      category: data['category'] ?? '',
      subcategory: data['subcategory'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likesCount: likesCount,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      commentsCount: commentsCount,
    );
  }
}

class Comment {
  final String id;
  final String userId;
  final String content;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.userId,
    required this.content,
    required this.timestamp,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Comment(
      id: doc.id,
      userId: data['userId'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class PostWidget extends StatefulWidget {
  final Post post;
  const PostWidget({super.key, required this.post});

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  late bool isLiked;
  late int likesCount;
  late int commentsCount;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLiked = widget.post.likedBy.contains(FirebaseAuth.instance.currentUser?.uid);
    likesCount = widget.post.likesCount;
    commentsCount = widget.post.commentsCount;
  }

  Future<void> _toggleLike() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be logged in to like a post')),
      );
      return;
    }

    setState(() {
      isLiked = !isLiked;
      likesCount = isLiked ? likesCount + 1 : likesCount - 1;
    });

    try {
      await FirebaseFirestore.instance.collection('posts').doc(widget.post.id).update({
        'likesCount': likesCount,
        'likedBy': isLiked ? FieldValue.arrayUnion([userId]) : FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      setState(() {
        isLiked = !isLiked;
        likesCount = isLiked ? likesCount + 1 : likesCount - 1;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update like: $e')));
    }
  }

  Future<void> _addComment() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be logged in to comment')),
      );
      return;
    }

    final commentContent = _commentController.text.trim();
    if (commentContent.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Comment cannot be empty')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.id)
          .collection('comments')
          .add({
        'userId': userId,
        'content': commentContent,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('posts').doc(widget.post.id).update({
        'commentsCount': FieldValue.increment(1),
      });

      setState(() {
        commentsCount++;
      });

      _commentController.clear();
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add comment: $e')),
      );
    }
  }

  void _showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add a Comment'),
          content: TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: 'Type your comment...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _addComment,
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(widget.post.userId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListTile(
                leading: CircleAvatar(backgroundColor: Colors.grey),
                title: Text('Loading...'),
              );
            }
            if (snapshot.hasError) {
              print('Error fetching user data for userId: ${widget.post.userId}, error: ${snapshot.error}');
              return ListTile(
                leading: CircleAvatar(backgroundImage: NetworkImage('https://via.placeholder.com/50')),
                title: Text('Error'),
              );
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              print('No user data found for userId: ${widget.post.userId}');
              return ListTile(
                leading: CircleAvatar(backgroundImage: NetworkImage('https://via.placeholder.com/50')),
                title: Text('Unknown User'),
              );
            }

            var userData = snapshot.data!.data() as Map<String, dynamic>;
            print('User data for userId ${widget.post.userId}: $userData');
            String username = userData['username'] ?? 'Unknown User';
            String profilePic = userData['profilePic'] ?? 'https://via.placeholder.com/50';

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: profilePic.isNotEmpty && !profilePic.startsWith('http') && File(profilePic).existsSync()
                    ? FileImage(File(profilePic))
                    : NetworkImage(profilePic.isNotEmpty ? profilePic : 'https://via.placeholder.com/50') as ImageProvider,
                onBackgroundImageError: (exception, stackTrace) {
                  print('Error loading profile picture for userId ${widget.post.userId}: $exception');
                },
                backgroundColor: Colors.grey,
              ),
              title: Text(username),
            );
          },
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: widget.post.imagePath.isNotEmpty && File(widget.post.imagePath).existsSync()
                ? Image.file(File(widget.post.imagePath), fit: BoxFit.cover)
                : Container(color: Colors.grey, height: 200, child: Center(child: Text('Image not found'))),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Text(widget.post.content, style: TextStyle(fontSize: 14, color: Colors.black87)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              IconButton(
                icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.black54),
                onPressed: _toggleLike,
              ),
              Text(likesCount.toString(), style: TextStyle(fontSize: 16, color: isLiked ? Colors.red : Colors.black54)),
              IconButton(
                icon: Icon(Icons.comment, color: Colors.black54),
                onPressed: _showCommentDialog,
              ),
              Text(commentsCount.toString(), style: TextStyle(fontSize: 16, color: Colors.black54)),
              IconButton(
                icon: Icon(Icons.chat_bubble_outline, color: Colors.black),
                onPressed: () {
                  if (widget.post.userId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Cannot start chat: Author ID is missing')),
                    );
                    return;
                  }
                  Navigator.pushNamed(context, '/chatofauthor', arguments: widget.post.userId);
                },
              ),
              Expanded(child: SizedBox()),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.save),
              ),
            ],
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .doc(widget.post.id)
              .collection('comments')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              print('Error fetching comments: ${snapshot.error}');
              return Text('Error loading comments');
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text('No comments yet'),
              );
            }

            final comments = snapshot.data!.docs.map((doc) => Comment.fromDocument(doc)).toList();

            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(comment.userId).get(),
                  builder: (context, userSnapshot) {
                    String commenterName = 'Unknown';
                    if (userSnapshot.hasData && userSnapshot.data!.exists) {
                      var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                      commenterName = userData['username'] ?? 'Unknown';
                    }

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$commenterName: ',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Expanded(
                            child: Text(
                              comment.content,
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
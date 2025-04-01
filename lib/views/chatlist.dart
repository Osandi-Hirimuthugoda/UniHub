import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat.dart'; // Adjust path

void main() {
  runApp(MaterialApp(home: WorkingChatListPage()));
}

class WorkingChatListPage extends StatefulWidget {
  @override
  _WorkingChatListPageState createState() => _WorkingChatListPageState();
}

class _WorkingChatListPageState extends State<WorkingChatListPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    print('InitState called at ${DateTime.now()}');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _generateChatId(String user1, String user2) {
    final users = [user1, user2]..sort();
    return '${users[0]}_${users[1]}';
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final dateTime = timestamp.toDate();
    final now = DateTime.now();
    if (dateTime.day == now.day && dateTime.month == now.month && dateTime.year == now.year) {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  Future<void> _startConversation(String otherUserId, String otherUserName) async {
    final currentUserId = _auth.currentUser!.uid;
    final chatId = _generateChatId(currentUserId, otherUserId);
    try {
      final chatRef = _firestore.collection('chat').doc(chatId);
      if (!(await chatRef.get()).exists) {
        await chatRef.set({
          'participants': [currentUserId, otherUserId],
          'lastMessage': 'Conversation started',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(chatId: chatId, otherUserId: otherUserId, otherUserName: otherUserName),
          ),
        ).then((_) => setState(() {}));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start New Conversation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search users by name...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            SizedBox(
              height: 200,
              width: double.maxFinite,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .where('fullname', isGreaterThanOrEqualTo: _searchQuery)
                    .where('fullname', isLessThanOrEqualTo: '$_searchQuery\uf8ff')
                    .limit(10)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final users = snapshot.data!.docs
                      .where((doc) => doc.id != _auth.currentUser!.uid)
                      .toList();
                  if (users.isEmpty) {
                    return const Center(child: Text('No users found'));
                  }
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final userData = users[index].data() as Map<String, dynamic>;
                      final userName = userData['fullname'] as String;
                      final userId = users[index].id;
                      return ListTile(
                        title: Text(userName),
                        onTap: () {
                          Navigator.pop(context);
                          _startConversation(userId, userName);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _auth.currentUser?.uid;
    print('Build called, user: $currentUserId');
    if (currentUserId == null) {
      return Scaffold(body: Center(child: Text('Sign in required')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('chat')
            .where('participants', arrayContains: currentUserId)
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          print('StreamBuilder triggered at ${DateTime.now()}');
          print('Connection state: ${snapshot.connectionState}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            print('Waiting for data');
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            print('No snapshot data');
            return Center(child: Text('No data available'));
          }
          print('Docs found: ${snapshot.data!.docs.length}');
          print('Raw data: ${snapshot.data!.docs.map((doc) => doc.data())}');
          if (snapshot.data!.docs.isEmpty) {
            print('No chats found');
            return Center(child: Text('No conversations'));
          }
          final chats = snapshot.data!.docs;
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chatData = chats[index].data() as Map<String, dynamic>;
              final otherUserId = (chatData['participants'] as List).firstWhere((id) => id != currentUserId);
              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(otherUserId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) return ListTile(title: Text('Loading...'));
                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  final userName = userData['fullname'] ?? 'Unknown';
                  return ListTile(
                    leading: CircleAvatar(child: Text(userName[0].toUpperCase())),
                    title: Text(userName),
                    subtitle: Text(chatData['lastMessage'] ?? ''),
                    trailing: Text(_formatTimestamp(chatData['lastMessageTime'] as Timestamp?)),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          chatId: chats[index].id,
                          otherUserId: otherUserId,
                          otherUserName: userName,
                        ),
                      ),
                    ).then((_) => setState(() {})),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
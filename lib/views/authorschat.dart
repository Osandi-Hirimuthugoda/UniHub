import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatOfAuthorScreen extends StatefulWidget {
  final String authorId; 

  const ChatOfAuthorScreen({super.key, required this.authorId});

  @override
  State<ChatOfAuthorScreen> createState() => _ChatOfAuthorScreenState();
}

class _ChatOfAuthorScreenState extends State<ChatOfAuthorScreen> {
  final TextEditingController _messageController = TextEditingController();
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  String? chatId;
  String authorUsername = "Loading...";

  @override
  void initState() {
    super.initState();
    _getChatId();
    _fetchAuthorUsername();
  }

  Future<void> _fetchAuthorUsername() async {
    try {
      DocumentSnapshot authorDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.authorId)
          .get();
      if (authorDoc.exists) {
        setState(() {
          authorUsername = authorDoc.get('username') ?? 'Unknown User';
        });
      }
    } catch (e) {
      print('Error fetching author username: $e');
    }
  }

  Future<void> _getChatId() async {
    if (currentUserId == null) return;

    final participants = [currentUserId!, widget.authorId]..sort();
    final potentialChatId = participants.join('_');

    final chatDoc = await FirebaseFirestore.instance
        .collection('chat')
        .doc(potentialChatId)
        .get();

    setState(() {
      chatId = chatDoc.exists ? potentialChatId : null;
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || currentUserId == null) return;

    if (chatId == null) {
      final participants = [currentUserId!, widget.authorId]..sort();
      chatId = participants.join('_');

      await FirebaseFirestore.instance.collection('chat').doc(chatId).set({
        'participants': participants,
        'lastMessage': _messageController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await FirebaseFirestore.instance
        .collection('chat')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': currentUserId,
      'text': _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance.collection('chat').doc(chatId).update({
      'lastMessage': _messageController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(authorUsername),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: chatId == null
                ? Center(child: Text('Start a conversation!'))
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chat')
                        .doc(chatId)
                        .collection('messages')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No messages yet'));
                      }

                      final messages = snapshot.data!.docs;

                      return ListView.builder(
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isMe = message['senderId'] == currentUserId;

                          return Align(
                            alignment:
                                isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.blue : Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                message['text'],
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
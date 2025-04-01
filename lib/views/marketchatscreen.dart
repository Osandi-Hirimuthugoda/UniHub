import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String seller;
  const ChatScreen({super.key, required this.seller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with $seller"),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: Text("Chat with $seller", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/eventchatscreen.dart';

class PostCard extends StatelessWidget {
  final String eventName;
  final String eventDate;
  final String eventLocation;
  final String profilePic;
  final String image;
  final String userId;

  const PostCard({super.key, 
    required this.eventName,
    required this.eventDate,
    required this.eventLocation,
    required this.profilePic,
    required this.image,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 20),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Info
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(profilePic),
                  radius: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    eventName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Post Image (Event Image)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: File(image).existsSync()
                ? Image.file(
                    File(image),
                    width: double.infinity,
                    height: 350,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: double.infinity,
                    height: 350,
                    color: Colors.grey,
                    child: Center(child: Text('Image not found')),
                  ),
          ),

          // Event Details
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Date: $eventDate",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  "Location: $eventLocation",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Like and Message Buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.favorite_border, size: 28),
                  onPressed: () {
                    // Add like functionality here
                  },
                ),
                IconButton(
                  icon: Icon(Icons.send, size: 28),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(seller: userId),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
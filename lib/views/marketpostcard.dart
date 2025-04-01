import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/eventchatscreen.dart';

class PostCard extends StatelessWidget {
  final String seller;
  final String profilePic;
  final String image;
  final String description;

  const PostCard({super.key, 
    required this.seller,
    required this.profilePic,
    required this.image,
    required this.description,
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
          // Seller Info
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(profilePic),
                  radius: 20,
                ),
                SizedBox(width: 10),
                Text(
                  seller,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),

          // Post Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              image,
              width: double.infinity,
              height: 400,
              fit: BoxFit.cover,
            ),
          ),
          // Description Text Below Image
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),

          // Like, Message Buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.favorite_border, size: 28),
                  onPressed: () {},
                ),

                IconButton(
                  icon: Icon(Icons.send, size: 28),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(seller: seller),
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

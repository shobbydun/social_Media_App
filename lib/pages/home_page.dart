import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:social_media_app/components/my_drawer.dart';
import 'package:social_media_app/components/my_post_button.dart';
import 'package:social_media_app/components/my_textfield.dart';
import 'package:social_media_app/database/firestore.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  // Firestore access
  final FirestoreDatabase database = FirestoreDatabase();

  // Controller for post
  final TextEditingController newPostController = TextEditingController();

  // Post message
  void postMessage() {
    if (newPostController.text.isNotEmpty) {
      String message = newPostController.text;
      database.addPost(message);
    }
    newPostController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("W A L L"),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.secondary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Handle search functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      drawer: MyDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stories section
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection("users").get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final users = snapshot.data?.docs;

                if (users == null || users.isEmpty) {
                  return const Center(child: Text("No users found"));
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index].data() as Map<String, dynamic>;
                    String username = user['username'] ?? 'Unknown';
                    // Use a default icon for profile picture
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      width: 80,
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.green, // Accent color
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.grey[300],
                              child: Icon(
                                Icons.person_3,
                                size: 30,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            username,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Textfield for posting
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, size: 24, color: Colors.grey[600]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MyTextfield(
                    hintText: "What's on your mind?",
                    obscureText: false,
                    controller: newPostController,
                    //maxLines:null,
                  ),
                ),
                const SizedBox(width: 12),
                MyPostButton(onTap: postMessage),
              ],
            ),
          ),

          // Posts
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: database.getPostsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final posts = snapshot.data?.docs;

                if (posts == null || posts.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(25),
                      child: Text("No posts.. Post Something"),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    String message = post['PostMessage'];
                    String userEmail = post['UserEmail'];
                    Timestamp timestamp = post['TimeStamp'];

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orangeAccent,
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.grey[300],
                                child: Icon(Icons.person, size: 20, color: Colors.grey[600]),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                userEmail,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              Text(
                                _formatTimestamp(timestamp),
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(message),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.favorite),
                                onPressed: () {
                                  // Handle like functionality
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.comment_outlined),
                                onPressed: () {
                                  // Handle comment functionality
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.share_outlined),
                                onPressed: () {
                                  // Handle share functionality
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat.yMMMd().format(date);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:social_share/social_share.dart'; // Import for social share functionality
import 'package:social_media_app/components/my_drawer.dart';
import 'package:social_media_app/components/my_post_button.dart';
import 'package:social_media_app/components/my_textfield.dart';
import 'package:social_media_app/database/firestore.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreDatabase database = FirestoreDatabase();
  final TextEditingController newPostController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  void postMessage() {
    if (newPostController.text.isNotEmpty) {
      String message = newPostController.text;
      database.addPost(message);
    }
    newPostController.clear();
  }

  void sharePost(String message) {
    SocialShare.shareOptions(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text("W A L L"),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.secondary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: SearchDelegateWidget(searchController: searchController),
              );
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
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("users").snapshots(),
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

                final filteredUsers = users.where((user) {
                  final userData = user.data() as Map<String, dynamic>;
                  final username = userData['username'] ?? '';
                  return username.toLowerCase().contains(searchQuery.toLowerCase());
                }).toList();

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index].data() as Map<String, dynamic>;
                    String username = user['username'] ?? 'Unknown';
                    String email = user['email'] ?? 'Unknown Email';

                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/profile_page',
                          arguments: email,
                        );
                      },
                      child: Container(
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
                                  color: Colors.green,
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

                final filteredPosts = posts.where((post) {
                  final postData = post.data() as Map<String, dynamic>;
                  final message = postData['PostMessage'] ?? '';
                  return message.toLowerCase().contains(searchQuery.toLowerCase());
                }).toList();

                return ListView.builder(
                  itemCount: filteredPosts.length,
                  itemBuilder: (context, index) {
                    final post = filteredPosts[index];
                    String message = post['PostMessage'];
                    String userEmail = post['UserEmail'];
                    Timestamp timestamp = post['TimeStamp'];

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
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
                                child: Icon(Icons.person,
                                    size: 20, color: Colors.grey[600]),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                userEmail,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              Text(
                                _formatTimestamp(timestamp),
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12),
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
                                  sharePost(message); // Share post when icon is pressed
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
    return DateFormat('MMM d, yyyy - h:mm a').format(timestamp.toDate());
  }
}

class SearchDelegateWidget extends SearchDelegate {
  final TextEditingController searchController;

  SearchDelegateWidget({required this.searchController});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          searchController.clear();
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // You might want to provide a specific view for the results
    return Center(child: Text('No specific results view implemented.'));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    searchController.text = query;
    return Center(child: Text('No suggestions available.'));
  }
}

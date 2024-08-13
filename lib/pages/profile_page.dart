import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/components/my_back_button.dart';

class ProfilePage extends StatelessWidget {
  final String email;

  ProfilePage({super.key, required this.email});

  // Current logged in user
  User? get currentUser => FirebaseAuth.instance.currentUser;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    if (email.isEmpty) {
      throw Exception('Email cannot be empty');
    }

    return await FirebaseFirestore.instance
        .collection("users")
        .doc(email)
        .get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserPosts() {
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    if (email.isEmpty) {
      throw Exception('Email cannot be empty');
    }
    
    return FirebaseFirestore.instance
        .collection("Posts")
        .where('UserEmail', isEqualTo: email)
        .orderBy('TimeStamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else if (snapshot.hasData && snapshot.data!.exists) {
            Map<String, dynamic>? user = snapshot.data!.data();

            if (user == null) {
              return const Center(
                child: Text("User data is empty"),
              );
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 25.0, top: 50),
                    child: Row(
                      children: [
                        MyBackButton(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Icon(
                      Icons.person,
                      size: 64,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    user['username'] ?? 'No Username',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user['email'] ?? 'No Email',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      user['bio'] ?? 'I am a rocket launcher enthusiast🚀',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatColumn(
                          'Followers',
                          (user['followersCount'] ?? 124570000) as int,
                        ),
                        _buildStatColumn(
                          'Following',
                          (user['followingCount'] ?? 189200) as int,
                        ),
                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: getUserPosts(),
                          builder: (context, postSnapshot) {
                            int postCount = postSnapshot.hasData
                                ? postSnapshot.data!.docs.length
                                : 0;
                            return _buildStatColumn(
                              'Posts',
                              postCount,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to edit profile page
                      },
                      child: const Text('Edit Profile'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Posts:',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 1),
                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: getUserPosts(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              return Center(child: Text("Error: ${snapshot.error}"));
                            }

                            final posts = snapshot.data?.docs;

                            if (posts == null || posts.isEmpty) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(25),
                                  child: Text("No posts yet"),
                                ),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: posts.length,
                              itemBuilder: (context, index) {
                                final post = posts[index];
                                final data = post.data(); // Access document data as a Map
                                String message = data['PostMessage'] ?? '';
                                Timestamp timestamp = data['TimeStamp'];

                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Card(
                                    elevation: 5,
                                    shadowColor: Colors.orangeAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(16.0),
                                      title: Text(
                                        message,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        DateFormat('MMM d, yyyy - h:mm a').format(timestamp.toDate()),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () async {
                                          bool confirm = await _confirmDelete(context);
                                          if (confirm) {
                                            await FirebaseFirestore.instance
                                                .collection("Posts")
                                                .doc(post.id) // Access document ID
                                                .delete();
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: Text("No data❌"),
            );
          }
        },
      ),
    );
  }

  Widget _buildStatColumn(String label, int count) {
    return Column(
      children: [
        Text(
          _formatNumber(count),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M'; // For millions
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k'; // For thousands
    } else {
      return number.toString(); // For numbers less than 1000
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Post"),
        content: const Text("Are you sure you want to delete this post?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Delete"),
          ),
        ],
      ),
    ) ?? false;
  }
}

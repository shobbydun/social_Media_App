import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/components/my_back_button.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  // Current logged in user
  User? get currentUser => FirebaseAuth.instance.currentUser;

  // Future to fetch user details
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    if (currentUser == null) {
      throw Exception('User not logged in');
    }
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser!.email)
        .get();
  }

  // Stream to fetch user posts
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserPosts() {
    if (currentUser == null) {
      throw Exception('User not logged in');
    }
    
    // Print current user email for debugging
    print("Fetching posts for user email: ${currentUser!.email}");

    return FirebaseFirestore.instance
        .collection("posts")
        .where('UserEmail', isEqualTo: currentUser!.email)
        .orderBy('TimeStamp', descending: true) // Ensure this matches the index
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error
          else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          // Data received
          else if (snapshot.hasData && snapshot.data!.exists) {
            // Extract the data
            Map<String, dynamic>? user = snapshot.data!.data();

            // Check if user data is null
            if (user == null) {
              return const Center(
                child: Text("User data is empty"),
              );
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Back button
                  const Padding(
                    padding: EdgeInsets.only(left: 25.0, top: 50),
                    child: Row(
                      children: [
                        MyBackButton(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Profile picture
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

                  // Username
                  Text(
                    user['username'] ?? 'No Username',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Email
                  Text(
                    user['email'] ?? 'No Email',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Bio
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

                  // Followers and Following
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatColumn(
                          'Followers',
                          (user['followersCount'] ?? 243000) as int,
                        ),
                        _buildStatColumn(
                          'Following',
                          (user['followingCount'] ?? 1040) as int,
                        ),
                        _buildStatColumn(
                          'Posts',
                          (user['postsCount'] ?? 0) as int,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Edit Profile Button
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

                  // Recent Activity or Posts
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Posts',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 10),
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

                            // Print the retrieved posts for debugging
                            print("Retrieved posts: ${posts?.map((e) => e.data()).toList()}");

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
                                String message = post['PostMessage'];
                                Timestamp timestamp = post['TimeStamp'];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                                  child: ListTile(
                                    title: Text(message),
                                    subtitle: Text(DateFormat('MMM d, yyyy - h:mm a').format(timestamp.toDate())),
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
}

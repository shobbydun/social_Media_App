import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/components/my_back_button.dart';
import 'package:social_media_app/components/my_list_tile.dart';
import 'package:social_media_app/helper/helper_functions.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser!;
  }

  // Toggle follow status
  Future<void> _toggleFollow(String userEmail, bool isFollowing) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(_currentUser.email);
    final followingDoc = FirebaseFirestore.instance.collection('users').doc(userEmail);

    if (isFollowing) {
      // Unfollow
      await userDoc.update({
        'following': FieldValue.arrayRemove([userEmail])
      });
      await followingDoc.update({
        'followers': FieldValue.arrayRemove([_currentUser.email])
      });
    } else {
      // Follow
      await userDoc.update({
        'following': FieldValue.arrayUnion([userEmail])
      });
      await followingDoc.update({
        'followers': FieldValue.arrayUnion([_currentUser.email])
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("users").snapshots(),
        builder: (context, snapshot) {
          // Handle errors
          if (snapshot.hasError) {
            print("Error: ${snapshot.error}"); // Debugging print statement
            displayMessageToUser("Something went wrong", context);
          }

          // Show loading spinner
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Handle empty data
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No users found"),
            );
          }

          // Get all users
          final users = snapshot.data!.docs;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
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
                
                // Viewing users text
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(
                    'Users',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                
                // List of users
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(0),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      // Get individual user
                      final user = users[index].data() as Map<String, dynamic>;
                      String username = user['username'] ?? 'Unknown';
                      String email = user['email'] ?? 'No email';
                      List<String> following = _currentUser.email != null
                        ? (user['following'] as List<String>? ?? [])
                        : [];
                      bool isFollowing = following.contains(_currentUser.email);

                      return MyListTile(
                        subtitle: username,
                        title: email,
                        timestamp: Timestamp.now(), // Replace this if you have actual timestamp data
                        trailing: IconButton(
                          icon: Icon(
                            isFollowing ? Icons.person_remove : Icons.person_add,
                            color: isFollowing ? Colors.red : Colors.blue,
                          ),
                          onPressed: () => _toggleFollow(email, isFollowing),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

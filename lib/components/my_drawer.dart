import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  // Logout user
  void logout() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              // Drawer header
              DrawerHeader(
                child: Icon(
                  Icons.connect_without_contact,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 80,
                ),
              ),
              const SizedBox(height: 25),

              // Home tile
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.home,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  title: Text("H O M E"),
                  onTap: () {
                    // Pop drawer
                    Navigator.pop(context);
                    // Navigate to home page
                    Navigator.pushNamed(context, '/home_page');
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Profile tile
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  title: const Text("P R O F I L E"),
                  onTap: () async {
                    // Pop drawer
                    Navigator.pop(context);

                    // Fetch current user email
                    final User? currentUser = FirebaseAuth.instance.currentUser;
                    if (currentUser != null && currentUser.email != null) {
                      // Navigate to profile page
                      Navigator.pushNamed(
                        context,
                        '/profile_page',
                        arguments: currentUser.email!,
                      );
                    } else {
                      // Handle case where user is not logged in or email is null
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('No user is currently logged in')),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Users tile
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.group,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  title: const Text("U S E R S"),
                  onTap: () {
                    // Pop drawer
                    Navigator.pop(context);
                    // Navigate to users page
                    Navigator.pushNamed(context, '/users_page');
                  },
                ),
              ),
            ],
          ),

          // Log out
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 20.0),
            child: ListTile(
              leading: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              title: const Text("L O G_O U T"),
              onTap: () {
                // Pop drawer
                Navigator.pop(context);
                // Logout
                logout();
              },
            ),
          ),
        ],
      ),
    );
  }
}

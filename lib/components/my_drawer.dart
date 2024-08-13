import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});


   //void logout user
  void logout(){
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
              //drawer  header
              DrawerHeader(
                child: Icon(
                  Icons.connect_without_contact,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 80,
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              //home tile
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.home,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  title: Text("H O M E"),
                  onTap: () {
                    //pop drawer
                    Navigator.pop(context);
                  },
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              //profile tile
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.home,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  title: const Text("P R O F I L E"),
                  onTap: () {
                    //pop drawer
                    Navigator.pop(context);

                    //navigate to profile page
                    Navigator.pushNamed(context, '/profile_page');
                  },
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              //users tile
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.group,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  title: const Text("U S E R S"),
                  onTap: () {
                    //pop drawer
                    Navigator.pop(context);


                    //navigate to users_page
                    Navigator.pushNamed(context, '/users_page');
                  },
                ),
              ),
            ],
          ),

          //log out
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 20.0),
            child: ListTile(
              leading: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              title: const Text("L O G_O U T"),
              onTap: () {
                //pop drawer
                Navigator.pop(context);

                //logout
                logout();
              },
            ),
          ),
        ],
      ),
    );
  }
}

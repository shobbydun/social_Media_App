import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/components/my_button.dart';
import 'package:social_media_app/components/my_textfield.dart';
import 'package:social_media_app/helper/helper_functions.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({
    super.key,
    this.onTap,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController =
      TextEditingController();

  // Register function placeholder
  void registerUser() async {
    // Show loading circle
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Make sure passwords match
    if (passwordController.text != confirmpasswordController.text) {
      // Pop loading indicator
      Navigator.pop(context);

      // Show error message
      displayMessageToUser("Passwords don't match!!", context);
    } else {
      // Try creating the user
      try {
        // Create user
        UserCredential? userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // Create a user document and add to Firestore
        await createUserDocument(userCredential);

        // Pop loading circle
        if (mounted) Navigator.pop(context); // Check if the widget is still mounted
      } on FirebaseAuthException catch (e) {
        // Pop loading circle
        if (mounted) Navigator.pop(context); // Check if the widget is still mounted

        // Display error message to user
        displayMessageToUser(e.message ?? 'An error occurred', context);
      }
    }
  }

  // Create a user doc and collect them in Firestore
  Future<void> createUserDocument(UserCredential? userCredential) async {
    if (userCredential != null && userCredential.user != null) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user!.email)
          .set({
        'email': userCredential.user!.email,
        'username': usernameController.text,
      });
    }
  }

  @override
  void dispose() {
    // Dispose of controllers when the widget is removed from the tree
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmpasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              // Logo
              Icon(
                Icons.person,
                size: 80,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              const SizedBox(height: 20),
              // App name
              Text(
                "Connect.com",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              // Username text field
              MyTextfield(
                hintText: "Username",
                obscureText: false,
                controller: usernameController,
              ),
              const SizedBox(height: 10),
              // Email text field
              MyTextfield(
                hintText: "Email",
                obscureText: false,
                controller: emailController,
              ),
              const SizedBox(height: 10),
              // Password text field
              MyTextfield(
                hintText: "Enter Password",
                obscureText: true,
                controller: passwordController,
              ),
              const SizedBox(height: 10),
              // Confirm password text field
              MyTextfield(
                hintText: "Confirm Password",
                obscureText: true,
                controller: confirmpasswordController,
              ),
              const SizedBox(height: 25),
              // Sign up button
              MyButton(
                onTap: registerUser,
                text: "Sign up",
              ),
              const SizedBox(height: 25),
              // If already have an account, navigate to login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      " Login here!",
                      style: TextStyle(
                        color: Colors.lightBlueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

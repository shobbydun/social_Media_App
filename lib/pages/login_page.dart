import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/components/my_button.dart';
import 'package:social_media_app/components/my_textfield.dart';
import 'package:social_media_app/helper/helper_functions.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;


  const LoginPage({
    super.key,
    required this.onTap,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  // Login function placeholder
  void login() async {
  // Show loading indicator
  showDialog(
    context: context,
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  // Try logging in
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    );

    // Pop loading indicator
    if (mounted) {
      Navigator.pop(context);
    }
  } on FirebaseAuthException catch (e) {
    // Pop loading indicator
    if (mounted) {
      Navigator.pop(context);
    }
    // Display error messages
    if (mounted) {
      displayMessageToUser(e.code, context);
    }
  }
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
              const SizedBox(height: 130,),
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

              // Forgot password
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Forgot your password?",
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Sign in button
              MyButton(
                onTap: login,
                text: "Sign in",
              ),

              const SizedBox(height: 25),

              // If don't have an account, navigate to register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      " Register here!",
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

import 'package:disaster_management/disaster/screen/login&signup/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disaster_management/app/ui/geolocation.dart'; // Import the geolocation page

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
Future<void> _signIn() async {
  if (_formKey.currentState!.validate()) {
    try {
      // Firebase sign-in logic
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      User? user = userCredential.user;

      if (user != null && !user.emailVerified) {
        Get.snackbar('Email not verified', 'Please verify your email before logging in.');
        await FirebaseAuth.instance.signOut(); // Log the user out if not verified
      } else {
        // If email is verified, navigate to the SelectGeolocation page
        Get.off(
          () => const SelectGeolocation(isStart: true),
          transition: Transition.downToUp,
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle sign-in errors (e.g., wrong password, user not found)
      Get.snackbar('Error', e.message ?? 'Sign-in failed');
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Enter email' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.length < 6 ? 'Password too short' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signIn,
                child: Text('Sign In'),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to SignupPage if the user doesn't have an account
                  Get.to(() => SignupPage(), transition: Transition.rightToLeft);
                },
                child: Text('Don’t have an account? Sign up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

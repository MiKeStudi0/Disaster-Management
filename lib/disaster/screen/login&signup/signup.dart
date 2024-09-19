import 'package:disaster_management/disaster/screen/login&signup/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disaster_management/app/ui/geolocation.dart'; // Import the geolocation page

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create user with Firebase Authentication
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        User? user = userCredential.user;

        if (user != null && !user.emailVerified) {
          // Send email verification
          await user.sendEmailVerification();
          Get.snackbar('Email Verification', 'A verification email has been sent. Please check your inbox.');

          // Wait for email verification
          await _waitForVerification(user);
        }
      } on FirebaseAuthException catch (e) {
        // Handle sign-up errors
        Get.snackbar('Error', e.message ?? 'Sign-up failed');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _waitForVerification(User user) async {
    // Show a waiting page
    Get.dialog(
      AlertDialog(
        title: Text('Please Verify Your Email'),
        content: Text('We have sent a verification email. Please verify to continue.'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close the dialog
            },
            child: Text('Okay'),
          ),
        ],
      ),
    );

    // Poll for email verification
    while (!user.emailVerified) {
      await Future.delayed(Duration(seconds: 5));
      await user.reload();
      user = FirebaseAuth.instance.currentUser!;
    }

    // After verification, save user data (name, phone, address)
    await _saveUserData(user);
    Get.off(() => SelectGeolocation(isStart: true), transition: Transition.downToUp);
  }

  Future<void> _saveUserData(User user) async {
    // Here, save the user's additional information (name, phone, address) to your database
    // For example, using Firestore or Realtime Database
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Enter name' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Enter email' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                validator: (value) => value!.isEmpty ? 'Enter phone number' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) => value!.isEmpty ? 'Enter address' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.length < 6 ? 'Password too short' : null,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _signUp,
                      child: Text('Sign Up'),
                    ),
              TextButton(
                onPressed: () {
                  // Navigate back to sign-in page
                  Get.to(() => SignInPage(), transition: Transition.rightToLeft);
                },
                child: Text('Already have an account? Sign in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:io'; // For File type
import 'package:disaster_management/disaster/screen/login&signup/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart'; // Add image picker
import 'package:firebase_storage/firebase_storage.dart'; // Add Firebase Storage
import 'package:disaster_management/app/ui/geolocation.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _districtController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  File? _profileImage; // Variable to store selected image

  final ImagePicker _picker = ImagePicker(); // Instance of ImagePicker

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        User? user = userCredential.user;

        if (user != null && !user.emailVerified) {
          await user.sendEmailVerification();
          Get.snackbar(
            'Email Verification',
            'A verification email has been sent. Please check your inbox.',
            backgroundColor: Theme.of(context).colorScheme.primary,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );

          await _waitForVerification(user);
        }
      } on FirebaseAuthException catch (e) {
        Get.snackbar(
          'Error',
          e.message ?? 'Sign-up failed',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _waitForVerification(User user) async {
    Get.dialog(
      AlertDialog(
        title: const Text('Please Verify Your Email'),
        content: const Text(
            'We have sent a verification email. Please verify to continue.'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Okay'),
          ),
        ],
      ),
    );

    while (!user.emailVerified) {
      await Future.delayed(const Duration(seconds: 5));
      await user.reload();
      user = FirebaseAuth.instance.currentUser!;
    }

    await _saveUserData(user);
    Get.off(() => const SelectGeolocation(isStart: true),
        transition: Transition.downToUp);
  }

  Future<void> _saveUserData(User user) async {
    String uid = user.uid;
    String name = _nameController.text;
    String email = _emailController.text;
    String phone = _phoneController.text;
    String address = _addressController.text;
    String district = _districtController.text;

    String? profileImageUrl;

    // If there's a profile image, upload it
    if (_profileImage != null) {
      try {
        // Upload image to Firebase Storage
        final storageRef = FirebaseStorage.instance.ref().child('profile_pictures/$uid');
        UploadTask uploadTask = storageRef.putFile(_profileImage!);
        await uploadTask;
        profileImageUrl = await storageRef.getDownloadURL();
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to upload profile picture: $e',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    // Upload user data to Firestore
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'district': district,
      'profileImageUrl': profileImageUrl ?? '', // Store image URL
      'createdAt': Timestamp.now(),
    }).then((_) {
      Get.snackbar(
        'Success',
        'User data saved successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }).catchError((error) {
      Get.snackbar(
        'Error',
        'Failed to save user data: $error',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const Padding(
              //   padding: EdgeInsets.only(left: 10),
              //   child: Text(
              //     'Disaster Management',
              //     style: TextStyle(
              //         fontFamily: 'Poppins',
              //         fontSize: 24,
              //         fontWeight: FontWeight.bold,
              //         color: Color.fromARGB(255, 251, 251, 251)),
              //   ),
              // ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                      const Center(
                          child:  Text(
                            'Create Account',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 118, 118, 118)),
                          ),
                        ),
                                      const SizedBox(height: 20),

                        // Profile Image Picker
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: colorScheme.secondary,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : null,
                            child: _profileImage == null
                                ? const Icon(Icons.add_a_photo, size: 30)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(_nameController, 'Name', Icons.person),
                        const SizedBox(height: 16),
                        _buildTextField(_emailController, 'Email', Icons.email),
                        const SizedBox(height: 16),
                        _buildTextField(
                            _phoneController, 'Phone Number', Icons.phone),
                        const SizedBox(height: 16),
                        _buildTextField(
                            _addressController, 'Address', Icons.location_on),
                        const SizedBox(height: 16),
                        _buildTextField(_districtController, 'District',
                            Icons.location_city),
                        const SizedBox(height: 16),
                        _buildPasswordField(),
                        const SizedBox(height: 20),

                        const SizedBox(height: 20),

                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _signUp,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 5,
                                    shadowColor:
                                        colorScheme.primary.withOpacity(0.5),
                                  ),
                                  child: const Text('Sign Up'),
                                ),
                              ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            Get.to(() => const SignInPage(),
                                transition: Transition.rightToLeft);
                          },
                          child: const Text(
                              'Already have an account?                Sign in'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colorScheme.onSurface),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.onSurface),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.secondary),
        ),
      ),
      validator: (value) => value!.isEmpty ? 'Enter $label' : null,
    );
  }

  TextFormField _buildPasswordField() {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: Icon(Icons.lock, color: colorScheme.onSurface),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.onSurface),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.secondary),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: colorScheme.onSurface,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
      validator: (value) => value!.length < 6 ? 'Password too short' : null,
    );
  }
}

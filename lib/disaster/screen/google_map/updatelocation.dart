import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vibration/vibration.dart';

class LocationTrackingPage extends StatefulWidget {
  const LocationTrackingPage({super.key});

  @override
  _LocationTrackingPageState createState() => _LocationTrackingPageState();
}

class _LocationTrackingPageState extends State<LocationTrackingPage> {
  late Timer _timer;
  bool _isTrackingEnabled = false;
  late String _userId;
  late String _username;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _initializeTrackingStatus();
  }

  // Initialize the tracking status based on the Firebase database
  Future<void> _initializeTrackingStatus() async {
    User? user = _auth.currentUser;
    if (user != null) {
      _userId = user.uid;

      // Fetch the username from Firestore
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(_userId).get();
      if (userDoc.exists) {
        setState(() {
          _username = userDoc[
              'name']; // Assuming the field 'name' exists in the Firestore document
        });
      }

      // Fetch the user's tracking status from Firebase Realtime Database
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref().child('users_tracking/$_username');
      DataSnapshot snapshot = await userRef.get();

      if (snapshot.exists) {
        bool isTracking = snapshot.child('isTracking').value as bool? ?? false;
        setState(() {
          _isTrackingEnabled = isTracking;
        });
      } else {
        setState(() {
          _isTrackingEnabled = false;
        });
      }
    }
  }

// Add the following updates to your code

void _updateTrackingStatus(bool value) async {
  DatabaseReference userRef =
      FirebaseDatabase.instance.ref().child('users_tracking/$_username');

  if (value) {
    // Fetch user data from Firestore before starting location updates
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(_userId).get();

      if (!userSnapshot.exists) {
        print("Error: User document not found in Firestore.");
        return;
      }

      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

      // Initialize user's data in Realtime Database before starting location updates
      Map<String, dynamic> initialData = {
        'name': userData['name'] ?? 'Unknown',
        'email': userData['email'] ?? 'Unknown',
        'phone': userData['phone'] ?? 'Unknown',
        'address': userData['address'] ?? 'Unknown',
        'district': userData['district'] ?? 'Unknown',
        'profileImageUrl': userData['profileImageUrl'] ?? 'Unknown',
        'isTracking': true,
        'location': {
          'latitude': 0.0, // Placeholder until location updates start
          'longitude': 0.0
        },
        'timestamp': DateTime.now().toIso8601String(),
      };

      await userRef.update(initialData).then((_) {
        print("Initial user data written to Realtime Database: $initialData");
      }).catchError((error) {
        print("Error writing initial data to Realtime Database: $error");
      });

      // Start location updates after initializing data
      _startLocationUpdates();
    } catch (e) {
      print("Error initializing tracking status: $e");
    }
  } else {
    // Update tracking status to false and stop location updates
    userRef.update({'isTracking': false}).then((_) {
      print("Tracking disabled in Realtime Database.");
    }).catchError((error) {
      print("Error updating tracking status: $error");
    });

    _stopLocationUpdates();
  }
}

void _startLocationUpdates() async {
  try {
    if (_username.isEmpty) {
      print("Error: Username is not initialized.");
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        // Update location and timestamp in Realtime Database
        DatabaseReference userRef =
            FirebaseDatabase.instance.ref().child('users_tracking/$_username');

        await userRef.update({
          'location': {
            'latitude': position.latitude,
            'longitude': position.longitude,
          },
          'timestamp': DateTime.now().toIso8601String(),
        }).then((_) {
          print("Location and timestamp updated successfully.");
        }).catchError((error) {
          print("Error updating location in Realtime Database: $error");
        });
      } catch (e) {
        print("Error during periodic location update: $e");
      }
    });
  } catch (e) {
    print("Error starting location updates: $e");
  }
}


  // Stop location updates
  void _stopLocationUpdates() {
    if (_timer.isActive) {
      _timer.cancel();
    }
  }

  // Update the user's location in Firebase
  void _updateUserLocation(Position position) {
    DatabaseReference userRef =
        FirebaseDatabase.instance.ref().child('users_tracking/$_username');

    userRef.set({
      'location': {
        'latitude': position.latitude,
        'longitude': position.longitude,
      },
      'isTracking': true, // Ensure tracking status is set to true
    }).then((_) {
      print("Location updated in Firebase");
    }).catchError((error) {
      print("Failed to update location: $error");
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Location Tracking")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Toggle button to enable/disable tracking
            SwitchListTile(
              title: const Text('Share Location'),
              value: _isTrackingEnabled,
              onChanged: (bool value) {
                setState(() {
                  _isTrackingEnabled = value;
                });
                _updateTrackingStatus(
                    value); // Update tracking status in database
              },
            ),
            const SizedBox(height: 20),
            // Display current tracking status
            Text(
              _isTrackingEnabled
                  ? "Location is being shared."
                  : "Location sharing is turned off.",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_isTrackingEnabled) {
      _stopLocationUpdates(); // Stop location updates when page is disposed
    }
    super.dispose();
  }
}

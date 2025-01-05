import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Start location updates based on time interval (every 5 seconds)
  void _startLocationUpdates() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _updateUserLocation(position);
    });
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

  // Update tracking status in Firebase
  void _updateTrackingStatus(bool value) async {
    DatabaseReference userRef =
        FirebaseDatabase.instance.ref().child('users_tracking/$_username');

    // Update only the 'isTracking' field in the user's data
    userRef.update({
      'isTracking': value,
    });

    if (value) {
      _startLocationUpdates(); // Start tracking when enabled
    } else {
      _stopLocationUpdates(); // Stop tracking when disabled
    }
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

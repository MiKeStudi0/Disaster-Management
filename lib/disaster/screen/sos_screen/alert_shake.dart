import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vibration/vibration.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ShakeLocationPage extends StatefulWidget {
  const ShakeLocationPage({super.key});

  @override
  _ShakeLocationPageState createState() => _ShakeLocationPageState();
}

class _ShakeLocationPageState extends State<ShakeLocationPage> {
  late List<double> _accelerometerValues;
  late DateTime _lastShakeTime;
  static const double _shakeThreshold = 12.0;
  static const Duration _shakeCooldown = Duration(seconds: 5);
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    _lastShakeTime = DateTime.now();
    _accelerometerValues = [0, 0, 0];
    // accelerometerEvents.listen(_onAccelerometerEvent);
    _accelerometerSubscription =
        accelerometerEventStream().listen(_onAccelerometerEvent);
  }

  @override
  void dispose() {
    _accelerometerSubscription.cancel();
    super.dispose();
    print('Shake sos closed');
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    final currentTime = DateTime.now();
    if (currentTime.difference(_lastShakeTime) > _shakeCooldown) {
      _accelerometerValues = [event.x, event.y, event.z];

      final double magnitude = sqrt(
          _accelerometerValues[0] * _accelerometerValues[0] +
              _accelerometerValues[1] * _accelerometerValues[1] +
              _accelerometerValues[2] * _accelerometerValues[2]);

      if (magnitude > _shakeThreshold) {
        _lastShakeTime = currentTime;
        _sendLocationToFirebase();
        _showSOSAlert();
        _triggerVibration();
      }
    }
  }

  Future<void> _sendLocationToFirebase() async {
    try {
      // Check network connectivity
      if (!await _isConnectedToNetwork()) {
        print("No internet connection. Unable to send data.");
        return;
      }

      // Check location permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("Location services are disabled.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      print("Current permission status: $permission");

      if (permission == LocationPermission.denied) {
        print("Requesting location permission...");
        permission = await Geolocator.requestPermission();
      }
      print("Permission after request: $permission");

      if (permission == LocationPermission.deniedForever) {
        print("Location permissions are permanently denied.");
        return;
      }
      print('access loc');

      // Fetch the current location
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      Position? position = await Geolocator.getLastKnownPosition();
      print('Location received: ${position?.latitude}, ${position?.longitude}');

      // Get the current user UID from Firebase Authentication
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print("User is not logged in.");
        return;
      }

      String uid = currentUser.uid;
      print("User logged in with UID: $uid");

      // Fetch the user's name from the Firestore 'users' collection
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userSnapshot.exists) {
        print("User document not found.");
        return;
      }
      String userName = userSnapshot.get('name');
      print("User's name: $userName");

      // Send location to Firestore with the user's name instead of UID
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('Alert_locations').doc(uid).set({
        'name': userName,
        'latitude': position?.latitude,
        'longitude': position?.longitude,
        'timestamp': DateTime.now(),
      });

      print(
          'Location sent to Firebase with name $userName: ${position?.latitude}, ${position?.longitude}');
    } catch (e) {
      if (e is TimeoutException) {
        print("Error: The location request timed out. Please try again.");
      } else {
        print('Error sending location to Firebase: $e');
      }
    }
  }

  Future<bool> _isConnectedToNetwork() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  void _triggerVibration() {
    Vibration.vibrate(duration: 1000); // Vibrate for 1 second
  }

  Future<void> _showSOSAlert() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Emergency SOS'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This is an emergency alert!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text('Your location has been sent to emergency services.'),
              SizedBox(height: 10),
              Text(
                  'Please remain calm and stay where you are until help arrives.'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(0),
            child: SizedBox(
              child: Column(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 150.0),
                        child: Center(
                          child: Lottie.asset(
                            'assets/animation/sos.json',
                            width: 300,
                            height: 300,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding:
                        EdgeInsets.only(left: 25.0, right: 20.0, top: 50.0),
                    child: Center(
                      child: Text(
                        'Shake your phone to send your location to emergency services and trigger an SOS alert to reach rescue teams ⚠️',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

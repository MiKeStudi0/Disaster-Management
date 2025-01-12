import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  late GoogleMapController _mapController;
  LatLng _currentPosition = const LatLng(0.0, 0.0);

  @override
  void initState() {
    super.initState();
    _initializeTrackingStatus();
    _getCurrentLocation();
  }

  Future<void> _initializeTrackingStatus() async {
    User? user = _auth.currentUser;
    if (user != null) {
      _userId = user.uid;
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(_userId).get();
      if (userDoc.exists) {
        setState(() {
          _username = userDoc['name'];
        });
      }
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

  void _updateTrackingStatus(bool value) async {
    DatabaseReference userRef =
        FirebaseDatabase.instance.ref().child('users_tracking/$_username');
    if (value) {
      try {
        DocumentSnapshot userSnapshot =
            await FirebaseFirestore.instance.collection('users').doc(_userId).get();
        if (!userSnapshot.exists) {
          print("Error: User document not found in Firestore.");
          return;
        }
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> initialData = {
          'name': userData['name'] ?? 'Unknown',
          'email': userData['email'] ?? 'Unknown',
          'phone': userData['phone'] ?? 'Unknown',
          'address': userData['address'] ?? 'Unknown',
          'district': userData['district'] ?? 'Unknown',
          'profileImageUrl': userData['profileImageUrl'] ?? 'Unknown',
          'isTracking': true,
          'location': {
            'latitude': 0.0,
            'longitude': 0.0
          },
          'timestamp': DateTime.now().toIso8601String(),
        };
        await userRef.update(initialData);
        _startLocationUpdates();
      } catch (e) {
        print("Error initializing tracking status: $e");
      }
    } else {
      userRef.update({'isTracking': false});
      _stopLocationUpdates();
    }
  }

  void _startLocationUpdates() async {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        DatabaseReference userRef =
            FirebaseDatabase.instance.ref().child('users_tracking/$_username');
        await userRef.update({
          'location': {
            'latitude': position.latitude,
            'longitude': position.longitude,
          },
          'timestamp': DateTime.now().toIso8601String(),
        });
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
      } catch (e) {
        print("Error during periodic location update: $e");
      }
    });
  }

  void _stopLocationUpdates() {
    if (_timer.isActive) {
      _timer.cancel();
    }
  }
void _setMapStyle() async {
  String style = await DefaultAssetBundle.of(context).loadString('assets/map_style.json');
  _mapController.setMapStyle(style);
}

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
    if (_mapController != null) {
      _mapController.animateCamera(CameraUpdate.newLatLng(_currentPosition));
    }
  }
@override
Widget build(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  return Scaffold(
    appBar: AppBar(
      title: const Text(
        "Location Tracking",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    body: Column(
      children: [
        Expanded(
          flex: 5,
          child: GoogleMap(
            fortyFiveDegreeImageryEnabled: true,
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 15,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              _setMapStyle();
            },
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
            
              borderRadius:  BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                SwitchListTile(
                  title: Text(
                    'Share Location',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  value: _isTrackingEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      _isTrackingEnabled = value;
                    });
                    _updateTrackingStatus(value);
                  },
                  activeColor: colorScheme.primary,
                  inactiveThumbColor: colorScheme.onSurfaceVariant,
                  inactiveTrackColor: colorScheme.surface,
                ),
                const SizedBox(height: 10),
                Text(
                  _isTrackingEnabled
                      ? "Location is being shared."
                      : "Location sharing is turned off.",
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _isTrackingEnabled
                        ? colorScheme.primary
                        : colorScheme.error,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Current Location: ${_currentPosition.latitude}, ${_currentPosition.longitude}",
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}


  @override
  void dispose() {
    if (_isTrackingEnabled) {
      _stopLocationUpdates();
    }
    super.dispose();
  }
}

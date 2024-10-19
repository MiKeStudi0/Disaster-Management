import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Initialize notification plugin
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
Timer? _timer;
bool _isInArea = false;
int _timeSpentInArea = 0;

// Function to start monitoring user location and trigger alerts
Future<void> locationAlertFunction() async {
  // Initialize notifications
  await _initializeNotifications();

  // Fetch alert locations from Firestore
  List<Map<String, dynamic>> alertPlaces =
      await _fetchAlertPlacesFromFirestore();

  // Start location tracking
  _startLocationTracking(alertPlaces);
}

// Initialize local notifications
Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

// Fetch all latitude, longitude, and radius values from Firebase collection
Future<List<Map<String, dynamic>>> _fetchAlertPlacesFromFirestore() async {
  List<Map<String, dynamic>> alertPlaces = [];

  // Fetch all documents from the 'Alertplace' collection
  QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('Danger_zones').get();

  for (var doc in snapshot.docs) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Assuming 'latitude', 'longitude', and 'radius' are fields in the collection
    alertPlaces.add({
      'latitude': data['latitude'],
      'longitude': data['longitude'],
      'radius': data['radius']
    });
  }

  return alertPlaces;
}

// Start location tracking
void _startLocationTracking(List<Map<String, dynamic>> alertPlaces) {
  Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // 10 meters
    ),
  ).listen((Position position) {
    bool userInAnyArea = false;

    // Loop through each alert place and check the user's proximity
    for (var place in alertPlaces) {
      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        place['latitude']!,
        place['longitude']!,
      );

      print("Distance from target: $distance meters");

      if (distance <= place['radius']!) {
        userInAnyArea = true;
        if (!_isInArea) {
          _isInArea = true;
          _startTimer();
          print("User has entered the area.");
        }
        break; // Exit the loop since we only need one area to trigger
      }
    }

    if (!userInAnyArea) {
      _resetTimer();
      print("User is not in any area.");
    }
  });
}

// Start a timer to track how long the user stays in the area
void _startTimer() {
  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    _timeSpentInArea++;

    print('User in area for $_timeSpentInArea seconds.');

    // Trigger alert if the user has been in the area for 5 minutes (300 seconds)
    if (_timeSpentInArea >= 3) {
      _showNotification();
      _resetTimer();
    }
  });
}

// Function to show notification
Future<void> _showNotification() async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'channel_id',
    'channel_name',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    'Location Alert',
    'You have stayed in this area for 5 minutes.',
    platformChannelSpecifics,
  );
}

// Reset the timer when user leaves the area
void _resetTimer() {
  _timer?.cancel();
  _timeSpentInArea = 0;
  _isInArea = false;
}

// Function to cancel the timer when no longer needed
void disposeLocationTracking() {
  _timer?.cancel();
}

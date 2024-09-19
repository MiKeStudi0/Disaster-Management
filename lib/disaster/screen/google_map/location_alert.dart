import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Define the specific location you want to monitor
final double targetLatitude = 11.4385327290558;
final double targetLongitude = 75.850978336516;
final double radius = 5000.0; // Area radius in meters (e.g., 5000 meters)

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
Timer? _timer;
bool _isInArea = false;
int _timeSpentInArea = 0;

void locationAlertFunction() {
  // Initialize notifications
  _initializeNotifications();

  // Start location tracking
  _startLocationTracking();
}

// Initialize local notifications
void _initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

// Function to display local notification
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
  await flutterLocalNotificationsPlugin.show(0, 'Location Alert',
      'You have stayed in this area for 5 minutes.', platformChannelSpecifics);
}

// Start location tracking
void _startLocationTracking() {
  Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // 10 meters
    ),
  ).listen((Position position) {
    double distance = Geolocator.distanceBetween(
        position.latitude, position.longitude, targetLatitude, targetLongitude);

    print("Distance from target: $distance meters");

    if (distance <= radius) {
      if (!_isInArea) {
        _isInArea = true;
        _startTimer();
        print("User has entered the area.");
      }
    } else {
      _resetTimer();
      print("User has left the area.");
    }
  });
}

// Start a 5-minute timer
void _startTimer() {
  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    _timeSpentInArea++;

    print('User in area for $_timeSpentInArea seconds.');

    // When user has been in the area for 5 minutes (300 seconds)
    if (_timeSpentInArea >= 3) {
      _showNotification();
      _resetTimer();
    }
  });
}

// Reset the timer when the user leaves the area
void _resetTimer() {
  _timer?.cancel();
  _timeSpentInArea = 0;
  _isInArea = false;
}

// Function to dispose of the timer
void disposeLocationTracking() {
  _timer?.cancel();
}

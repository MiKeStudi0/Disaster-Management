import 'dart:ui';


import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shake/shake.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vibration/vibration.dart';

class ShakeLocationPage extends StatefulWidget {
  @override
  _ShakeLocationPageState createState() => _ShakeLocationPageState();
}

class _ShakeLocationPageState extends State<ShakeLocationPage> {
  @override
  void initState() {
    super.initState();
    ShakeDetector.autoStart(onPhoneShake: () {
      _sendLocationToFirebase();
      _showSOSAlert();
      _triggerVibration(); // Trigger haptic feedback
    });
  }Future<void> _sendLocationToFirebase() async {
  try {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference locations = firestore.collection('Alert_locations');

    await locations.doc().set({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': DateTime.now(),
    });

    print(
        'Location sent to Firebase: ${position.latitude}, ${position.longitude}');
  } catch (e) {
    print('Error sending location: $e');
  }
}

  Future<void> _showSOSAlert() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Emergency SOS'),
          content: Column(
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
                'Please remain calm and stay where you are until help arrives.',
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Trigger haptic feedback
  void _triggerVibration() {
                          Vibration.vibrate(duration: 1000);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: Column(
        children: [
          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: SizedBox(
                              // height: MediaQuery.of(context).size.height,
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
                    'assets/animation/sos.json', // path to your Lottie animation file
                    width: 300,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
         const Padding(
            padding:  EdgeInsets.only(left: 25.0 , right: 20.0 , top: 50.0),
            child: Center(
              child: Text(
                'Shake your Phone to Send Your Location To Emergency Services and Trigger SOS Alert to Reach Rescue Teams⚠️',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                
              ),
            ),
          ),
        ],
      ),
    ))]));
  }
}
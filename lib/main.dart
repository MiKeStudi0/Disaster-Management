import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live Location',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LocationScreen(),
    );
  }
}

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  Position? _currentPosition;
  String _locationMessage = "Fetching location...";

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationMessage = 'Location services are disabled.';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        setState(() {
          _locationMessage = 'Location permissions are denied.';
        });
        return;
      }
    }

    _listenToLocationChanges();
  }

  void _listenToLocationChanges() {
    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1, // Set to 1 meter for frequent updates
      ),
    ).listen((Position position) {
      print('Position updated: ${position.latitude}, ${position.longitude}');
      setState(() {
        _currentPosition = position;
        _locationMessage =
            'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Location'),
      ),
      body: Center(
        child: Text(
          _locationMessage,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

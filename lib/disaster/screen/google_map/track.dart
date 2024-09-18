import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationTrackingScreen extends StatefulWidget {
  @override
  _LocationTrackingScreenState createState() => _LocationTrackingScreenState();
}

class _LocationTrackingScreenState extends State<LocationTrackingScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final List<LatLng> _polylineCoordinates = [];
  late Position _currentPosition;
  late StreamSubscription<Position> _positionStream;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    final hasPermission = await Permission.location.isGranted;
    if (!hasPermission) {
      return;
    }

    // Get the current location
    _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
      accuracy: LocationAccuracy.high, // Updated parameter name
      distanceFilter: 10,
    ));
    _updateMapLocation(_currentPosition);

    // Start listening to location updates
    _positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high, // Updated parameter name
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = position;
        _updateMapLocation(position);
        _polylineCoordinates.add(LatLng(position.latitude, position.longitude));
        _polylines.add(
          Polyline(
            polylineId: PolylineId('route'),
            points: _polylineCoordinates,
            color: Colors.blue,
            width: 5,
          ),
        );
      });
    });
  }

  void _updateMapLocation(Position position) {
    _mapController.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(position.latitude, position.longitude),
      ),
    );

    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('current_location'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: InfoWindow(title: 'You are here'),
        ),
      );
    });
  }

  @override
  void dispose() {
    _positionStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Location Tracking')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(0, 0),
          zoom: 2.0,
        ),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        markers: _markers,
        polylines: _polylines,
      ),
    );
  }
}

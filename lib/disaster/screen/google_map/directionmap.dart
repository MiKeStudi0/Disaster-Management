import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

class MapDirectionPage extends StatefulWidget {
  final LatLng destination;

  MapDirectionPage({required this.destination});

  @override
  _MapDirectionPageState createState() => _MapDirectionPageState();
}

class _MapDirectionPageState extends State<MapDirectionPage> {
  late GoogleMapController _mapController;
  LatLng _currentPosition = LatLng(0, 0); // Initial dummy position
  List<LatLng> _polylineCoordinates = [];
  Set<Polyline> _polylines = {};
  String? _nextInstruction;
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Fetch initial location
    _startLocationUpdates(); // Start continuous updates
  }

  @override
  void dispose() {
    _tts.stop(); // Stop TTS
    super.dispose();
  }

  /// Fetches the current location of the user.
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      _fetchDirections(); // Fetch the route once the location is determined
    } catch (e) {
      print('Error fetching current location: $e');
    }
  }

  /// Continuously updates the user's location in real-time.
  void _startLocationUpdates() {
    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Minimum distance to trigger update
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      // Center map to current location
      _mapController.animateCamera(CameraUpdate.newLatLng(_currentPosition));
      _checkRouteDeviation();
    });
  }

  /// Fetches the route directions and displays the polyline.
  Future<void> _fetchDirections() async {
    try {
      String apiKey =
          "AIzaSyBJMhMpJEZEN2fubae-mdIZ-vCEXOAkHMk"; // Replace with your API Key
      String url =
          "https://maps.googleapis.com/maps/api/directions/json?origin=${_currentPosition.latitude},${_currentPosition.longitude}&destination=${widget.destination.latitude},${widget.destination.longitude}&mode=driving&key=$apiKey";

      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data['routes'].isNotEmpty) {
        List steps = data['routes'][0]['legs'][0]['steps'];
        setState(() {
          _polylineCoordinates = [];
          for (var step in steps) {
            PolylinePoints polylinePoints = PolylinePoints();
            List<PointLatLng> result =
                polylinePoints.decodePolyline(step['polyline']['points']);
            for (var point in result) {
              _polylineCoordinates.add(LatLng(point.latitude, point.longitude));
            }
          }

          _polylines = {
            Polyline(
              polylineId: PolylineId("route"),
              points: _polylineCoordinates,
              color: Colors.blue,
              width: 5,
            ),
          };
        });

        _updateNextInstruction(steps); // Speak the first instruction
      } else {
        print("No route found.");
      }
    } catch (e) {
      print("Error fetching directions: $e");
    }
  }

  /// Updates the next navigation instruction.
  void _updateNextInstruction(List steps) {
    if (steps.isNotEmpty) {
      setState(() {
        _nextInstruction = steps[0]['html_instructions'];
      });
      _tts.speak(_nextInstruction!); // Speak the instruction
    }
  }

  /// Checks if the user has deviated from the route.
  void _checkRouteDeviation() {
    const double deviationThreshold = 50.0; // Threshold in meters
    bool isOffRoute = _polylineCoordinates.every((LatLng point) {
      double distance = Geolocator.distanceBetween(
        _currentPosition.latitude,
        _currentPosition.longitude,
        point.latitude,
        point.longitude,
      );
      return distance > deviationThreshold;
    });

    if (isOffRoute) {
      _fetchDirections(); // Fetch new route if off-route
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Navigation")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: LatLng(0, 0), zoom: 13),
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            polylines: _polylines,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Text(
                _nextInstruction ?? "Fetching directions...",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

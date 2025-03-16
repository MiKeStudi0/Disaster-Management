import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:disaster_management/disaster/screen/rescue/const.dart';

class MapDirectionPage extends StatefulWidget {
  final LatLng destination;

  const MapDirectionPage({super.key, required this.destination});

  @override
  _MapDirectionPageState createState() => _MapDirectionPageState();
}

class _MapDirectionPageState extends State<MapDirectionPage> {
  late GoogleMapController _mapController;
  LatLng _currentPosition = const LatLng(0, 0); // Initial dummy position
  List<LatLng> _polylineCoordinates = [];
  Set<Polyline> _polylines = {};
  String? _nextInstruction;
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      _fetchDirections(); // Fetch route after getting the location
    } catch (e) {
      print('Error fetching current location: $e');
    }
  }

  void _startLocationUpdates() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      _mapController.animateCamera(CameraUpdate.newLatLng(_currentPosition));
      _checkRouteDeviation();
    });
  }

  /// Fetches the route using Google Routes API
  Future<void> _fetchDirections() async {
    const String apiKey = map;
    const String url =
        "https://routes.googleapis.com/directions/v2:computeRoutes";

    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      'X-Goog-FieldMask':
          'routes.polyline.encodedPolyline,routes.legs.steps.navigationInstruction'
    };

    final body = jsonEncode({
      "origin": {
        "location": {
          "latLng": {
            "latitude": _currentPosition.latitude,
            "longitude": _currentPosition.longitude
          }
        }
      },
      "destination": {
        "location": {
          "latLng": {
            "latitude": widget.destination.latitude,
            "longitude": widget.destination.longitude
          }
        }
      },
      "travelMode": "DRIVE",
      "routingPreference": "TRAFFIC_AWARE"
    });

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);
      print("API Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["routes"] != null && data["routes"].isNotEmpty) {
          String encodedPolyline =
              data["routes"][0]["polyline"]["encodedPolyline"];
          _polylineCoordinates = _decodePolyline(encodedPolyline);
          _updatePolylines();

          List steps = data["routes"][0]["legs"][0]["steps"];
          _updateNextInstruction(steps);
          setState(() {});
        } else {
          print("No routes found.");
        }
      } else {
        print("Error fetching route: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (e) {
      print("Error fetching directions: $e");
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int byte;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);

      int deltaLat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += deltaLat;

      shift = 0;
      result = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);

      int deltaLng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += deltaLng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  void _updatePolylines() {
    setState(() {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: PolylineId("route"),
          points: _polylineCoordinates,
          color: Colors.blue,
          width: 5,
        ),
      );
    });
  }

  void _updateNextInstruction(List steps) {
    if (steps.isNotEmpty) {
      setState(() {
        _nextInstruction = steps[0]['navigationInstruction']['instruction'];
      });
      _tts.speak(_nextInstruction!);
    }
  }

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
      print("Off route! Recalculating...");
      _fetchDirections();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Navigation")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: _currentPosition, zoom: 13),
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10)
                ],
              ),
              child: Text(
                _nextInstruction ?? "Fetching directions...",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

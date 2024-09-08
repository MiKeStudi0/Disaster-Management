import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  await dotenv.load(fileName: ".env");
   runApp(MyApp());}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map Directions',
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final LatLng _startLocation = LatLng(11.430790, 75.699440); // Kerala
  final LatLng _endLocation = LatLng(11.450060, 75.770447); // Delhi
  Set<Polyline> _polylines = {};
  List<LatLng> _polylineCoordinates = [];
 

  @override
  void initState() {  
    super.initState();
    _getDirections();
  }

  void _getDirections() async {
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_startLocation.latitude},${_startLocation.longitude}&destination=${_endLocation.latitude},${_endLocation.longitude}&key=APIKEY';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      print(response.body); // Debug: Print the response
      final decodedData = json.decode(response.body);
      final routes = decodedData['routes'] as List;
      if (routes.isNotEmpty) {
        final points = routes[0]['overview_polyline']['points'];
        _polylineCoordinates = _decodePolyline(points);
        setState(() {
          _polylines.add(
            Polyline(
              polylineId: PolylineId('route'),
              points: _polylineCoordinates,
              color: Colors.blue,
              width: 5,
            ),
          );
        });
      }
    } else {
      print("Failed to get directions: ${response.statusCode}");
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Map Directions')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _startLocation,
          zoom: 5.0, // Adjust this to focus on the route
        ),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        polylines: _polylines,
        markers: {
          Marker(markerId: MarkerId('start'), position: _startLocation),
          Marker(markerId: MarkerId('end'), position: _endLocation),
        },
      ),
    );
  }
}

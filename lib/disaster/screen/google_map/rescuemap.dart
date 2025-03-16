import 'dart:convert';
import 'package:disaster_management/disaster/screen/rescue/const.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class RescueMap extends StatefulWidget {
  const RescueMap({super.key});

  @override
  _RescueMapState createState() => _RescueMapState();
}

class _RescueMapState extends State<RescueMap> {
  late GoogleMapController _mapController;
  LatLng? _currentLocation;
  double _heading = 0.0;
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _initializeCompass();
  }

  void _setMapStyle() async {
    String style = await DefaultAssetBundle.of(context)
        .loadString('assets/map_style.json');
    _mapController.setMapStyle(style);
  }

  void _initializeCompass() {
    FlutterCompass.events!.listen((event) {
      setState(() {
        _heading = event.heading ?? 0.0;
      });
    });
  }

  Future<void> _determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print('Location permissions are denied');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
    _fetchRecuseLocation();
    _moveCameraToCurrentLocation();
  }

  void _moveCameraToCurrentLocation() {
    if (_currentLocation != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLng(_currentLocation!),
      );
    }
  }

  Future<void> _fetchRecuseLocation() async {
    if (_currentLocation == null) return;

    print('Fetching locations near $_currentLocation');

    // Fetch locations from Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot =
        await firestore.collection('Resucelocations').get();

    List<QueryDocumentSnapshot> documents = querySnapshot.docs;

    print('Fetched ${documents.length} locations'); // Debugging log

    // Add markers and handle directions for each location
    _addMarkersFromFirebase(documents);
  }

  void _addMarkersFromFirebase(List<QueryDocumentSnapshot> documents) {
    setState(() {
      _markers.clear();
      for (var document in documents) {
        // Get latitude and longitude from Firestore (as strings)
        String latString = document['latitude'];
        String lngString = document['longitude'];
        String name = document['name'] ?? 'Unknown';

        // Convert the latitude and longitude from string to double
        double lat = double.tryParse(latString) ?? 0.0;
        double lng = double.tryParse(lngString) ?? 0.0;

        // Add the marker if valid lat and lng values are found
        if (lat != 0.0 && lng != 0.0) {
          _markers.add(
            Marker(
              markerId: MarkerId(name),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(title: name),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
              onTap: () {
                _getDirectionsToPlace(LatLng(
                    lat, lng)); // Add direction route when the marker is tapped
              },
            ),
          );
        }
      }
    });
  }

  void _getDirectionsToPlace(LatLng destination) async {
    if (_currentLocation == null) return;

    const apiKey = map; // Replace with your actual API key
    final url =
        Uri.parse("https://routes.googleapis.com/directions/v2:computeRoutes");

    final headers = {
      "Content-Type": "application/json",
      "X-Goog-Api-Key": apiKey,
      "X-Goog-FieldMask":
          "routes.polyline.encodedPolyline" // Fetch only required fields
    };

    final body = jsonEncode({
      "origin": {
        "location": {
          "latLng": {
            "latitude": _currentLocation!.latitude,
            "longitude": _currentLocation!.longitude
          }
        }
      },
      "destination": {
        "location": {
          "latLng": {
            "latitude": destination.latitude,
            "longitude": destination.longitude
          }
        }
      },
      "travelMode": "DRIVE",
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      if (decodedData['routes'].isNotEmpty) {
        final points = decodedData['routes'][0]['polyline']['encodedPolyline'];
        List<LatLng> polylineCoordinates = _decodePolyline(points);
        setState(() {
          _polylines.clear();
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('route_to_place'),
              points: polylineCoordinates,
              color: Colors.red,
              width: 5,
            ),
          );
        });
        _mapController.animateCamera(
          CameraUpdate.newLatLng(destination),
        );
      } else {
        print('No routes found');
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
      appBar: AppBar(title: Text('SafeRescue Directions')),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation!,
                    zoom: 10.0,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                    _moveCameraToCurrentLocation();
                    _setMapStyle();
                  },
                  polylines: _polylines,
                  markers: _markers.union({
                    Marker(
                      markerId: const MarkerId('current_location'),
                      position: _currentLocation!,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueBlue),
                      rotation: _heading,
                    ),
                  }),
                ),
                Positioned(
                  top: 16.0,
                  right: 16.0,
                  child: GestureDetector(
                    onTap: () {
                      _mapController.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: _currentLocation!,
                            zoom: 10.0,
                            bearing: _heading,
                          ),
                        ),
                      );
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.navigation,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

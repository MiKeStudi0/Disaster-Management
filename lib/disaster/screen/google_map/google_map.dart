import 'dart:convert';
import 'package:disaster_management/disaster/screen/rescue/const.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  final String? keyword;

  const MapScreen({super.key, this.keyword});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  LatLng? _currentLocation;
  double _heading = 0.0; // Store the compass heading
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _initializeCompass();
  }
void _setMapStyle() async {
  String style = await DefaultAssetBundle.of(context).loadString('assets/map_style.json');
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
    _fetchPoliceStations();
    _moveCameraToCurrentLocation();
  }

  void _moveCameraToCurrentLocation() {
    if (_currentLocation != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLng(_currentLocation!),
      );
    }
  }

  void _fetchPoliceStations() async {
    if (_currentLocation == null) return;

    print('Fetching ${widget.keyword} near $_currentLocation');
    const apiKey = map; // Replace with your actual Google Places API key
    final url = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/nearbysearch/json',
      {
        'location': '${_currentLocation!.latitude},${_currentLocation!.longitude}',
        'radius': '10000', // 10 km radius
        'type': widget.keyword,
        'key': apiKey,
      },
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      final places = decodedData['results'] as List;
      _addMarkers(places);
    } else {
      print("Failed to fetch places: ${response.statusCode}");
    }
  }

  void _addMarkers(List places) {
    setState(() {
      _markers.clear();
      for (var place in places) {
        final location = place['geometry']['location'];
        final lat = location['lat'];
        final lng = location['lng'];
        final name = place['name'];

        _markers.add(
          Marker(
            markerId: MarkerId(name),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: name),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            onTap: () {
              _getDirectionsToPlace(LatLng(lat, lng));
            },
          ),
        );
      }
    });
  }

  void _getDirectionsToPlace(LatLng destination) async {
    if (_currentLocation == null) return;

    const apiKey = map; // Replace with your actual API key
    final url = Uri.https(
      'maps.googleapis.com',
      '/maps/api/directions/json',
      {
        'origin': '${_currentLocation!.latitude},${_currentLocation!.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'key': apiKey,
        'mode': 'driving',
      },
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      final routes = decodedData['routes'] as List;
      if (routes.isNotEmpty) {
        final points = routes[0]['overview_polyline']['points'];
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
      appBar: AppBar(title: Text('${widget.keyword} Directions')),
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
                  //compassEnabled: true,
                  polylines: _polylines,
                  markers: _markers.union({
                    Marker(
                      markerId: const MarkerId('current_location'),
                      position: _currentLocation!,
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
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
                            bearing: _heading, // Update bearing to face the user’s direction
                          ),
                        ),
                      );
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.navigation, // Compass-like icon
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

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DangerZoneMap extends StatefulWidget {
  const DangerZoneMap({super.key});

  @override
  _DangerZoneMapState createState() => _DangerZoneMapState();
}

class _DangerZoneMapState extends State<DangerZoneMap> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Circle> _circles = {};
  String? _selectedZoneDescription;
  LatLng? _currentLocation;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchDangerZonesFromFirebase();
  }

  void _setMapStyle() {
    getJsonFile('assets/map_style.json').then((String value) {
      final mapStyle = value;
      _controller.future.then((controller) {
        controller.setMapStyle(mapStyle);
      });
    }).catchError((error) {
      debugPrint('Error setting map style: $error');
    });
  }

  Future<String> getJsonFile(String path) async {
    return await rootBundle.loadString(path);
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _addCurrentLocationMarker(
            LatLng(position.latitude, position.longitude));
      });

      if (_currentLocation != null) {
        final GoogleMapController controller = await _controller.future;
        controller
            .animateCamera(CameraUpdate.newLatLngZoom(_currentLocation!, 14.0));
      }
    }
  }

  void _addCurrentLocationMarker(LatLng position) {
    if (_currentLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
      _moveCamera(position);
    }
  }

  Future<void> _moveCamera(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: position, zoom: 12.0),
    ));
    _addMarker(position);
  }

  void _addMarker(
    LatLng position,
  ) {
    final Marker marker = Marker(
      markerId: MarkerId("You are here"),
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );
    setState(() {
      _markers.add(marker);
    });
  }

  void _addDangerMarker(LatLng position, String description) async {
    final BitmapDescriptor dangerIcon = await _getCustomIcon();

    final Marker marker = Marker(
      markerId: MarkerId(position.toString()),
      position: position,
      icon: dangerIcon,
      infoWindow: InfoWindow(
        title: 'Danger Zone',
        snippet: 'Tap for details',
        onTap: () {
          _showMarkerDetails(description);
        },
      ),
    );

    setState(() {
      _markers.add(marker);
    });
  }

  // Function to load the custom icon from the assets
  Future<BitmapDescriptor> _getCustomIcon() async {
    return await BitmapDescriptor.asset(
      ImageConfiguration(size: Size(35, 35)),
      'assets/icons/caution-icon.png',
    );
  }

  void _showMarkerDetails(String description) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              top: 16.0,
              left: 16.0,
              right: 16.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Danger Zone",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _fetchDangerZonesFromFirebase() async {
    try {
      FirebaseFirestore.instance
          .collection('Danger_zones')
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          try {
            debugPrint('Processing document: ${doc.id}');
            var data = doc.data();
            debugPrint('Document data: $data');
            double latitude = double.tryParse(data['latitude'].toString()) ??
                (throw FormatException('Invalid latitude'));
            double longitude = double.tryParse(data['longitude'].toString()) ??
                (throw FormatException('Invalid longitude'));
            double radius = double.tryParse(data['radius'].toString()) ??
                (throw FormatException('Invalid radius'));
            String description = data['description'] ?? 'Unknown';

            LatLng position = LatLng(latitude, longitude);
            _addCircle(position, radius / 5, description);
            _addDangerMarker(position, description);
          } catch (e) {
            debugPrint('Error processing document ${doc.id}: $e');
          }
        }
      }).catchError((error) {
        debugPrint('Error fetching documents: $error');
      });
    } catch (e) {
      debugPrint('Unexpected error: $e');
    }
  }

  void _addCircle(LatLng position, double radius, String description) {
    final Circle circle = Circle(
      circleId: CircleId(description),
      center: position,
      radius: radius,
      fillColor: Colors.red.withOpacity(0.5),
      strokeColor: Colors.red,
      strokeWidth: 2,
      onTap: () {
        setState(() {
          _selectedZoneDescription = description;
        });
      },
    );
    setState(() {
      _circles.add(circle);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danger Zones'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(11.258753, 75.780411),
              zoom: 10.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              _setMapStyle();
            },
            circles: _circles,
            markers: _markers,
          ),
          if (_selectedZoneDescription != null)
            Positioned(
              bottom: 20,
              left: 15,
              right: 15,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Danger Zone',
                        style: GoogleFonts.ubuntu(
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedZoneDescription!,
                        style: GoogleFonts.ubuntu(
                          textStyle: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedZoneDescription = null;
                            });
                          },
                          child: const Text('Close'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

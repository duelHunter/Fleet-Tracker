import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../widgets/bottom_navigation.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Location _location = Location();
  LatLng _currentPosition =
      const LatLng(6.9271, 79.8612); // Default to Colombo, Sri Lanka

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    // Check if location services are enabled
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) return;
    }

    // Check for location permissions
    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }

    // Fetch current location
    final userLocation = await _location.getLocation();
    setState(() {
      _currentPosition =
          LatLng(userLocation.latitude!, userLocation.longitude!);
    });

    // Move the map camera to the user's location
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_currentPosition, 14.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        centerTitle: true,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentPosition,
          zoom: 14.0,
        ),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 1),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

import 'package:location/location.dart';

class LocationService {
  final Location _location = Location();

  Future<LocationData> getCurrentPosition() async {
    // Check if location services are enabled.
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }
    }

    // Check location permission.
    PermissionStatus permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission != PermissionStatus.granted) {
        throw Exception('Location permission denied.');
      }
    }

    // Get the current location.
    return await _location.getLocation();
  }

  Stream<LocationData> trackPosition() {
    return _location.onLocationChanged;
  }
}

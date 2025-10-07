import 'package:geolocator/geolocator.dart';
import 'package:railtime/model/lat_lon.dart';

class LocationService {
  /// Try to gain permission to use location from user
  ///
  /// Return true is location service is enabled and permitted, false otherwise
  Future<bool> _handleLocationPermission() async {
    // Check if location service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  /// Get the current GPS location
  ///
  /// Return [LatLon] or null no permission or unable to obtain
  Future<LatLon?> getCurrentLocation() async {
    // Check permission
    final bool hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      return null;
    }
    // Get current location
    await for (Position position in Geolocator.getPositionStream(
      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        timeLimit: Duration(seconds: 10),
      ),
    )) {
      return LatLon(
        position.latitude,
        position.longitude,
      ); // Return the first fresh position
    }

    return null;
  }
}

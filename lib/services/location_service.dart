import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static const double officeLat = -6.301334940855258;
  static const double officeLng = 106.73515885138507;

  static const double validRadiusMeters = 100.0;

  Future<bool> ensurePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  Future<Position> getCurrentPosition() async {
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  double distanceFromOffice(double lat, double lng) {
    return Geolocator.distanceBetween(lat, lng, officeLat, officeLng);
  }

  Future<String?> reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
          p.country,
        ].where((e) => e != null && e.isNotEmpty).map((e) => e!).toList();
        return parts.join(', ');
      }
    } catch (_) {}
    return null;
  }
}

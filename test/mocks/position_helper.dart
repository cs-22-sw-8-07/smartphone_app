import 'package:geolocator/geolocator.dart';

Position mockPosition(double lat, double long) {
  return Position(
      accuracy: 0.0,
      altitude: 0.0,
      heading: 0.0,
      latitude: lat,
      longitude: long,
      speed: 0.0,
      speedAccuracy: 0.0,
      timestamp: DateTime.now(),
      isMocked: true);
}

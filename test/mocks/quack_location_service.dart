import 'package:geolocator_platform_interface/src/models/position.dart';
import 'package:smartphone_app/services/quack_location_service/interfaces/quack_location_functions.dart';
import 'package:smartphone_app/services/quack_location_service/service/quack_location_service.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';

Position getMockPosition(double lat, double long) {
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

class MockQuackLocationService implements IQuackLocationFunctions {
  QuackLocationType? _locationType;

  @override
  List<FurthestDistancePerimeter> get furthestDistancePerimeters =>
      throw UnimplementedError();

  @override
  Future<QuackLocationType?> getQuackLocationType(Position position) async {
    return _locationType;
  }

  @override
  QuackLocationType get locationType => _locationType!;

  set locationType(QuackLocationType locationType) =>
      _locationType = locationType;
}

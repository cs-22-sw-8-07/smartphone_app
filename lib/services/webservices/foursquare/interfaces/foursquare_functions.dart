import 'package:smartphone_app/services/webservices/foursquare/models/foursquare_classes.dart';
import 'package:smartphone_app/services/webservices/foursquare/services/foursquare_service.dart';

class IFoursquareFunctions {
  Future<FoursquareServiceResponse<GetNearbyPlacesResponse>> getNearbyPlaces(
      {required double latitude, required double longitude}) {
    throw UnimplementedError();
  }

  Future<FoursquareServiceResponse<GetPlacesResponse>> getPlaces(
      {required double latitude,
      required double longitude,
      required int radiusInMeters,
      required List<int> categories}) {
    throw UnimplementedError();
  }
}

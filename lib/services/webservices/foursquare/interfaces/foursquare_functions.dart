import 'package:smartphone_app/services/webservices/foursquare/models/foursquare_classes.dart';
import 'package:smartphone_app/services/webservices/foursquare/services/foursquare_service.dart';

class IFoursquareFunctions {

  /// Get nearby places from Foursquare from a given [latitude] and [longitude]
  Future<FoursquareServiceResponse<GetNearbyPlacesResponse>> getNearbyPlaces(
      {required double latitude, required double longitude}) {
    throw UnimplementedError();
  }

  /// Get places from Foursquare from a given [latitude] and [longitude]
  /// The results can be filtered through:
  ///
  /// [radiusInMeters] which tells the furthest distance to get places from
  /// [categories] which specifies the category of places to get
  Future<FoursquareServiceResponse<GetPlacesResponse>> getPlaces(
      {required double latitude,
      required double longitude,
      required int radiusInMeters,
      required List<int> categories}) {
    throw UnimplementedError();
  }
}

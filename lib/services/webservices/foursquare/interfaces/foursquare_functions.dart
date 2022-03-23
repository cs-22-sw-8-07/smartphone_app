import 'package:smartphone_app/services/webservices/foursquare/models/foursquare_classes.dart';
import 'package:smartphone_app/services/webservices/foursquare/services/foursquare_service.dart';

class IFoursquareFunctions {
  Future<FoursquareServiceResponse<GetNearbyPlacesResponse>> getNearbyPlaces(
      {required double latitude, required double longitude}) {
    throw UnimplementedError();
  }
}

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:smartphone_app/services/webservices/foursquare/interfaces/foursquare_functions.dart';
import 'package:smartphone_app/services/webservices/foursquare/models/foursquare_classes.dart';
import 'package:smartphone_app/services/webservices/foursquare/services/foursquare_service.dart';

class MockFoursquareService implements IFoursquareFunctions {
  ///
  /// METHODS
  ///
  //region Methods

  Future<dynamic> getJsonData(String assetName) async {
    String jsonStr =
    await rootBundle.loadString('assets/mock_data/' + assetName);
    return await json.decode(jsonStr);
  }

//endregion

  ///
  /// OVERRIDE METHODS
  ///
//region Override methods

  @override
  Future<FoursquareServiceResponse<GetNearbyPlacesResponse>> getNearbyPlaces({required double latitude, required double longitude}) async {
    return FoursquareServiceResponse.success(GetNearbyPlacesResponse.fromJson(
        await getJsonData("foursquare_get_nearby_places_response.json")));
  }

//endregion
}
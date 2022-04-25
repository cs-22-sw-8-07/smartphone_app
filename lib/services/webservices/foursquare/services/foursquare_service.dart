import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smartphone_app/services/webservices/foursquare/interfaces/foursquare_functions.dart';
import 'package:smartphone_app/services/webservices/foursquare/models/foursquare_classes.dart';

import '../../../../helpers/rest_helper.dart';

class FoursquareServiceResponse<Response extends FoursquareResponse> {
  String? exception;
  Response? foursquareResponse;

  FoursquareServiceResponse.error(this.exception);

  FoursquareServiceResponse.success(this.foursquareResponse);

  bool get isSuccess {
    return exception == null;
  }

  String? get errorMessage {
    if (exception != null) return exception;
    return null;
  }
}

class FoursquareService implements IFoursquareFunctions {
  ///
  /// STATIC
  ///
  //region Static

  static IFoursquareFunctions? _foursquareFunctions;
  static String? _apiKey;

  static init(IFoursquareFunctions foursquareFunctions) {
    _foursquareFunctions = foursquareFunctions;
    _apiKey = dotenv.env['FOURSQUARE_API_KEY'].toString();
  }

  static IFoursquareFunctions getInstance() {
    return _foursquareFunctions!;
  }

  //endregion

  ///
  /// CONSTANTS
  ///
  //region Constants

  static const String url = "https://api.foursquare.com";

  //endregion

  ///
  /// VARIABLES
  ///
  //region Variables

  late RestHelper restHelper;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  FoursquareService() {
    restHelper = RestHelper(url: url);
  }

  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  /// Converts integer list into a comma separated string e.g. "1,2,3,4"
  String _getIntegerListAsCommaSeparatedString(List<int> list) {
    if (list.isEmpty) {
      return "";
    }
    String str = list.first.toString();
    for (int i = 1; i < list.length; i++) {
      str += "," + list[i].toString();
    }
    return str;
  }

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
//region Override methods

  @override
  Future<FoursquareServiceResponse<GetNearbyPlacesResponse>> getNearbyPlaces(
      {required double latitude, required double longitude}) async {
    try {
      // Send GET request
      RestResponse restResponse =
          await restHelper.sendGetRequest("/v3/places/nearby", parameters: {
        "ll": latitude.toString().replaceAll(",", ".") +
            "," +
            longitude.toString().replaceAll(",", "."),
        "limit": "50"
      }, headers: {
        "Authorization": _apiKey!
      });
      // Check for errors
      if (!restResponse.isSuccess) {
        return FoursquareServiceResponse.error(restResponse.errorMessage);
      }
      // Decode json
      GetNearbyPlacesResponse response =
          GetNearbyPlacesResponse.fromJson(restResponse.jsonResponse);
      // Return success response
      return FoursquareServiceResponse.success(response);
    } on Exception catch (e) {
      return FoursquareServiceResponse.error(e.toString());
    }
  }

  @override
  Future<FoursquareServiceResponse<GetPlacesResponse>> getPlaces(
      {required double latitude,
      required double longitude,
      required int radiusInMeters,
      required List<int> categories}) async {
    try {
      // Send GET request
      RestResponse restResponse =
          await restHelper.sendGetRequest("/v3/places/search", parameters: {
        "ll": latitude.toString().replaceAll(",", ".") +
            "," +
            longitude.toString().replaceAll(",", "."),
        "limit": "50",
        "radius": radiusInMeters.toString(),
        "sort": "distance",
        if (categories.isNotEmpty)
          "categories": _getIntegerListAsCommaSeparatedString(categories)
      }, headers: {
        "Authorization": _apiKey!
      });
      // Check for errors
      if (!restResponse.isSuccess) {
        return FoursquareServiceResponse.error(restResponse.errorMessage);
      }
      // Decode json
      GetPlacesResponse response =
          GetPlacesResponse.fromJson(restResponse.jsonResponse);
      // Return success response
      return FoursquareServiceResponse.success(response);
    } on Exception catch (e) {
      return FoursquareServiceResponse.error(e.toString());
    }
  }

//endregion

}

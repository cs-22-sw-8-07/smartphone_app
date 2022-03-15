import 'package:geolocator/geolocator.dart';
import 'package:smartphone_app/services/webservices/foursquare/models/foursquare_classes.dart';
import 'package:smartphone_app/services/webservices/foursquare/service/foursquare_service.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';

import '../../../helpers/position_helper/position_helper.dart';
import '../interfaces/quack_location_functions.dart';

class QuackLocationService implements IQuackLocationFunctions {
  ///
  /// STATICS
  ///
  //region Statics

  static int getQuackLocationTypeInt(QuackLocationType qlt) {
    switch (qlt) {
      case QuackLocationType.forest:
        return 1;
      case QuackLocationType.beach:
        return 2;
    }
  }

  static IQuackLocationFunctions? _quackLocationFunctions;

  static init(IQuackLocationFunctions quackLocationFunctions) {
    _quackLocationFunctions = quackLocationFunctions;
  }

  static IQuackLocationFunctions getInstance() {
    return _quackLocationFunctions!;
  }

//endregion

  ///
  /// VARIABLES
  ///
  //region Variables

  Position? latestPosition;
  List<FoursquarePlace> places = [];
  double? updateRadius;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  QuackLocationService();

//endregion

  ///
  /// METHODS
  ///
  //region Methods

  Future<List<FoursquarePlace>> getFoursquarePlaces(Position position) async {
    FoursquareServiceResponse<GetNearbyPlacesResponse> response =
        await FoursquareService.getInstance().getNearbyPlaces(
            latitude: position.latitude, longitude: position.longitude);

    if (!response.isSuccess) {
      return [];
    }

    return response.foursquareResponse!.results!;
  }

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  Future<QuackLocationType> getQuackLocationType(Position position) async {
    /*Geolocator.get

    if (updateRadius == null || updateRadius) {



    } else {}*/
    return QuackLocationType.beach;
  }

//endregion

}

import 'package:geolocator/geolocator.dart';
import 'package:smartphone_app/services/quack_location_service/helpers/quack_location_helper.dart';
import 'package:smartphone_app/services/webservices/foursquare/models/foursquare_classes.dart';
import 'package:smartphone_app/services/webservices/foursquare/service/foursquare_service.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';
import 'package:darq/darq.dart';

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
      case QuackLocationType.unknown:
        // TODO: Handle this case.
        break;
      case QuackLocationType.nightLife:
        // TODO: Handle this case.
        break;
      case QuackLocationType.urban:
        // TODO: Handle this case.
        break;
      case QuackLocationType.cemetery:
        // TODO: Handle this case.
        break;
      case QuackLocationType.education:
        // TODO: Handle this case.
        break;
      case QuackLocationType.church:
        // TODO: Handle this case.
        break;
    }
    return 0;
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

  final int _inPerimeterDistance = 100;
  Position? latestPosition;
  List<FoursquarePlace> allPlaces = [];
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

  Future<List<FoursquarePlace>?> getFoursquarePlaces(Position position) async {
    FoursquareServiceResponse<GetNearbyPlacesResponse> response =
    await FoursquareService.getInstance().getNearbyPlaces(
        latitude: position.latitude, longitude: position.longitude);

    if (!response.isSuccess) {
      return null;
    }

    return response.foursquareResponse!.results!;
  }

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  Future<QuackLocationType?> getQuackLocationType(Position position) async {
    double? distanceBetween;

    if (latestPosition != null) {
      distanceBetween = Geolocator.distanceBetween(
          latestPosition!.latitude, latestPosition!.longitude,
          position.latitude, position.longitude);
    }

    if (updateRadius == null || distanceBetween! >= updateRadius!) {
      latestPosition = position;
     var places = await getFoursquarePlaces(position);
     if (places == null) {
       return null;
     }
     // Sort after distance closest -> to furthest away
     places.sort((a, b) => a.distance!.compareTo(b.distance!));

     updateRadius = places.last.distance!.toDouble();

     // Add to complete list
     for (var place in places) {
       if (!allPlaces.contains(place)) {
         allPlaces.add(place);
       }
     }

     for (var place in places) {
       if (place.distance! > _inPerimeterDistance) {
         return QuackLocationType.unknown;
       }
       QuackLocationType locationType = QuackLocationHelper.getQuackLocationType(place);
       if (locationType != QuackLocationType.unknown) {
         return locationType;
       }
     }

     return QuackLocationType.unknown;
    }

    return null;
  }

//endregion

}

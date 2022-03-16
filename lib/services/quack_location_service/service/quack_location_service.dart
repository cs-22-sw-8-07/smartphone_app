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
  Position? latestSearchPosition;
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

  Future<List<FoursquarePlace>?> _getFoursquarePlaces(Position position) async {
    FoursquareServiceResponse<GetNearbyPlacesResponse> response =
        await FoursquareService.getInstance().getNearbyPlaces(
            latitude: position.latitude, longitude: position.longitude);

    if (!response.isSuccess) {
      return null;
    }

    return response.foursquareResponse!.results!;
  }

  List<FoursquarePlace> _getAllPlacesWithinPerimeter(Position position) {
    return allPlaces.where((x) {
      double? distance = x.distanceBetween(position);
      x.distance = distance?.toInt();
      return distance != null && distance <= _inPerimeterDistance;
    }).toList(growable: true);
  }

  /// Sort after distance closest -> to furthest away
  void _sortPlacesAfterDistance(List<FoursquarePlace> places) {
    places.sort((a, b) => a.distance!.compareTo(b.distance!));
  }

  QuackLocationType _getQuackLocationTypeFromPlacesInPerimeter(
      List<FoursquarePlace> places) {
    // Check places within the perimeter
    for (var place in places) {
      if (place.distance! > _inPerimeterDistance) {
        return QuackLocationType.unknown;
      }
      QuackLocationType locationType =
      QuackLocationHelper.getQuackLocationType(place);
      if (locationType != QuackLocationType.unknown) {
        return locationType;
      }
    }
    return QuackLocationType.unknown;
  }

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  Future<QuackLocationType?> getQuackLocationType(Position position) async {
    double? distanceBetweenSearchPlaces;
    double? distanceBetween;

    if (latestSearchPosition != null) {
      distanceBetweenSearchPlaces = Geolocator.distanceBetween(
          latestSearchPosition!.latitude,
          latestSearchPosition!.longitude,
          position.latitude,
          position.longitude);
    }

    if (updateRadius == null || distanceBetweenSearchPlaces! >= updateRadius!) {
      latestSearchPosition = position;
      latestPosition = position;
      var places = await _getFoursquarePlaces(position);
      if (places == null) {
        return null;
      }

      _sortPlacesAfterDistance(places);
      updateRadius = places.last.distance!.toDouble();

      var allPlacesInPerimeter = _getAllPlacesWithinPerimeter(position);

      // Add to old places list
      for (var place in places) {
        if (!allPlaces.contains(place)) {
          allPlaces.add(place);
        }
      }

      // All new places plus old places within the perimeter
      var placesInPerimeter = places;
      placesInPerimeter.addAll(allPlacesInPerimeter);
      _sortPlacesAfterDistance(placesInPerimeter);

      return _getQuackLocationTypeFromPlacesInPerimeter(placesInPerimeter);
    }

    if (latestPosition != null) {
      distanceBetween = Geolocator.distanceBetween(latestPosition!.latitude,
          latestPosition!.longitude, position.latitude, position.longitude);
    }

    if (distanceBetween != null && distanceBetween >= _inPerimeterDistance) {
      latestPosition = position;

      var allPlacesInPerimeter = _getAllPlacesWithinPerimeter(position);
      _sortPlacesAfterDistance(allPlacesInPerimeter);

      return _getQuackLocationTypeFromPlacesInPerimeter(allPlacesInPerimeter);
    }
  }

//endregion

}

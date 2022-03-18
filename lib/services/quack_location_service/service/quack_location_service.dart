import 'package:flutter/foundation.dart';
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
  Position? latestPerimeterPosition;
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

  /// Get nearby places for the current [position] from the Foursquare API
  ///
  /// Returns: A nullable list of [FoursquarePlace]
  Future<List<FoursquarePlace>?> _getFoursquarePlaces(Position position) async {
    FoursquareServiceResponse<GetNearbyPlacesResponse> response =
        await FoursquareService.getInstance().getNearbyPlaces(
            latitude: position.latitude, longitude: position.longitude);

    if (!response.isSuccess) {
      return null;
    }

    return response.foursquareResponse!.results!;
  }

  /// Get all old places within the perimeter for the current [position]
  ///
  /// Returns: A list of [FoursquarePlace]
  List<FoursquarePlace> _getAllPlacesWithinPerimeter(Position position) {
    return allPlaces.where((x) {
      double? distance = x.distanceBetween(position);
      x.distance = distance?.toInt();
      return distance != null && distance <= _inPerimeterDistance;
    }).toList(growable: true);
  }

  /// Sort [places] after [distance] in a [FoursquarePlace] ascending
  void _sortPlacesAfterDistance(List<FoursquarePlace> places) {
    places.sort((a, b) => a.distance!.compareTo(b.distance!));
  }

  /// Go through all the categories in the list [places]
  ///
  /// Returns: A [QuackLocationType] corresponding to a category, or
  /// [QuackLocationType.unknown] if no match could be found
  QuackLocationType _getQuackLocationTypeFromPlacesInPerimeter(
      List<FoursquarePlace> places) {
    List<String> categories = [];

    try {
      for (var place in places) {
        if (place.categories!.isNotEmpty &&
            !categories.contains(place.categories![0].name!)) {
          categories.add(place.categories![0].name!);
        }
      }

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
    } finally {
      if (kDebugMode) {
        print(categories);
      }
    }
  }

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  Future<QuackLocationType?> getQuackLocationType(Position position) async {
    double? distanceBetweenSearchPlaces;

    if (latestSearchPosition != null) {
      // Calculate distance between the latest position where places was
      // gathered from Foursquare and the current position
      distanceBetweenSearchPlaces = Geolocator.distanceBetween(
          latestSearchPosition!.latitude,
          latestSearchPosition!.longitude,
          position.latitude,
          position.longitude);
    }

    if (updateRadius == null ||
        distanceBetweenSearchPlaces! >=
            (updateRadius! - _inPerimeterDistance)) {
      // Set latest search position
      latestSearchPosition = position;
      // Set latest perimeter position
      latestPerimeterPosition = position;
      // Get nearby places from Foursquare
      var places = await _getFoursquarePlaces(position);
      if (places == null) {
        return null;
      }

      _sortPlacesAfterDistance(places);
      // Set update radius to largest distance in the places list
      updateRadius = places.last.distance!.toDouble();

      // Get all old places within perimeter
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

      // Go through all places within the perimeter
      return _getQuackLocationTypeFromPlacesInPerimeter(placesInPerimeter);
    } else if (latestPerimeterPosition != null) {
      double? distanceBetween = Geolocator.distanceBetween(
          latestPerimeterPosition!.latitude,
          latestPerimeterPosition!.longitude,
          position.latitude,
          position.longitude);

      // Check if the new position is far enough away from the last position
      if (distanceBetween >= _inPerimeterDistance) {
        latestPerimeterPosition = position;

        // Get all old places within the perimeter
        var allPlacesInPerimeter = _getAllPlacesWithinPerimeter(position);
        _sortPlacesAfterDistance(allPlacesInPerimeter);

        // Go through all old places and get the first matching
        // QuackLocationType
        return _getQuackLocationTypeFromPlacesInPerimeter(allPlacesInPerimeter);
      }
    }

    return null;
  }

//endregion

}

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smartphone_app/services/quack_location_service/helpers/quack_location_helper.dart';
import 'package:smartphone_app/services/webservices/foursquare/models/foursquare_classes.dart';
import 'package:smartphone_app/services/webservices/foursquare/services/foursquare_service.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';

import '../interfaces/quack_location_functions.dart';

class HighestDistancePerimeter {
  final Position center;
  final double radius;

  HighestDistancePerimeter({required this.center, required this.radius});
}

int getQuackLocationTypeInt(QuackLocationType qlt) {
  switch (qlt) {
    case QuackLocationType.unknown:
      return 0;
    case QuackLocationType.church:
      return 1;
    case QuackLocationType.education:
      return 2;
    case QuackLocationType.cemetery:
      return 3;
    case QuackLocationType.forest:
      return 4;
    case QuackLocationType.beach:
      return 5;
    case QuackLocationType.urban:
      return 6;
    case QuackLocationType.nightLife:
      return 7;
  }
}

class QuackLocationService implements IQuackLocationFunctions {
  ///
  /// STATICS
  ///
  //region Statics

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

  final int _locationTypeUpdatePerimeterRadius = 100;
  Position? _locationTypeUpdatePerimeterCenterPosition;
  final List<FoursquarePlace> _allPlaces = [];
  final List<HighestDistancePerimeter> _highestDistancePerimeters = [];
  QuackLocationType _locationType = QuackLocationType.unknown;

  //endregion

  ///
  /// PROPERTIES
  ///
  //region Properties

  Position? get locationTypeUpdatePerimeterCenterPosition =>
      _locationTypeUpdatePerimeterCenterPosition;

  QuackLocationType get locationType => _locationType;

  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  /// Get nearby places for the current [position] from the Foursquare API
  ///
  /// Returns: A nullable list of [FoursquarePlace]
  Future<List<FoursquarePlace>?> _getFoursquarePlaces(Position position) async {
    List<int> categoriesList = [];
    for (var item in QuackLocationHelper.getAllCategoriesAsList()) {
      categoriesList.addAll(item.categories);
    }

    FoursquareServiceResponse<GetNearbyPlacesResponse> response =
        await FoursquareService.getInstance().getNearbyPlaces(
            latitude: position.latitude, longitude: position.longitude);

    if (!response.isSuccess) {
      return null;
    }

    return response.foursquareResponse!.results!;
  }

  /// Update distance for all places according to the given [position]
  void _updateDistanceForAllPlaces(Position position) {
    // Update all distances
    for (var place in _allPlaces) {
      double? distance = place.distanceBetween(position);
      place.distance = distance?.toInt();
    }
  }

  /// Sort [places] after [distance] in a [FoursquarePlace] ascending
  void _sortPlacesAfterDistance(List<FoursquarePlace> places) {
    places.sort((a, b) => a.distance!.compareTo(b.distance!));
  }

  /// Go through all the categories in the list [places]
  ///
  /// Returns: A [QuackLocationType] corresponding to a category, or
  /// [QuackLocationType.unknown] if no match could be found
  QuackLocationType _getQuackLocationTypeFromPlaces(
      List<FoursquarePlace> places) {
    // Check places within the perimeter
    for (var place in places) {
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
    if (!_isWithinUpdatePlacesPerimeters(position)) {
      // Set latest perimeter position
      _locationTypeUpdatePerimeterCenterPosition = position;
      // Get nearby places from Foursquare
      var places = await _getFoursquarePlaces(position);
      if (places == null) {
        return null;
      }
      if (kDebugMode) {
        print("Number of places retrieved: " + places.length.toString());
      }
      double? furthestDistancePerimeterRadius;

      if (places.isNotEmpty) {
        // Get distance to furthest place
        furthestDistancePerimeterRadius = places.last.distance!.toDouble();
        if (kDebugMode) {
          print("FP radius: " + furthestDistancePerimeterRadius.toString());
        }
        // Add to all places list
        for (var place in places) {
          if (!_allPlaces.contains(place)) {
            _allPlaces.add(place);
          }
        }
      }

      if (places.isEmpty ||
          furthestDistancePerimeterRadius! <
              _locationTypeUpdatePerimeterRadius.toDouble()) {
        furthestDistancePerimeterRadius =
            _locationTypeUpdatePerimeterRadius.toDouble() * 2;
      }

      // Add highest distance perimeter first in the list. This is done because the
      // user is most likely to be in this perimeter and it is checked first
      _highestDistancePerimeters.insert(
          0,
          HighestDistancePerimeter(
              center: position, radius: furthestDistancePerimeterRadius));
      // Go through all places to get a QuackLocationType
      return getQuackLocationTypeFromAllPlaces(position);
    } else if (_locationTypeUpdatePerimeterCenterPosition != null) {
      double? distanceBetween = Geolocator.distanceBetween(
          _locationTypeUpdatePerimeterCenterPosition!.latitude,
          _locationTypeUpdatePerimeterCenterPosition!.longitude,
          position.latitude,
          position.longitude);

      // Check if the new position is out of the perimeter
      if (distanceBetween >= _locationTypeUpdatePerimeterRadius) {
        _locationTypeUpdatePerimeterCenterPosition = position;

        // Go through all places to get a QuackLocationType
        return getQuackLocationTypeFromAllPlaces(position);
      }
    }

    return null;
  }

  bool _isWithinUpdatePlacesPerimeters(Position position) {
    for (var perimeter in _highestDistancePerimeters) {
      var distanceBetween = Geolocator.distanceBetween(
          perimeter.center.latitude,
          perimeter.center.longitude,
          position.latitude,
          position.longitude);

      if (distanceBetween <
          (perimeter.radius - _locationTypeUpdatePerimeterRadius)) {
        if (kDebugMode) {
          print("Is within perimeter: true");
        }
        return true;
      }
    }
    if (kDebugMode) {
      print("Is within perimeter: false");
    }
    return false;
  }

  QuackLocationType getQuackLocationTypeFromAllPlaces(Position position) {
    // Update distance for all places
    _updateDistanceForAllPlaces(position);
    // Sort places after distance
    _sortPlacesAfterDistance(_allPlaces);

    // Go through all places to get a QuackLocationType
    _locationType = _getQuackLocationTypeFromPlaces(_allPlaces);
    return _locationType;
  }

//endregion

}

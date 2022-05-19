import 'package:geolocator/geolocator.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';

import '../service/quack_location_service.dart';

class IQuackLocationFunctions {
  /// Get the currently assigned [QuackLocationType]
  QuackLocationType get locationType {
    throw UnimplementedError();
  }

  /// The list of [FurthestDistancePerimeter] which specifies the areas where
  /// the user has been
  List<FurthestDistancePerimeter> get furthestDistancePerimeters {
    throw UnimplementedError();
  }

  /// Get a [QuackLocationType] based on a given [position]
  Future<QuackLocationType?> getQuackLocationType(Position position) {
    throw UnimplementedError();
  }
}

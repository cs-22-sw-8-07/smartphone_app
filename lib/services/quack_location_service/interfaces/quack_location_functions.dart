
import 'package:geolocator/geolocator.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';

import '../service/quack_location_service.dart';

class IQuackLocationFunctions {

  QuackLocationType get locationType {
    throw UnimplementedError();
  }

  List<FurthestDistancePerimeter> get furthestDistancePerimeters {
    throw UnimplementedError();
  }

  Future<QuackLocationType?> getQuackLocationType(Position position) {
    throw UnimplementedError();
  }



}
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class PositionHelper {
  ///
  /// VARIABLES
  ///
  //region Variables

  final AndroidSettings? androidSettings;
  final AppleSettings? appleSettings;
  LocationSettings? locationSettings;
  StreamController<Position?> positionStreamController =
      StreamController.broadcast();

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  PositionHelper({required this.androidSettings, required this.appleSettings}) {
    if (Platform.isAndroid) {
      locationSettings = androidSettings;
    } else {
      locationSettings = appleSettings;
    }

    setupPositionStream();
  }

  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  void dispose() {

  }

  Future<Position?> getCurrentLocation() {
    return Geolocator.getCurrentPosition(forceAndroidLocationManager: true);
  }

  Future<Position?> getLastKnownLocation() {
    return Geolocator.getLastKnownPosition(forceAndroidLocationManager: true);
  }

  void setupPositionStream() {
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) {
      if (kDebugMode) {
        print("Position: " +
            (position == null
                ? 'Unknown'
                : '${position.latitude.toString()}, ${position.longitude.toString()}'));
      }
      positionStreamController.add(position);
    });
  }

  Stream<Position?> getPositionStream() {
    return positionStreamController.stream;
  }

  //endregion

}

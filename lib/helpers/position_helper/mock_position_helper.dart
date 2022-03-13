import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:geolocator_android/src/types/android_settings.dart';
import 'package:geolocator_apple/src/types/apple_settings.dart';
import 'package:smartphone_app/helpers/position_helper/position_helper.dart';

class MockPositionHelper extends PositionHelper {

  ///
  /// VARIABLES
  ///
  //region Variables

  bool runThread = true;
  Timer? timer;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  MockPositionHelper({required AndroidSettings androidSettings,
    required AppleSettings appleSettings})
      : super(androidSettings: androidSettings, appleSettings: appleSettings);

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  void setupPositionStream() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      Position position = Position(longitude: 50.11111,
          latitude: 9.999,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0);
      positionStreamController.add(position);
    });
  }

  @override
  void dispose() {
    runThread = false;
    if (timer != null) {
      timer!.cancel();
    }
  }

//endregion
}

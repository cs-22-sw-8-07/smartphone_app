import 'package:geolocator/geolocator.dart';
import 'package:geolocator_android/src/types/android_settings.dart';
import 'package:geolocator_apple/src/types/apple_settings.dart';
import 'package:smartphone_app/helpers/position_helper/position_helper.dart';

class MockPositionHelper extends PositionHelper {

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  MockPositionHelper() : super(androidSettings: null, appleSettings: null);

  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  void setMockPosition(Position? position) {
    positionStreamController.add(position);
  }

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  void setupPositionStream() {

  }

  //endregion
}

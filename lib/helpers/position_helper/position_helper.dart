import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smartphone_app/helpers/position_helper/models/position_helper_classes.dart';
import 'package:geolocator_android/src/types/foreground_settings.dart';
import 'package:smartphone_app/localization/local_app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'mock_position_helper.dart';
import 'udp_position_helper.dart';

class PositionHelper {
  ///
  /// STATICS
  ///
  //region Statics

  static PositionHelper? _positionHelper;

  static PositionHelper _getPositionHelper(AppLocalizations appLocalizations) {
    if (_positionHelper != null) {
      return _positionHelper!;
    }

    PositionType pt = getPositionType();
    switch (pt) {
      case PositionType.mock:
        return MockPositionHelper();
      case PositionType.udp:
        return UdpPositionHelper();
      case PositionType.device:
        return PositionHelper(
            androidSettings: AndroidSettings(
                accuracy: LocationAccuracy.high,
                distanceFilter: 0,
                forceLocationManager: true,
                intervalDuration: const Duration(seconds: 10),
                //(Optional) Set foreground notification config to keep the app alive
                //when going to the background
                foregroundNotificationConfig: ForegroundNotificationConfig(
                  notificationIcon: const AndroidResource(
                      name: "notification_icon", defType: "drawable"),
                  notificationText:
                      appLocalizations.getting_location_in_background,
                  notificationTitle: appLocalizations.app_name,
                  enableWakeLock: true,
                )),
            appleSettings: AppleSettings(
              accuracy: LocationAccuracy.high,
              activityType: ActivityType.fitness,
              distanceFilter: 100,
              pauseLocationUpdatesAutomatically: true,
              // Only set to true if our app will be started up in the background.
              showBackgroundLocationIndicator: false,
            ));
    }
  }

  static PositionHelper getInstanceWithContext(
      {required BuildContext context}) {
    return _getPositionHelper(AppLocalizations.of(context)!);
  }

  static Future<PositionHelper> getInstance(
      AppLocalizations appLocalizations) async {
    return _getPositionHelper(
        (await LocalAppLocalizations.getAppLocalizations()));
  }

  static void setInstance(PositionHelper positionHelper) {
    _positionHelper = positionHelper;
  }

  //endregion

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

  void dispose() {}

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

  static PositionType getPositionType() {
    String envString = dotenv.env['WHICH_POSITION_HELPER'].toString();
    PositionType pt = PositionType.udp; //default

    if (envString == 'mock') {
      pt = PositionType.mock;
    } else if (envString == 'udp') {
      pt = PositionType.udp;
    } else if (envString == 'device') {
      pt = PositionType.device;
    }

    return pt;
  }

//endregion

}

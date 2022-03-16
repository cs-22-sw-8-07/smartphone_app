import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smartphone_app/helpers/position_helper/position_helper.dart';

import '../udp_helper.dart';
import 'models/position_helper_classes.dart';

class MockPositionHelper extends PositionHelper {
  ///
  /// VARIABLES
  ///
  //region Variables

  UdpHelper? _udpHelper;
  String? _ipAddress;
  StreamSubscription<String>? _streamSubscription;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  MockPositionHelper(
      {required AndroidSettings androidSettings,
      required AppleSettings appleSettings})
      : super(androidSettings: androidSettings, appleSettings: appleSettings);

  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  Position? parseUdpPacket(String udpPacket) {
    try {
      MockLatLng mockLatLng = MockLatLng.fromJson(jsonDecode(udpPacket));

      return Position(
          longitude: mockLatLng.longitude!,
          latitude: mockLatLng.latitude!,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0);
    } on Exception {
      return null;
    }
  }

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  void setupPositionStream() {
    _ipAddress = dotenv.env['MOCK_POSITION_SERVER_IP'].toString();
    _udpHelper = UdpHelper(ipAddress: _ipAddress!, inPort: 2201);
    _udpHelper!.start();

    _streamSubscription = _udpHelper!.onDataReceived.listen((str) {
      positionStreamController.add(parseUdpPacket(str));
    });
  }

  @override
  void dispose() {
    if (_streamSubscription != null) {
      _streamSubscription!.cancel();
    }
  }

//endregion
}

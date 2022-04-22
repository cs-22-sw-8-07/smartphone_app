// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smartphone_app/services/quack_location_service/service/quack_location_service.dart';
import 'package:smartphone_app/services/webservices/foursquare/services/foursquare_service.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';
import 'package:smartphone_app/services/webservices/quack/services/quack_service.dart';

import '../../mocks/foursquare_service.dart';
import '../../mocks/quack_service.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  Future<QuackLocationType?> mockLocation(double lat, double long) async {
    return QuackLocationService.getInstance().getQuackLocationType(Position(
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        latitude: lat,
        longitude: long,
        speed: 0.0,
        speedAccuracy: 0.0,
        timestamp: DateTime.now(),
        isMocked: true));
  }

  group("getQuackLocationType -> No places", () {
    setUp(() async {
      QuackLocationService.init(QuackLocationService());
      FoursquareService.init(MockFoursquareServiceNoPlaces());
      await mockLocation(57.73, 10.59);
    });

    test("Check initial with no places", () async {
      expect(QuackLocationService.getInstance().locationType,
          QuackLocationType.unknown);
    });
  });

  group("getQuackLocationType", () {
    setUp(() async {
      QuackLocationService.init(QuackLocationService());
      FoursquareService.init(MockFoursquareService());
      await mockLocation(57.73, 10.59);
    });

    test("Check initial", () async {
      expect(QuackLocationService.getInstance().locationType,
          QuackLocationType.urban);
    });

    test("Check location without moving", () async {
      QuackLocationType? newLoc = await mockLocation(57.73, 10.59);
      expect(newLoc, null);
    });

    test("Check location after moving within search perimeter", () async {
      QuackLocationType? newLoc = await mockLocation(57.7305, 10.5912);
      expect(newLoc, null);
    });

    test(
        "Check location after moving near Place with category correlating to QuackLocationType.beach",
        () async {
      QuackLocationType? newLoc =
          await mockLocation(57.731045604172294, 10.613407743501238);
      expect(newLoc, QuackLocationType.beach);
    });

    test("Check location after moving to edge of update radius", () async {
      QuackLocationType? newLoc = await mockLocation(57.7663, 10.6234);
      expect(newLoc, QuackLocationType.forest);
    });

    test("Check location after moving far outside update radius", () async {
      await mockLocation(57.73, 10.59);
      QuackLocationType? newLoc = await mockLocation(56.9951, 10.0234);
      expect(newLoc, QuackLocationType.beach);
    });

    test("Moving back into old update radius", () async {
      await mockLocation(57.73, 10.59);
      QuackLocationType? newLoc = await mockLocation(56.9951, 10.0234);
      expect(newLoc, QuackLocationType.beach);
      newLoc = await mockLocation(57.73, 10.59);
      expect(newLoc, QuackLocationType.urban);
      expect(
          QuackLocationService.getInstance().furthestDistancePerimeters.length,
          2);
    });
  });
}

// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/services/quack_location_service/helpers/quack_location_helper.dart';
import 'package:smartphone_app/services/webservices/foursquare/models/foursquare_classes.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  setUp(() async {});

  group("getQuackLocationType", () {
    test("Unknown category", () async {
      List<FoursquareCategory> categs = [
        FoursquareCategory(id: 11111, name: "Category from FSQ")
      ];
      FoursquarePlace qplace = FoursquarePlace(id: "1000", categories: categs);
      var result = QuackLocationHelper.getQuackLocationType(qplace);
      expect(result, QuackLocationType.unknown);
    });

    test("Night Life category", () async {
      List<FoursquareCategory> categs = [
        FoursquareCategory(id: 13010, name: "Category from FSQ")
      ];
      FoursquarePlace qplace = FoursquarePlace(id: "1001", categories: categs);
      var result = QuackLocationHelper.getQuackLocationType(qplace);
      expect(result, QuackLocationType.nightLife);
    });

    test("Church category", () async {
      List<FoursquareCategory> categs = [
        FoursquareCategory(id: 12099, name: "Category from FSQ")
      ];
      FoursquarePlace qplace = FoursquarePlace(id: "1002", categories: categs);
      var result = QuackLocationHelper.getQuackLocationType(qplace);
      expect(result, QuackLocationType.church);
    });

    test("Education category", () async {
      List<FoursquareCategory> categs = [
        FoursquareCategory(id: 12060, name: "Category from FSQ")
      ];
      FoursquarePlace qplace = FoursquarePlace(id: "1003", categories: categs);
      var result = QuackLocationHelper.getQuackLocationType(qplace);
      expect(result, QuackLocationType.education);
    });

    test("Cemetery category", () async {
      List<FoursquareCategory> categs = [
        FoursquareCategory(id: 12003, name: "Category from FSQ")
      ];
      FoursquarePlace qplace = FoursquarePlace(id: "1004", categories: categs);
      var result = QuackLocationHelper.getQuackLocationType(qplace);
      expect(result, QuackLocationType.cemetery);
    });

    test("Forest category", () async {
      List<FoursquareCategory> categs = [
        FoursquareCategory(id: 16032, name: "Category from FSQ")
      ];
      FoursquarePlace qplace = FoursquarePlace(id: "1005", categories: categs);
      var result = QuackLocationHelper.getQuackLocationType(qplace);
      expect(result, QuackLocationType.forest);
    });

    test("Beach category", () async {
      List<FoursquareCategory> categs = [
        FoursquareCategory(id: 16021, name: "Category from FSQ")
      ];
      FoursquarePlace qplace = FoursquarePlace(id: "1006", categories: categs);
      var result = QuackLocationHelper.getQuackLocationType(qplace);
      expect(result, QuackLocationType.beach);
    });

    test("Urban category", () async {
      List<FoursquareCategory> categs = [
        FoursquareCategory(id: 17025, name: "Category from FSQ")
      ];
      FoursquarePlace qplace = FoursquarePlace(id: "1007", categories: categs);
      var result = QuackLocationHelper.getQuackLocationType(qplace);
      expect(result, QuackLocationType.urban);
    });

    test("Multiple categories; 1st - Unknown, 2nd - Beach", () async {
      List<FoursquareCategory> categs = [
        FoursquareCategory(id: 9000, name: "Category from FSQ"),
        FoursquareCategory(id: 16023, name: "2nd Category from FSQ")
      ];
      FoursquarePlace qplace = FoursquarePlace(id: "1008", categories: categs);
      var result = QuackLocationHelper.getQuackLocationType(qplace);
      expect(result, QuackLocationType.beach);
    });
    test("Multiple categories; 1st - Urban, 2nd - Unknown", () async {
      List<FoursquareCategory> categs = [
        FoursquareCategory(id: 12070, name: "Category from FSQ"),
        FoursquareCategory(id: 20000, name: "2nd Category from FSQ")
      ];
      FoursquarePlace qplace = FoursquarePlace(id: "1009", categories: categs);
      var result = QuackLocationHelper.getQuackLocationType(qplace);
      expect(result, QuackLocationType.urban);
    });
    test("Multiple categories; 1st - Unknown, 2nd - Unknown", () async {
      List<FoursquareCategory> categs = [
        FoursquareCategory(id: 9000, name: "Category from FSQ"),
        FoursquareCategory(id: 0, name: "2nd Category from FSQ")
      ];
      FoursquarePlace qplace = FoursquarePlace(id: "1010", categories: categs);
      var result = QuackLocationHelper.getQuackLocationType(qplace);
      expect(result, QuackLocationType.unknown);
    });
  });
}

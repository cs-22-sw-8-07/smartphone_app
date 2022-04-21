// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/services/webservices/foursquare/models/foursquare_classes.dart';
import 'package:smartphone_app/services/webservices/foursquare/services/foursquare_service.dart';

import '../../mocks/foursquare_service.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
// arrange
  setUp(() async {
    FoursquareService.init(MockFoursquareService());
  });

  group("FourSquareService", () {
    test(
        "getNearbyPlaces -> Latitude: 0, Longitude: 0 -> Check correct deserialize",
        () async {
      var resp = await FoursquareService.getInstance()
          .getNearbyPlaces(latitude: 0, longitude: 0);

      var place = resp.foursquareResponse!.results![0];
      expect(resp.isSuccess, true);

      expect(place.id, "5d234a71fac612002379be33");
      expect(place.distance, 475);
      expect(place.location!.postcode, "9990");
      expect(place.name, "Kattegatt Meets Skagerrak");
      expect(place.geocodes!["main"]?.latitude, 57.743939);
      expect(place.geocodes!["main"]?.longitude, 10.648037);
      expect(place.location!.formattedAddress, "9990 Skagen");
    });
  });
}

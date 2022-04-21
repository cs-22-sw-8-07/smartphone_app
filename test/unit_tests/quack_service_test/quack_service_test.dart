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

  setUp(() async {
    QuackService.init(MockQuackService());
  });

  group("getPlaylist", () {
    test("QuackLocationType.beach -> Correct deserialize",
        () async {
      QuackServiceResponse<GetPlaylistResponse> response =
          await QuackService.getInstance().getPlaylist(QuackLocationType.beach);
      expect(response.quackResponse!.result!.id!, "1");
    });
    test("QuackLocationType.forest -> Correct deserialize",
        () async {
      QuackServiceResponse<GetPlaylistResponse> response =
          await QuackService.getInstance()
              .getPlaylist(QuackLocationType.forest);
      expect(response.quackResponse!.result!.id!, "2");
    });
  });
}

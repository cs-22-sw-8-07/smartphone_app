// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';
import 'package:smartphone_app/services/webservices/quack/services/quack_mock_service.dart';
import 'package:smartphone_app/services/webservices/quack/services/quack_service.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
// arrange
  setUp(() async {
    QuackService.init(MockQuackService());
  });

  group("getPlaylist", () {
    //tester på om beach får den rigtige playliste
    test("getPlaylist beach test", () async {
      QuackServiceResponse<GetPlaylistResponse> response =
          await QuackService.getInstance().getPlaylist(QuackLocationType.beach);
      expect(response.quackResponse!.result!.id!, "1");
    });
    //tester om alle andre locationer får den anden playliste. I dette tilfælde er det forest
    test("getPlaylist other test", () async {
      QuackServiceResponse<GetPlaylistResponse> response =
          await QuackService.getInstance()
              .getPlaylist(QuackLocationType.forest);
      expect(response.quackResponse!.result!.id!, "2");
    });
  });
}

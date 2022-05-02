import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';
import 'package:smartphone_app/services/webservices/quack/services/quack_service.dart';

import '../../mocks/quack_service.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  setUp(() async {
    QuackService.init(MockQuackService());
  });

  String? playlistsJson;

  group("getPlaylist", () {
    test("QuackLocationType.beach -> Correct deserialize", () async {
      QuackServiceResponse<GetPlaylistResponse> response =
          await QuackService.getInstance()
              .getPlaylist(qlt: QuackLocationType.beach, playlists: []);
      expect(response.quackResponse!.result!.id!, "1");
    });
    test("QuackLocationType.forest -> Correct deserialize", () async {
      QuackServiceResponse<GetPlaylistResponse> response =
          await QuackService.getInstance()
              .getPlaylist(qlt: QuackLocationType.forest, playlists: []);
      expect(response.quackResponse!.result!.id!, "2");
    });
  });

  group("getPreviousOffsets", () {
    setUp(() async {
      playlistsJson ??=
          (await rootBundle.loadString('assets/mock_data/playlists_mock.json'));
      SharedPreferences.setMockInitialValues(
          {AppValuesKey.playlists.toString(): playlistsJson!});
      var sharedPreferences = await SharedPreferences.getInstance();
      AppValuesHelper.getInstance().sharedPreferences = sharedPreferences;
    });

    test("QuackLocationType.forest -> Correct values", () async {
      var currentOffsets = getPreviousOffsets(
          playlists: AppValuesHelper.getInstance().getPlaylists(),
          quackLocationType: QuackLocationType.education);
      expect(currentOffsets, [2, 3, 9, 10, 11]);
    });
  });
}

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  group("AppValuesHelper", () {
    String? playlistsJson;

    group("saveBool and getBool", () {
      setUp(() async {
        SharedPreferences.setMockInitialValues({});
        var sharedPreferences = await SharedPreferences.getInstance();
        AppValuesHelper.getInstance().sharedPreferences = sharedPreferences;
      });

      test("Correct values", () async {
        // Act
        AppValuesHelper.getInstance().saveBool(AppValuesKey.displayName, false);

        // Assert
        expect(AppValuesHelper.getInstance().getBool(AppValuesKey.displayName),
            false);
      });
    });

    group("saveBool and getBool -> No shared preferences", () {
      test("Try catch", () async {
        // Assert
        expect(AppValuesHelper.getInstance().getBool(AppValuesKey.displayName),
            false);
      });
    });

    group("saveInteger and getInteger", () {
      setUp(() async {
        SharedPreferences.setMockInitialValues({});
        var sharedPreferences = await SharedPreferences.getInstance();
        AppValuesHelper.getInstance().sharedPreferences = sharedPreferences;
      });

      test("Check value -> 1234", () async {
        // Act
        AppValuesHelper.getInstance()
            .saveInteger(AppValuesKey.displayName, 1234);

        // Assert
        expect(
            AppValuesHelper.getInstance().getInteger(AppValuesKey.displayName),
            1234);
      });

      test("Check value -> null", () async {
        // Act
        AppValuesHelper.getInstance()
            .saveInteger(AppValuesKey.displayName, null);

        // Assert
        expect(
            AppValuesHelper.getInstance().getInteger(AppValuesKey.displayName),
            null);
      });
    });

    group("saveInteger and getInteger -> No shared preferences", () {
      test("Try catch", () async {
        // Assert
        expect(
            AppValuesHelper.getInstance().getInteger(AppValuesKey.displayName),
            null);
      });
    });

    group("savePlaylist", () {
      setUp(() async {
        SharedPreferences.setMockInitialValues({});
        var sharedPreferences = await SharedPreferences.getInstance();
        AppValuesHelper.getInstance().sharedPreferences = sharedPreferences;
      });

      test("No playlists saved currently", () async {
        // Arrange
        var playlist = QuackPlaylist(
            id: "1234",
            locationType: 3,
            tracks: [QuackTrack(id: "1"), QuackTrack(id: "2")],
            offset: 2);

        // Act
        AppValuesHelper.getInstance().savePlaylist(playlist);
        var playlists = AppValuesHelper.getInstance().getPlaylists();

        // Assert
        expect(playlists.length, 1);
        expect(playlists.first, playlist);
      });
    });

    group("savePlaylist", () {
      setUp(() async {
        playlistsJson ??= (await rootBundle
            .loadString('assets/mock_data/playlists_mock.json'));
        SharedPreferences.setMockInitialValues(
            {AppValuesKey.playlists.toString(): playlistsJson!});
        var sharedPreferences = await SharedPreferences.getInstance();
        AppValuesHelper.getInstance().sharedPreferences = sharedPreferences;
      });

      test("Playlists saved currently -> Updated playlist", () async {
        // Arrange
        var playlist = QuackPlaylist(
            id: "1234",
            locationType: 3,
            tracks: [QuackTrack(id: "1"), QuackTrack(id: "2")],
            offset: 2);

        // Act
        // Save one playlist
        AppValuesHelper.getInstance().savePlaylist(playlist);
        // Save new playlist
        AppValuesHelper.getInstance().savePlaylist(playlist);
        var playlists = AppValuesHelper.getInstance().getPlaylists();

        // Assert
        expect(playlists.length, 10);
        expect(playlists.first, playlist);
        expect(playlists[1], isNot(playlist));
      });

      test("Playlists saved currently -> Updated playlist 2", () async {
        // Arrange
        var playlist = QuackPlaylist(
            id: "34534534534",
            locationType: 3,
            tracks: [QuackTrack(id: "1"), QuackTrack(id: "2")],
            offset: 2);

        // Act
        // Save one playlist
        AppValuesHelper.getInstance().savePlaylist(playlist);
        var playlists = AppValuesHelper.getInstance().getPlaylists();

        // Assert
        expect(playlists.length, 10);
        expect(playlists.first, playlist);
        expect(playlists[1], isNot(playlist));
      });

      test("Playlists saved currently -> Two different playlist", () async {
        // Arrange
        var playlist = QuackPlaylist(
            id: "1",
            locationType: 3,
            tracks: [QuackTrack(id: "1"), QuackTrack(id: "2")],
            offset: 2);
        var playlist2 = QuackPlaylist(
            id: "2",
            locationType: 3,
            tracks: [QuackTrack(id: "1"), QuackTrack(id: "2")],
            offset: 2);

        // Act
        // Save one playlist
        AppValuesHelper.getInstance().savePlaylist(playlist);
        // Save new playlist
        AppValuesHelper.getInstance().savePlaylist(playlist2);
        var playlists = AppValuesHelper.getInstance().getPlaylists();

        // Assert
        expect(playlists.length, 10);
        expect(playlists.first, playlist2);
        expect(playlists[1], playlist);
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/pages/history/history_page_events_states.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';

void main() {
  group("HistoryPageEvent", () {
    group("ButtonPressed", () {
      test("Events are equal", () {
        expect(
          const ButtonPressed(buttonEvent: HistoryButtonEvent.back),
          const ButtonPressed(buttonEvent: HistoryButtonEvent.back),
        );
      });
      test("Events are not equal", () {
        expect(
          const ButtonPressed(buttonEvent: HistoryButtonEvent.back),
          isNot(const ButtonPressed(
              buttonEvent: HistoryButtonEvent.openWithSpotify)),
        );
      });
    });

    group("PlaylistSelected", () {
      test("Events are equal", () {
        QuackPlaylist testPlaylist =
            QuackPlaylist(id: "111", locationType: 5, tracks: const []);
        expect(
          PlaylistSelected(playlist: testPlaylist),
          PlaylistSelected(playlist: testPlaylist),
        );
      });
    });
  });
}

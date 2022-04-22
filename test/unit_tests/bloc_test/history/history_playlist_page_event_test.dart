import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/pages/history/history_playlist/history_playlist_page_events_states.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';
import 'package:smartphone_app/utilities/general_util.dart';

void main() {
  group("HistoryPageEvent", () {
    group("ButtonPressed", () {
      test("Events are equal", () {
        expect(
          const ButtonPressed(buttonEvent: HistoryPlaylistButtonEvent.back),
          const ButtonPressed(buttonEvent: HistoryPlaylistButtonEvent.back),
        );
      });
    });
  });
}

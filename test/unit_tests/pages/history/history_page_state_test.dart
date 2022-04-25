import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/pages/history/history_page_events_states.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';

void main() {
  List<QuackPlaylist>? testPlaylists = [
    QuackPlaylist(id: "111", locationType: 5, tracks: const [])
  ];

  group("HistoryState", () {
    test("States are equal", () {
      expect(HistoryPageState().copyWith(playlists: testPlaylists),
          HistoryPageState(playlists: testPlaylists));
    });
    test("States are not equal -> playlists", () {
      expect(HistoryPageState().copyWith(playlists: testPlaylists),
          isNot(HistoryPageState(playlists: const [])));
    });
  });
}

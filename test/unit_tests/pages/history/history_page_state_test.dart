import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/pages/history/history_page_events_states.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';
import 'package:smartphone_app/utilities/general_util.dart';

void main() {
  List<QuackPlaylist>? testPlaylists = [
    QuackPlaylist(id: "111", locationType: 5, tracks: const [])
  ];

  group("HistoryState", () {
    test("States are equal", () {
      expect(HistoryState().copyWith(playlists: testPlaylists),
          HistoryState(playlists: testPlaylists));
    });
    test("States are not equal -> playlists", () {
      expect(HistoryState().copyWith(playlists: testPlaylists),
          isNot(HistoryState(playlists: const [])));
    });
  });
}

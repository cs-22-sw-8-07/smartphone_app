import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/pages/history/history_playlist/history_playlist_page_events_states.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';
import 'package:smartphone_app/utilities/general_util.dart';

void main() {
  QuackPlaylist testPlaylist =
      QuackPlaylist(id: "111", locationType: 5, tracks: const []);

  group("HistoryState", () {
    test("States are equal", () {
      expect(HistoryPlaylistState().copyWith(playlist: testPlaylist),
          HistoryPlaylistState(playlist: testPlaylist));
    });
    test("States are not equal -> playlists", () {
      expect(HistoryPlaylistState().copyWith(playlist: testPlaylist),
          isNot(HistoryPlaylistState(playlist: QuackPlaylist())));
    });
  });
}

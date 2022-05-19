import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/pages/history_playlist/history_playlist_page_events_states.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';

void main() {
  QuackPlaylist testPlaylist =
      QuackPlaylist(id: "111", locationType: 5, tracks: const []);

  group("HistoryState", () {
    test("States are equal", () {
      expect(HistoryPlaylistPageState().copyWith(playlist: testPlaylist),
          HistoryPlaylistPageState(playlist: testPlaylist));
    });
    test("States are not equal -> playlists", () {
      expect(HistoryPlaylistPageState().copyWith(playlist: testPlaylist),
          isNot(HistoryPlaylistPageState(playlist: QuackPlaylist())));
    });
  });
}

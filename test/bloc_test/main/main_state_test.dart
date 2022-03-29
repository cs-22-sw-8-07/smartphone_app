import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/pages/main/main_page_events_states.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';
import 'package:spotify_sdk/models/player_state.dart';

void main() {
  group("MainPageState", () {
    test("Supports value comparisons", () {
      var track = QuackTrack(id: "1234");
      track.key = const Key("1234");

      var state = MainPageState();
      state = state.copyWith(
          currentTrack: track,
          isLoading: false,
          isRecommendationStarted: false,
          quackLocationType: QuackLocationType.cemetery,
          lockedQuackLocationType: QuackLocationType.beach,
          hasJustPerformedAction: true,
          isPlaylistShown: true,
          playerState: null,
          playlist:
              QuackPlaylist(id: "1234", locationType: 1, tracks: const []));
      expect(
          state,
          MainPageState(
              currentTrack: track,
              isLoading: false,
              isRecommendationStarted: false,
              quackLocationType: QuackLocationType.cemetery,
              lockedQuackLocationType: QuackLocationType.beach,
              hasJustPerformedAction: true,
              isPlaylistShown: true,
              playerState: null,
              playlist: QuackPlaylist(
                  id: "1234", locationType: 1, tracks: const [])));
    });
  });
}

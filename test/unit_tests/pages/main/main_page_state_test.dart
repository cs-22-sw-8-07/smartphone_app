import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/pages/main/main_page_events_states.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';

import '../../../mocks/spotify_service.dart';

void main() {
  group("MainPageState", () {
    test("States are equal", () {
      expect(
          MainPageState().copyWith(
              currentTrack: QuackTrack(id: "1234", key: const Key("1234")),
              isLoading: false,
              quackLocationType: QuackLocationType.cemetery,
              lockedQuackLocationType: QuackLocationType.beach,
              hasPerformedAction: true,
              isLocationListShown: true,
              isPlaylistShown: true,
              playerState: null,
              playlist:
                  QuackPlaylist(id: "1234", locationType: 1, tracks: const [])),
          MainPageState(
              currentTrack: QuackTrack(id: "1234", key: const Key("1234")),
              isLoading: false,
              quackLocationType: QuackLocationType.cemetery,
              lockedQuackLocationType: QuackLocationType.beach,
              hasPerformedAction: true,
              isLocationListShown: true,
              isPlaylistShown: true,
              playerState: null,
              playlist: QuackPlaylist(
                  id: "1234", locationType: 1, tracks: const [])));
    });
    test("States are not equal -> currentTrack", () {
      expect(
          MainPageState().copyWith(
              currentTrack: QuackTrack(id: "1234", key: const Key("1234"))),
          isNot(MainPageState(
              currentTrack: QuackTrack(id: "1234", key: const Key("123")))));
    });
    test("States are not equal -> isLoading", () {
      expect(MainPageState().copyWith(isLoading: true),
          isNot(MainPageState(isLoading: false)));
    });
    test("States are not equal -> isLocationListShown", () {
      expect(MainPageState().copyWith(isLocationListShown: true),
          isNot(MainPageState(isLocationListShown: false)));
    });
    test("States are not equal -> quackLocationType", () {
      expect(
          MainPageState().copyWith(quackLocationType: QuackLocationType.beach),
          isNot(MainPageState(quackLocationType: QuackLocationType.unknown)));
    });
    test("States are not equal -> lockedQuackLocationType", () {
      expect(
          MainPageState()
              .copyWith(lockedQuackLocationType: QuackLocationType.beach),
          isNot(MainPageState(
              lockedQuackLocationType: QuackLocationType.unknown)));
    });
    test("States are not equal -> hasJustPerformedAction", () {
      expect(MainPageState().copyWith(hasPerformedAction: true),
          isNot(MainPageState(hasPerformedAction: false)));
    });
    test("States are not equal -> isPlaylistShown", () {
      expect(MainPageState().copyWith(isPlaylistShown: true),
          isNot(MainPageState(isPlaylistShown: false)));
    });
    test("States are not equal -> playerState", () {
      expect(
          MainPageState().copyWith(playerState: null),
          isNot(MainPageState(
              playerState: MockSpotifyService.getMockPlayerState())));
    });
    test("States are not equal -> playlist", () {
      expect(
          MainPageState().copyWith(
              playlist:
                  QuackPlaylist(id: "123", locationType: 1, tracks: const [])),
          isNot(MainPageState(
              playlist: QuackPlaylist(
                  id: "1234", locationType: 1, tracks: const []))));
    });
  });
}

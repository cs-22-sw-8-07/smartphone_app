import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/pages/main/main_page_events_states.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';

import '../../../mocks/spotify_service.dart';

void main() {
  group("MainPageEvent", () {
    group("ButtonPressed", () {
      test("Events are equal", () {
        expect(
          const ButtonPressed(buttonEvent: MainButtonEvent.resumePausePlayer),
          const ButtonPressed(buttonEvent: MainButtonEvent.resumePausePlayer),
        );
      });
      test("Events are not equal", () {
        expect(
          const ButtonPressed(buttonEvent: MainButtonEvent.resumePausePlayer),
          isNot(const ButtonPressed(buttonEvent: MainButtonEvent.viewPlaylist)),
        );
      });
    });

    group("TouchEvent", () {
      test("Events are equal", () {
        expect(
          const TouchEvent(touchEvent: MainTouchEvent.goToNextTrack),
          const TouchEvent(touchEvent: MainTouchEvent.goToNextTrack),
        );
      });
      test("Events are not equal", () {
        expect(
          const TouchEvent(touchEvent: MainTouchEvent.goToNextTrack),
          isNot(const TouchEvent(touchEvent: MainTouchEvent.goToPreviousTrack)),
        );
      });
    });

    group("PlayerStateChanged", () {
      test("Events are equal", () {
        expect(
          const SpotifyPlayerStateChanged(playerState: null),
          const SpotifyPlayerStateChanged(playerState: null),
        );
      });
      test("Events are not equal", () {
        expect(
          SpotifyPlayerStateChanged(
              playerState: MockSpotifyService.getMockPlayerState(trackId: "1")),
          isNot(SpotifyPlayerStateChanged(
              playerState:
                  MockSpotifyService.getMockPlayerState(trackId: "2"))),
        );
      });
    });

    group("PlaylistReceived", () {
      test("Events are equal", () {
        expect(
          PlaylistReceived(
              playList:
                  QuackPlaylist(id: "1234", locationType: 1, tracks: const [])),
          PlaylistReceived(
              playList:
                  QuackPlaylist(id: "1234", locationType: 1, tracks: const [])),
        );
      });
      test("Events are not equal", () {
        expect(
          PlaylistReceived(
              playList:
                  QuackPlaylist(id: "12", locationType: 1, tracks: const [])),
          isNot(PlaylistReceived(
              playList: QuackPlaylist(
                  id: "1234", locationType: 1, tracks: const []))),
        );
      });
    });

    group("MainPageValueChanged", () {
      test("Events are equal", () {
        expect(
          const MainPageValueChanged(
              isLoading: false,
              quackLocationType: QuackLocationType.beach,
              currentTrack: null),
          const MainPageValueChanged(
              isLoading: false,
              quackLocationType: QuackLocationType.beach,
              currentTrack: null),
        );
      });
      test("Events are not equal -> isLoading", () {
        expect(
          const MainPageValueChanged(isLoading: true),
          isNot(const MainPageValueChanged(isLoading: false)),
        );
      });
      test("Events are not equal -> quackLocationType", () {
        expect(
          const MainPageValueChanged(
              quackLocationType: QuackLocationType.beach),
          isNot(const MainPageValueChanged(
              quackLocationType: QuackLocationType.unknown)),
        );
      });
      test("Events are not equal -> currentTrack", () {
        expect(
          const MainPageValueChanged(currentTrack: null),
          isNot(MainPageValueChanged(currentTrack: QuackTrack(id: "1"))),
        );
      });
    });

    group("LocationSelected", () {
      test("Events are equal", () {
        expect(
          const LocationSelected(quackLocationType: QuackLocationType.beach),
          const LocationSelected(quackLocationType: QuackLocationType.beach),
        );
      });
      test("Events are not equal", () {
        expect(
          const LocationSelected(quackLocationType: QuackLocationType.beach),
          isNot(const LocationSelected(
              quackLocationType: QuackLocationType.urban)),
        );
      });
    });

    group("TrackSelected", () {
      test("Events are equal", () {
        expect(
          TrackSelected(quackTrack: QuackTrack(id: "1")),
          TrackSelected(quackTrack: QuackTrack(id: "1")),
        );
      });
      test("Events are not equal", () {
        expect(
          TrackSelected(quackTrack: QuackTrack(id: "1")),
          isNot(TrackSelected(quackTrack: QuackTrack(id: "2"))),
        );
      });
    });
  });
}

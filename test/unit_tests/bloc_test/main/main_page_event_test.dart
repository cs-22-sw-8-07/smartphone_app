import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/pages/main/main_page_events_states.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';

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
          isNot(
              const ButtonPressed(buttonEvent: MainButtonEvent.resizePlaylist)),
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
          const SpotifyPlayerStateChanged(playerState: null),
          isNot(const TouchEvent(touchEvent: MainTouchEvent.goToPreviousTrack)),
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
              isRecommendationStarted: true,
              currentTrack: null),
          const MainPageValueChanged(
              isLoading: false,
              quackLocationType: QuackLocationType.beach,
              isRecommendationStarted: true,
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
      test("Events are not equal -> isRecommendationStarted", () {
        expect(
          const MainPageValueChanged(isRecommendationStarted: false),
          isNot(const MainPageValueChanged(isRecommendationStarted: true)),
        );
      });
      test("Events are not equal -> currentTrack", () {
        expect(
          const MainPageValueChanged(currentTrack: null),
          isNot(MainPageValueChanged(currentTrack: QuackTrack(id: "1"))),
        );
      });
    });

    group("HasPerformedSpotifyPlayerAction", () {
      test("Events are equal", () {
        expect(
          const HasPerformedSpotifyPlayerAction(),
          const HasPerformedSpotifyPlayerAction(),
        );
      });
      test("Events are not equal", () {
        expect(
          const HasPerformedSpotifyPlayerAction(),
          isNot(const MainPageValueChanged(currentTrack: null)),
        );
      });
    });
  });
}

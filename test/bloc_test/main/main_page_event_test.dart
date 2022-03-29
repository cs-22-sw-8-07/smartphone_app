import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/pages/main/main_page_events_states.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';

void main() {
  group("MainPageEvent", () {
    group("ButtonPressed", () {
      test("Supports value comparisons", () {
        expect(
          const ButtonPressed(buttonEvent: MainButtonEvent.resumePausePlayer),
          const ButtonPressed(buttonEvent: MainButtonEvent.resumePausePlayer),
        );
      });
    });

    group("TouchEvent", () {
      test("Supports value comparisons", () {
        expect(
          const TouchEvent(touchEvent: MainTouchEvent.goToNextTrack),
          const TouchEvent(touchEvent: MainTouchEvent.goToNextTrack),
        );
      });
    });

    group("PlayerStateChanged", () {
      test("Supports value comparisons", () {
        expect(
          const SpotifyPlayerStateChanged(playerState: null),
          const SpotifyPlayerStateChanged(playerState: null),
        );
      });
    });

    group("PlaylistReceived", () {
      test("Supports value comparisons", () {
        expect(
          PlaylistReceived(
              playList:
                  QuackPlaylist(id: "1234", locationType: 1, tracks: const [])),
          PlaylistReceived(
              playList:
                  QuackPlaylist(id: "1234", locationType: 1, tracks: const [])),
        );
      });
    });

    group("MainPageValueChanged", () {
      test("Supports value comparisons", () {
        expect(
          MainPageValueChanged(
              isLoading: false,
              quackLocationType: QuackLocationType.beach,
              isRecommendationStarted: true,
              currentTrack: null),
          MainPageValueChanged(
              isLoading: false,
              quackLocationType: QuackLocationType.beach,
              isRecommendationStarted: true,
              currentTrack: null),
        );
      });
    });

    group("HasPerformedSpotifyPlayerAction", () {
      test("Supports value comparisons", () {
        expect(
          const HasPerformedSpotifyPlayerAction(),
          const HasPerformedSpotifyPlayerAction(),
        );
      });
    });
  });
}

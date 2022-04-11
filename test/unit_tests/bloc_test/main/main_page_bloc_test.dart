import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/helpers/position_helper/mock_position_helper.dart';
import 'package:smartphone_app/pages/main/main_page_bloc.dart';
import 'package:smartphone_app/pages/main/main_page_events_states.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';
import 'package:smartphone_app/services/webservices/spotify/services/spotify_service.dart';

import '../../../mocks/build_context.dart';
import '../../../mocks/spotify_service.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  group("MainPage", () {
    late MainPageBloc bloc;

    setUp(() {
      SpotifyService.init(MockSpotifyService());
      bloc = MainPageBloc(
          context: MockBuildContext(), positionHelper: MockPositionHelper());
    });

    test("Initial state is correct", () {
      expect(
          bloc.state,
          MainPageState(
              hasJustPerformedAction: false,
              isPlaylistShown: false,
              isLoading: false,
              quackLocationType: QuackLocationType.unknown,
              isRecommendationStarted: false));
    });

    blocTest<MainPageBloc, MainPageState>("ButtonPressed -> Resize playlist",
        build: () => bloc,
        act: (bloc) => bloc.add(
            const ButtonPressed(buttonEvent: MainButtonEvent.viewPlaylist)),
        expect: () => [bloc.state.copyWith(isPlaylistShown: true)]);

    blocTest<MainPageBloc, MainPageState>("TouchEvent -> Go to next track",
        build: () => bloc,
        setUp: () {
          bloc.state.currentTrack = QuackTrack(id: "1");
          bloc.state.playlist = QuackPlaylist(
              id: "test",
              locationType: 1,
              tracks: [QuackTrack(id: "1"), QuackTrack(id: "2")]);
        },
        act: (bloc) => bloc
            .add(const TouchEvent(touchEvent: MainTouchEvent.goToNextTrack)),
        expect: () {
          return [
            bloc.state.copyWith(
                hasJustPerformedAction: true,
                currentTrack: QuackTrack(id: "1")),
            bloc.state.copyWith(
                hasJustPerformedAction: true, currentTrack: QuackTrack(id: "2"))
          ];
        });

    blocTest<MainPageBloc, MainPageState>("TouchEvent -> Go to previous track",
        build: () => bloc,
        setUp: () {
          bloc.state.currentTrack = QuackTrack(id: "2");
          bloc.state.playlist = QuackPlaylist(
              id: "test",
              locationType: 1,
              tracks: [QuackTrack(id: "1"), QuackTrack(id: "2")]);
        },
        act: (bloc) => bloc.add(
            const TouchEvent(touchEvent: MainTouchEvent.goToPreviousTrack)),
        expect: () {
          return [
            bloc.state.copyWith(
                hasJustPerformedAction: true,
                currentTrack: QuackTrack(id: "2")),
            bloc.state.copyWith(
                hasJustPerformedAction: true, currentTrack: QuackTrack(id: "1"))
          ];
        });

    blocTest<MainPageBloc, MainPageState>(
        "MainPageValueChanged -> All values changed",
        build: () => bloc,
        act: (bloc) => bloc.add(MainPageValueChanged(
            currentTrack: QuackTrack(id: "1"),
            isRecommendationStarted: true,
            quackLocationType: QuackLocationType.nightLife,
            isLoading: false)),
        expect: () {
          return [
            bloc.state.copyWith(
                currentTrack: QuackTrack(id: "1"),
                isRecommendationStarted: true,
                quackLocationType: QuackLocationType.nightLife,
                isLoading: false)
          ];
        });

    blocTest<MainPageBloc, MainPageState>(
        "MainPageValueChanged -> Booleans changed",
        build: () => bloc,
        act: (bloc) => bloc.add(MainPageValueChanged(
            isRecommendationStarted: true, isLoading: false)),
        expect: () {
          return [
            bloc.state.copyWith(isRecommendationStarted: true, isLoading: false)
          ];
        });

    var playerState = MockSpotifyService.getMockPlayerState();
    blocTest<MainPageBloc, MainPageState>("SpotifyPlayerStateChanged",
        build: () => bloc,
        act: (bloc) =>
            bloc.add(SpotifyPlayerStateChanged(playerState: playerState)),
        expect: () {
          return [bloc.state.copyWith(playerState: playerState)];
        });

    var playList = QuackPlaylist(
        id: "test",
        locationType: 1,
        tracks: [QuackTrack(id: "1"), QuackTrack(id: "2")]);
    blocTest<MainPageBloc, MainPageState>("PlaylistReceived",
        build: () => bloc,
        act: (bloc) => bloc.add(PlaylistReceived(playList: playList)),
        expect: () {
          return [bloc.state.copyWith(playlist: playList)];
        });

    blocTest<MainPageBloc, MainPageState>("TrackSelected",
        build: () => bloc,
        act: (bloc) => bloc.add(TrackSelected(quackTrack: QuackTrack(id: "1"))),
        expect: () {
          var firstState = bloc.state.copyWith(hasJustPerformedAction: true);
          firstState.currentTrack = null;
          return [
            firstState,
            bloc.state.copyWith(
                hasJustPerformedAction: true, currentTrack: QuackTrack(id: "1"))
          ];
        });

    blocTest<MainPageBloc, MainPageState>("HasPerformedAction",
        build: () => bloc,
        act: (bloc) => bloc.add(const HasPerformedSpotifyPlayerAction()),
        expect: () {
          return [bloc.state.copyWith(hasJustPerformedAction: true)];
        });
  });
}

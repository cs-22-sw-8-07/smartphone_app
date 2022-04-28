import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/helpers/position_helper/mock_position_helper.dart';
import 'package:smartphone_app/helpers/position_helper/position_helper.dart';
import 'package:smartphone_app/pages/main/main_page_bloc.dart';
import 'package:smartphone_app/pages/main/main_page_events_states.dart';
import 'package:smartphone_app/pages/main/main_page_ui.dart';
import 'package:smartphone_app/services/quack_location_service/service/quack_location_service.dart';
import 'package:smartphone_app/services/webservices/quack/interfaces/quack_functions.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';
import 'package:smartphone_app/services/webservices/quack/services/quack_service.dart';
import 'package:smartphone_app/services/webservices/spotify/services/spotify_service.dart';
import 'package:smartphone_app/widgets/question_dialog.dart';

import '../../../helpers/bloc_test_widget.dart';
import '../../../mocks/build_context.dart';
import '../../../mocks/quack_location_service.dart';
import '../../../mocks/quack_service.dart';
import '../../../mocks/question_dialog.dart';
import '../../../mocks/spotify_service.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  SpotifyService.init(MockSpotifyService());

  group("MainPage", () {
    late MainPageBloc bloc;
    late MainPage mainPage;
    PositionHelper? positionHelper;
    QuackPlaylist? playlistFromQuackService;
    IQuackFunctions? quackFunctions;

    setUp(() {
      GoogleFonts.config.allowRuntimeFetching = false;
      mainPage = MainPage();
      positionHelper = MockPositionHelper();
      PositionHelper.setInstance(positionHelper!);
      SharedPreferences.setMockInitialValues({});
      AppValuesHelper.getInstance().setup();
    });

    group("SpotifyService -> Return error", () {
      setUp(() {
        quackFunctions ??= MockQuackService();
        QuackService.init(quackFunctions!);
        SpotifyService.init(MockSpotifyServiceError());
        bloc = MainPageBloc(
            context: MockBuildContext(), positionHelper: MockPositionHelper());
      });

      blocTest<MainPageBloc, MainPageState>(
          "TrackSelected -> Spotify returns error",
          setUp: () {
            SpotifyService.init(MockSpotifyServiceError());
            bloc.state.playlist = QuackPlaylist(
                id: "1", tracks: [QuackTrack(id: "1"), QuackTrack(id: "2")]);
          },
          build: () => bloc,
          act: (bloc) =>
              bloc.add(TrackSelected(quackTrack: QuackTrack(id: "1"))),
          expect: () {
            var firstState = bloc.state.copyWith(hasJustPerformedAction: true);
            firstState.currentTrack = null;
            return [
              firstState,
              bloc.state.copyWith(
                  hasJustPerformedAction: true,
                  currentTrack: QuackTrack(id: "1"))
            ];
          });

      blocTest<MainPageBloc, MainPageState>(
          "ButtonPressed -> Resume/Pause player -> Player state is paused",
          setUp: () => bloc.state.playerState =
              MockSpotifyService.getMockPlayerState(isPaused: true),
          build: () => bloc,
          act: (bloc) => bloc.add(const ButtonPressed(
              buttonEvent: MainButtonEvent.resumePausePlayer)),
          expect: () {
            return [];
          });

      blocTest<MainPageBloc, MainPageState>(
          "ButtonPressed -> Resume/Pause player -> Player state is not paused",
          setUp: () =>
              bloc.state.playerState = MockSpotifyService.getMockPlayerState(),
          build: () => bloc,
          act: (bloc) => bloc.add(const ButtonPressed(
              buttonEvent: MainButtonEvent.resumePausePlayer)),
          expect: () {
            return [];
          });
    });

    group("QuackService -> Return success", () {
      setUp(() {
        quackFunctions ??= MockQuackService();
        QuackService.init(quackFunctions!);
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
                isLocationListShown: false,
                isLoading: false,
                quackLocationType: QuackLocationType.unknown));
      });

      blocTest<MainPageBloc, MainPageState>(
          "Subscribe to position -> Position is null",
          build: () => bloc,
          act: (bloc) async {
            if (positionHelper is MockPositionHelper) {
              (positionHelper as MockPositionHelper).setMockPosition(null);
            }
          },
          expect: () => []);

      blocTest<MainPageBloc, MainPageState>(
          "ButtonPressed -> Back -> isPlaylistShown is true",
          setUp: () => bloc.state.isPlaylistShown = true,
          build: () => bloc,
          act: (bloc) =>
              bloc.add(const ButtonPressed(buttonEvent: MainButtonEvent.back)),
          expect: () => [bloc.state.copyWith(isPlaylistShown: false)]);

      blocTest<MainPageBloc, MainPageState>(
          "ButtonPressed -> Back -> isPlaylistShown is false",
          setUp: () => bloc.state.isPlaylistShown = false,
          build: () => bloc,
          act: (bloc) =>
              bloc.add(const ButtonPressed(buttonEvent: MainButtonEvent.back)),
          expect: () => []);

      blocTest<MainPageBloc, MainPageState>(
          "PositionReceived method -> Position is null",
          build: () => bloc,
          act: (bloc) => bloc.positionReceived(null),
          expect: () => []);

      blocTestWidget<MainPage, MainPageBloc, MainPageState>(
          "PositionReceived method -> Position is not null",
          buildWidget: () => mainPage,
          setUp: () {
            var service = MockQuackLocationService();
            service.locationType = QuackLocationType.cemetery;
            QuackLocationService.init(service);
          },
          build: (w) => w.bloc,
          act: (bloc) => bloc.positionReceived(getMockPosition(0, 0)),
          expect: (bloc) => [
                bloc.state
                    .copyWith(quackLocationType: QuackLocationType.cemetery)
              ]);

      blocTestWidget<MainPage, MainPageBloc, MainPageState>(
          "PositionReceived method -> Position is not null and received QuackLocationType is 'Unknown'",
          buildWidget: () => mainPage,
          setUp: () {
            var service = MockQuackLocationService();
            service.locationType = QuackLocationType.unknown;
            QuackLocationService.init(service);
          },
          build: (w) {
            w.bloc.state.quackLocationType = QuackLocationType.nightLife;
            w.bloc.state.playlist = QuackPlaylist(id: "1", tracks: const []);
            w.bloc.state.playerState = MockSpotifyService.getMockPlayerState();
            return w.bloc;
          },
          act: (bloc) => bloc.positionReceived(getMockPosition(0, 0)),
          expect: (bloc) {
            var newState = bloc.state.copyWith(
                quackLocationType: QuackLocationType.nightLife,
                hasJustPerformedAction: false,
                playlist: QuackPlaylist(id: "1", tracks: const []));
            newState.playlist = null;

            return [
              newState,
              newState.copyWith(quackLocationType: QuackLocationType.unknown),
              newState.copyWith(
                  quackLocationType: QuackLocationType.unknown,
                  hasJustPerformedAction: true)
            ];
          });

      blocTestWidget<MainPage, MainPageBloc, MainPageState>(
          "PositionReceived method -> Position is not null -> Playlist is not null "
          "and the current QuackLocationType does not match the one from "
          "QuackLocationService",
          buildWidget: () => mainPage,
          setUp: () async {
            playlistFromQuackService = (await QuackService.getInstance()
                    .getPlaylist(qlt: QuackLocationType.beach, playlists: []))
                .quackResponse!
                .result;

            var service = MockQuackLocationService();
            service.locationType = QuackLocationType.cemetery;
            QuackLocationService.init(service);
          },
          build: (w) {
            w.bloc.state.playlist = QuackPlaylist(
                id: "1", tracks: [QuackTrack(id: "1"), QuackTrack(id: "2")]);
            w.bloc.state.quackLocationType = QuackLocationType.beach;
            w.bloc.state.lockedQuackLocationType = QuackLocationType.nightLife;
            return w.bloc;
          },
          act: (bloc) => bloc.positionReceived(getMockPosition(0, 0)),
          expect: (bloc) {
            return [
              bloc.state
                  .copyWith(quackLocationType: QuackLocationType.cemetery),
            ];
          });

      blocTestWidget<MainPage, MainPageBloc, MainPageState>(
          "PositionReceived method -> Position is not null -> Playlist is not null "
          "and the current QuackLocationType does not match the one from "
          "QuackLocationService and LockedQuackLocationType is null",
          buildWidget: () => mainPage,
          setUp: () async {
            playlistFromQuackService = (await QuackService.getInstance()
                    .getPlaylist(qlt: QuackLocationType.beach, playlists: []))
                .quackResponse!
                .result;

            var service = MockQuackLocationService();
            service.locationType = QuackLocationType.cemetery;
            QuackLocationService.init(service);
          },
          build: (w) {
            w.bloc.state.playlist = QuackPlaylist(
                id: "1", tracks: [QuackTrack(id: "1"), QuackTrack(id: "2")]);
            w.bloc.state.quackLocationType = QuackLocationType.beach;
            w.bloc.state.lockedQuackLocationType = null;
            return w.bloc;
          },
          act: (bloc) => bloc.positionReceived(getMockPosition(0, 0)),
          expect: (bloc) {
            var newState = bloc.state.copyWith(
                quackLocationType: QuackLocationType.cemetery,
                playlist: QuackPlaylist(
                    id: "1",
                    tracks: [QuackTrack(id: "1"), QuackTrack(id: "2")]));
            newState.updatedItemHashCode = null;

            return [
              newState,
              newState.copyWith(isLoading: true),
              newState.copyWith(
                  isLoading: true,
                  updatedItemHashCode: playlistFromQuackService.hashCode,
                  quackLocationType: QuackLocationType.cemetery,
                  playlist: playlistFromQuackService),
              newState.copyWith(
                  isLoading: false,
                  updatedItemHashCode: playlistFromQuackService.hashCode,
                  quackLocationType: QuackLocationType.cemetery,
                  playlist: playlistFromQuackService),
            ];
          });

      blocTest<MainPageBloc, MainPageState>(
          "ButtonPressed -> Select manual location",
          build: () => bloc,
          act: (bloc) => bloc.add(const ButtonPressed(
              buttonEvent: MainButtonEvent.selectManualLocation)),
          expect: () => [bloc.state.copyWith(isLocationListShown: true)]);

      blocTest<MainPageBloc, MainPageState>("ButtonPressed -> Resize playlist",
          build: () => bloc,
          act: (bloc) => bloc.add(
              const ButtonPressed(buttonEvent: MainButtonEvent.viewPlaylist)),
          expect: () => [bloc.state.copyWith(isPlaylistShown: true)]);

      blocTest<MainPageBloc, MainPageState>(
          "LocationSelected -> From forest to forest",
          build: () => bloc,
          setUp: () async {
            playlistFromQuackService = (await QuackService.getInstance()
                    .getPlaylist(
                        qlt: QuackLocationType.cemetery, playlists: []))
                .quackResponse!
                .result!;
            bloc.state.isLocationListShown = true;
            bloc.state.quackLocationType = QuackLocationType.forest;
          },
          act: (bloc) => bloc.add(const LocationSelected(
              quackLocationType: QuackLocationType.forest)),
          expect: () {
            return [
              bloc.state.copyWith(
                  isLocationListShown: false,
                  lockedQuackLocationType: QuackLocationType.forest)
            ];
          });

      blocTest<MainPageBloc, MainPageState>(
          "LocationSelected -> QuackLocationType in the event is null and QuackLocationType is 'Unknown'",
          build: () => bloc,
          setUp: () async {
            bloc.state.playerState = MockSpotifyService.getMockPlayerState();
            bloc.state.currentTrack = QuackTrack(id: "1");
            bloc.state.playlist = QuackPlaylist(id: "1", tracks: const []);
            bloc.state.quackLocationType = QuackLocationType.unknown;
            bloc.state.lockedQuackLocationType = QuackLocationType.beach;
          },
          act: (bloc) =>
              bloc.add(const LocationSelected(quackLocationType: null)),
          expect: () {
            var newState = bloc.state.copyWith(hasJustPerformedAction: false);
            newState.playlist = null;
            newState.currentTrack = null;
            newState.lockedQuackLocationType = null;

            return [
              newState,
              newState.copyWith(hasJustPerformedAction: true),
            ];
          });

      blocTest<MainPageBloc, MainPageState>(
          "LocationSelected -> QuackLocationType in the event is 'Beach' and "
          "LockedQuackLocationType is 'Beach'",
          build: () => bloc,
          setUp: () async {
            bloc.state.playerState = MockSpotifyService.getMockPlayerState();
            bloc.state.currentTrack = QuackTrack(id: "1");
            bloc.state.playlist = QuackPlaylist(id: "1", tracks: const []);
            bloc.state.quackLocationType = QuackLocationType.unknown;
            bloc.state.lockedQuackLocationType = QuackLocationType.beach;
          },
          act: (bloc) => bloc.add(const LocationSelected(
              quackLocationType: QuackLocationType.beach)),
          expect: () {
            return [
              bloc.state
                  .copyWith(lockedQuackLocationType: QuackLocationType.beach),
            ];
          });

      blocTest<MainPageBloc, MainPageState>(
          "LocationSelected -> QuackLocationType is 'Church' and "
          "LockedQuackLocationType is null -> From 'Church' to 'Cemetery'",
          build: () => bloc,
          setUp: () async {
            playlistFromQuackService = (await QuackService.getInstance()
                    .getPlaylist(
                        qlt: QuackLocationType.cemetery, playlists: []))
                .quackResponse!
                .result!;
            bloc.state.isLocationListShown = true;
            bloc.state.quackLocationType = QuackLocationType.church;
            bloc.state.currentTrack = QuackTrack(id: "2");
          },
          act: (bloc) => bloc.add(const LocationSelected(
              quackLocationType: QuackLocationType.cemetery)),
          expect: () {
            var newState = bloc.state.copyWith(
                lockedQuackLocationType: QuackLocationType.cemetery,
                isLocationListShown: false,
                hasJustPerformedAction: false,
                isLoading: false);
            newState.updatedItemHashCode = null;
            newState.playlist = null;

            return [
              newState.copyWith(currentTrack: QuackTrack(id: "2")),
              newState.copyWith(
                  isLoading: true, currentTrack: QuackTrack(id: "2")),
              newState.copyWith(
                  hasJustPerformedAction: true,
                  isLoading: true,
                  currentTrack: QuackTrack(id: "2")),
              newState.copyWith(
                  hasJustPerformedAction: true,
                  currentTrack: playlistFromQuackService!.tracks!.first,
                  isLoading: true),
              newState.copyWith(
                  hasJustPerformedAction: true,
                  currentTrack: playlistFromQuackService!.tracks!.first,
                  isLoading: true,
                  updatedItemHashCode: playlistFromQuackService.hashCode,
                  playlist: playlistFromQuackService),
              newState.copyWith(
                  hasJustPerformedAction: true,
                  currentTrack: playlistFromQuackService!.tracks!.first,
                  isLoading: false,
                  updatedItemHashCode: playlistFromQuackService.hashCode,
                  playlist: playlistFromQuackService),
            ];
          });

      blocTest<MainPageBloc, MainPageState>(
          "LocationSelected -> QuackLocationType is 'Forest' and "
          "LockedQuackLocationType is 'Education' -> From 'Education' to 'Cemetery'",
          build: () => bloc,
          setUp: () async {
            playlistFromQuackService = (await QuackService.getInstance()
                    .getPlaylist(
                        qlt: QuackLocationType.cemetery, playlists: []))
                .quackResponse!
                .result!;
            bloc.state.isLocationListShown = true;
            bloc.state.quackLocationType = QuackLocationType.forest;
            bloc.state.lockedQuackLocationType = QuackLocationType.education;
            bloc.state.currentTrack = QuackTrack(id: "2");
          },
          act: (bloc) => bloc.add(const LocationSelected(
              quackLocationType: QuackLocationType.cemetery)),
          expect: () {
            var newState = bloc.state.copyWith(
                lockedQuackLocationType: QuackLocationType.cemetery,
                isLocationListShown: false,
                hasJustPerformedAction: false,
                isLoading: false);
            newState.updatedItemHashCode = null;
            newState.playlist = null;

            return [
              newState.copyWith(currentTrack: QuackTrack(id: "2")),
              newState.copyWith(
                  isLoading: true, currentTrack: QuackTrack(id: "2")),
              newState.copyWith(
                  hasJustPerformedAction: true,
                  isLoading: true,
                  currentTrack: QuackTrack(id: "2")),
              newState.copyWith(
                  hasJustPerformedAction: true,
                  currentTrack: playlistFromQuackService!.tracks!.first,
                  isLoading: true),
              newState.copyWith(
                  hasJustPerformedAction: true,
                  currentTrack: playlistFromQuackService!.tracks!.first,
                  isLoading: true,
                  updatedItemHashCode: playlistFromQuackService.hashCode,
                  playlist: playlistFromQuackService),
              newState.copyWith(
                  hasJustPerformedAction: true,
                  currentTrack: playlistFromQuackService!.tracks!.first,
                  isLoading: false,
                  updatedItemHashCode: playlistFromQuackService.hashCode,
                  playlist: playlistFromQuackService),
            ];
          });

      blocTest<MainPageBloc, MainPageState>(
          "LocationSelected -> Set LockedQuackLocationType to null",
          build: () => bloc,
          setUp: () async {
            playlistFromQuackService = (await QuackService.getInstance()
                    .getPlaylist(
                        qlt: QuackLocationType.cemetery, playlists: []))
                .quackResponse!
                .result!;
            bloc.state.isLocationListShown = true;
            bloc.state.lockedQuackLocationType = QuackLocationType.church;
            bloc.state.quackLocationType = QuackLocationType.cemetery;
            bloc.state.currentTrack = QuackTrack(id: "2");
          },
          act: (bloc) =>
              bloc.add(const LocationSelected(quackLocationType: null)),
          expect: () {
            var newState = bloc.state.copyWith(
                isLocationListShown: false,
                quackLocationType: QuackLocationType.cemetery,
                hasJustPerformedAction: false,
                isLoading: false);
            newState.lockedQuackLocationType = null;
            newState.updatedItemHashCode = null;
            newState.playlist = null;

            return [
              newState.copyWith(currentTrack: QuackTrack(id: "2")),
              newState.copyWith(
                  isLoading: true, currentTrack: QuackTrack(id: "2")),
              newState.copyWith(
                  hasJustPerformedAction: true,
                  isLoading: true,
                  currentTrack: QuackTrack(id: "2")),
              newState.copyWith(
                  hasJustPerformedAction: true,
                  currentTrack: playlistFromQuackService!.tracks!.first,
                  isLoading: true),
              newState.copyWith(
                  hasJustPerformedAction: true,
                  currentTrack: playlistFromQuackService!.tracks!.first,
                  isLoading: true,
                  updatedItemHashCode: playlistFromQuackService.hashCode,
                  playlist: playlistFromQuackService),
              newState.copyWith(
                  hasJustPerformedAction: true,
                  currentTrack: playlistFromQuackService!.tracks!.first,
                  isLoading: false,
                  updatedItemHashCode: playlistFromQuackService.hashCode,
                  playlist: playlistFromQuackService),
            ];
          });

      blocTest<MainPageBloc, MainPageState>("TouchEvent -> Go to next track",
          build: () => bloc,
          setUp: () {
            bloc.state.currentTrack = QuackTrack(id: "1");
            bloc.state.playlist = QuackPlaylist(
                id: "test",
                locationType: 1,
                tracks: [
                  QuackTrack(id: "1"),
                  QuackTrack(id: "2"),
                  QuackTrack(id: "3")
                ]);
          },
          act: (bloc) => bloc
              .add(const TouchEvent(touchEvent: MainTouchEvent.goToNextTrack)),
          expect: () {
            return [
              bloc.state.copyWith(
                  hasJustPerformedAction: true,
                  currentTrack: QuackTrack(id: "1")),
              bloc.state.copyWith(
                  hasJustPerformedAction: true,
                  currentTrack: QuackTrack(id: "2"))
            ];
          });

      blocTest<MainPageBloc, MainPageState>(
          "TouchEvent -> Go to next track -> Current track not in playlist",
          build: () => bloc,
          setUp: () {
            bloc.state.currentTrack = QuackTrack(id: "4");
            bloc.state.playlist = QuackPlaylist(
                id: "test",
                locationType: 1,
                tracks: [
                  QuackTrack(id: "1"),
                  QuackTrack(id: "2"),
                  QuackTrack(id: "3")
                ]);
          },
          act: (bloc) => bloc
              .add(const TouchEvent(touchEvent: MainTouchEvent.goToNextTrack)),
          expect: () {
            return [];
          });

      blocTest<MainPageBloc, MainPageState>(
          "TouchEvent -> Go to next track -> Current track is the last track in the playlist",
          build: () => bloc,
          setUp: () {
            bloc.state.currentTrack = QuackTrack(id: "3");
            bloc.state.playlist = QuackPlaylist(
                id: "test",
                locationType: 1,
                tracks: [
                  QuackTrack(id: "1"),
                  QuackTrack(id: "2"),
                  QuackTrack(id: "3")
                ]);
          },
          act: (bloc) => bloc
              .add(const TouchEvent(touchEvent: MainTouchEvent.goToNextTrack)),
          expect: () {
            return [];
          });

      blocTest<MainPageBloc, MainPageState>(
          "TouchEvent -> Go to next track -> Last track so also append to existing playlist",
          build: () => bloc,
          setUp: () async {
            playlistFromQuackService = (await QuackService.getInstance()
                    .getPlaylist(qlt: QuackLocationType.beach, playlists: []))
                .quackResponse!
                .result!;
            bloc.state.quackLocationType = QuackLocationType.beach;
            bloc.state.currentTrack = QuackTrack(id: "1");
            bloc.state.playlist = QuackPlaylist(
                id: "test", tracks: [QuackTrack(id: "1"), QuackTrack(id: "2")]);
          },
          act: (bloc) => bloc
              .add(const TouchEvent(touchEvent: MainTouchEvent.goToNextTrack)),
          expect: () {
            var newState = bloc.state.copyWith(
                hasJustPerformedAction: true,
                isLoading: false,
                playlist: QuackPlaylist(
                    id: "test",
                    tracks: [QuackTrack(id: "1"), QuackTrack(id: "2")]));
            newState.updatedItemHashCode = null;

            var tempExpandedPlaylist = QuackPlaylist(
                id: "test", tracks: [QuackTrack(id: "1"), QuackTrack(id: "2")]);
            tempExpandedPlaylist.tracks!
                .addAll(playlistFromQuackService!.tracks!);

            return [
              newState.copyWith(currentTrack: QuackTrack(id: "1")),
              newState.copyWith(currentTrack: QuackTrack(id: "2")),
              newState.copyWith(
                  currentTrack: QuackTrack(id: "2"), isLoading: true),
              newState.copyWith(
                  currentTrack: QuackTrack(id: "2"),
                  isLoading: true,
                  updatedItemHashCode: tempExpandedPlaylist.hashCode,
                  playlist: tempExpandedPlaylist),
              newState.copyWith(
                  currentTrack: QuackTrack(id: "2"),
                  isLoading: false,
                  updatedItemHashCode: tempExpandedPlaylist.hashCode,
                  playlist: tempExpandedPlaylist),
            ];
          });

      blocTest<MainPageBloc, MainPageState>(
          "TouchEvent -> Go to previous track",
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
                  hasJustPerformedAction: true,
                  currentTrack: QuackTrack(id: "1"))
            ];
          });

      blocTest<MainPageBloc, MainPageState>(
          "TouchEvent -> Go to previous track -> Current track is the first track in the playlist",
          build: () => bloc,
          setUp: () {
            bloc.state.currentTrack = QuackTrack(id: "1");
            bloc.state.playlist = QuackPlaylist(
                id: "test",
                locationType: 1,
                tracks: [QuackTrack(id: "1"), QuackTrack(id: "2")]);
          },
          act: (bloc) => bloc.add(
              const TouchEvent(touchEvent: MainTouchEvent.goToPreviousTrack)),
          expect: () {
            return [
              bloc.state.copyWith(hasJustPerformedAction: true),
            ];
          });

      blocTest<MainPageBloc, MainPageState>(
          "MainPageValueChanged -> All values changed",
          build: () => bloc,
          act: (bloc) => bloc.add(MainPageValueChanged(
              currentTrack: QuackTrack(id: "1"),
              quackLocationType: QuackLocationType.nightLife,
              isLoading: false)),
          expect: () {
            return [
              bloc.state.copyWith(
                  currentTrack: QuackTrack(id: "1"),
                  quackLocationType: QuackLocationType.nightLife,
                  isLoading: false)
            ];
          });

      blocTest<MainPageBloc, MainPageState>(
          "MainPageValueChanged -> IsLoading changed",
          build: () => bloc,
          act: (bloc) => bloc.add(const MainPageValueChanged(isLoading: false)),
          expect: () {
            return [bloc.state.copyWith(isLoading: false)];
          });

      blocTest<MainPageBloc, MainPageState>(
          "MainPageValueChanged -> QuackLocationType changed",
          build: () => bloc,
          act: (bloc) => bloc.add(const MainPageValueChanged(
              quackLocationType: QuackLocationType.beach)),
          expect: () {
            return [
              bloc.state.copyWith(quackLocationType: QuackLocationType.beach)
            ];
          });

      blocTest<MainPageBloc, MainPageState>(
          "MainPageValueChanged -> CurrentTrack changed",
          build: () => bloc,
          act: (bloc) =>
              bloc.add(MainPageValueChanged(currentTrack: QuackTrack(id: "1"))),
          expect: () {
            return [bloc.state.copyWith(currentTrack: QuackTrack(id: "1"))];
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
          setUp: () => bloc.state.playlist = QuackPlaylist(
              id: "1", tracks: [QuackTrack(id: "1"), QuackTrack(id: "2")]),
          build: () => bloc,
          act: (bloc) =>
              bloc.add(TrackSelected(quackTrack: QuackTrack(id: "1"))),
          expect: () {
            var firstState = bloc.state.copyWith(hasJustPerformedAction: true);
            firstState.currentTrack = null;
            return [
              firstState,
              bloc.state.copyWith(
                  hasJustPerformedAction: true,
                  currentTrack: QuackTrack(id: "1"))
            ];
          });

      var trackSelectedPlaylist = QuackPlaylist(
          id: "1", tracks: [QuackTrack(id: "1"), QuackTrack(id: "2")]);
      QuackPlaylist? trackSelectedQuackPlaylist;
      blocTest<MainPageBloc, MainPageState>(
          "TrackSelected -> Append to existing playlist",
          setUp: () async {
            trackSelectedQuackPlaylist = (await QuackService.getInstance()
                    .getPlaylist(qlt: QuackLocationType.beach, playlists: []))
                .quackResponse!
                .result!;
            bloc.state.quackLocationType = QuackLocationType.beach;
            bloc.state.playlist = trackSelectedPlaylist;
          },
          build: () => bloc,
          act: (bloc) =>
              bloc.add(TrackSelected(quackTrack: QuackTrack(id: "2"))),
          expect: () {
            var newState = bloc.state.copyWith(
                isLoading: false,
                hasJustPerformedAction: true,
                playlist: QuackPlaylist(
                    id: "1",
                    tracks: [QuackTrack(id: "1"), QuackTrack(id: "2")]));
            newState.currentTrack = null;
            newState.updatedItemHashCode = null;

            var tempPlaylist = QuackPlaylist(
                id: "1", tracks: [QuackTrack(id: "1"), QuackTrack(id: "2")]);
            tempPlaylist.tracks!.addAll(trackSelectedQuackPlaylist!.tracks!);
            var hashCode = tempPlaylist.hashCode;

            return [
              newState,
              newState.copyWith(currentTrack: QuackTrack(id: "2")),
              newState.copyWith(
                  currentTrack: QuackTrack(id: "2"), isLoading: true),
              newState.copyWith(
                  currentTrack: QuackTrack(id: "2"),
                  isLoading: true,
                  updatedItemHashCode: hashCode,
                  playlist: tempPlaylist),
              newState.copyWith(
                  currentTrack: QuackTrack(id: "2"),
                  isLoading: false,
                  updatedItemHashCode: hashCode,
                  playlist: tempPlaylist),
            ];
          });

      blocTestWidget<MainPage, MainPageBloc, MainPageState>(
          "ButtonPressed -> Refresh playlist -> Picked yes",
          setUp: () async {
            playlistFromQuackService = (await QuackService.getInstance()
                    .getPlaylist(qlt: QuackLocationType.beach, playlists: []))
                .quackResponse!
                .result;
            QuestionDialog.setInstance(MockQuestionDialogYes());
          },
          buildWidget: () => mainPage,
          build: (w) async {
            w.bloc.state.playerState =
                MockSpotifyService.getMockPlayerState(isPaused: false);
            w.bloc.state.quackLocationType = QuackLocationType.beach;
            return w.bloc;
          },
          act: (bloc) => bloc.add(const ButtonPressed(
              buttonEvent: MainButtonEvent.refreshPlaylist)),
          expect: (bloc) async {
            var newState = bloc.state.copyWith(hasJustPerformedAction: false);
            newState.currentTrack = null;
            newState.playlist = null;
            newState.updatedItemHashCode = null;

            return [
              newState.copyWith(isLoading: true),
              newState.copyWith(isLoading: true, hasJustPerformedAction: true),
              newState.copyWith(
                  isLoading: true,
                  hasJustPerformedAction: true,
                  currentTrack: playlistFromQuackService!.tracks!.first),
              newState.copyWith(
                  playlist: playlistFromQuackService,
                  isLoading: true,
                  hasJustPerformedAction: true,
                  updatedItemHashCode: playlistFromQuackService.hashCode,
                  currentTrack: playlistFromQuackService!.tracks!.first),
              newState.copyWith(
                  playlist: playlistFromQuackService,
                  isLoading: false,
                  updatedItemHashCode: playlistFromQuackService.hashCode,
                  hasJustPerformedAction: true,
                  currentTrack: playlistFromQuackService!.tracks!.first)
            ];
          });

      blocTestWidget<MainPage, MainPageBloc, MainPageState>(
          "ButtonPressed -> Refresh playlist -> Picked yes and player is not paused",
          setUp: () async {
            playlistFromQuackService = (await QuackService.getInstance()
                    .getPlaylist(qlt: QuackLocationType.beach, playlists: []))
                .quackResponse!
                .result;
            QuestionDialog.setInstance(MockQuestionDialogYes());
          },
          buildWidget: () => mainPage,
          build: (w) async {
            w.bloc.state.playerState =
                MockSpotifyService.getMockPlayerState(isPaused: false);
            w.bloc.state.quackLocationType = QuackLocationType.beach;
            return w.bloc;
          },
          act: (bloc) => bloc.add(const ButtonPressed(
              buttonEvent: MainButtonEvent.refreshPlaylist)),
          expect: (bloc) async {
            var newState = bloc.state.copyWith(hasJustPerformedAction: false);
            newState.currentTrack = null;
            newState.playlist = null;
            newState.updatedItemHashCode = null;

            return [
              newState.copyWith(isLoading: true),
              newState.copyWith(isLoading: true, hasJustPerformedAction: true),
              newState.copyWith(
                  isLoading: true,
                  hasJustPerformedAction: true,
                  currentTrack: playlistFromQuackService!.tracks!.first),
              newState.copyWith(
                  playlist: playlistFromQuackService,
                  isLoading: true,
                  hasJustPerformedAction: true,
                  updatedItemHashCode: playlistFromQuackService.hashCode,
                  currentTrack: playlistFromQuackService!.tracks!.first),
              newState.copyWith(
                  playlist: playlistFromQuackService,
                  isLoading: false,
                  updatedItemHashCode: playlistFromQuackService.hashCode,
                  hasJustPerformedAction: true,
                  currentTrack: playlistFromQuackService!.tracks!.first)
            ];
          });

      blocTestWidget<MainPage, MainPageBloc, MainPageState>(
          "ButtonPressed -> Refresh playlist -> Picked no",
          setUp: () async {
            QuestionDialog.setInstance(MockQuestionDialogNo());
          },
          buildWidget: () => mainPage,
          build: (w) => w.bloc,
          act: (bloc) => bloc.add(const ButtonPressed(
              buttonEvent: MainButtonEvent.refreshPlaylist)),
          expect: (bloc) => []);

      blocTest<MainPageBloc, MainPageState>("HasPerformedSpotifyPlayerAction",
          build: () => bloc,
          act: (bloc) => bloc.add(const HasPerformedSpotifyPlayerAction()),
          expect: () {
            return [bloc.state.copyWith(hasJustPerformedAction: true)];
          });

      QuackPlaylist? notExpandedPlaylist;
      QuackPlaylist? expandedPlaylist;
      blocTestWidget<MainPage, MainPageBloc, MainPageState>(
          "ButtonPressed -> Append to playlist",
          setUp: () async {
            expandedPlaylist =
                QuackPlaylist(tracks: List.of([], growable: true));
            var playlistFromQuackAppend = (await QuackService.getInstance()
                    .getPlaylist(qlt: QuackLocationType.beach, playlists: []))
                .quackResponse!
                .result;

            expandedPlaylist!.id = playlistFromQuackAppend!.id;
            expandedPlaylist!.locationType =
                playlistFromQuackAppend.locationType;
            expandedPlaylist!.tracks!.addAll(playlistFromQuackAppend.tracks!);
            expandedPlaylist!.tracks!.addAll(playlistFromQuackAppend.tracks!);

            notExpandedPlaylist = expandedPlaylist!.copy();
            notExpandedPlaylist!.tracks =
                notExpandedPlaylist!.tracks!.take(10).toList(growable: true);
          },
          buildWidget: () => MainPage(),
          build: (w) async {
            w.bloc.state.playlist = notExpandedPlaylist;
            w.bloc.state.quackLocationType = QuackLocationType.beach;
            return w.bloc;
          },
          act: (bloc) => bloc.add(const ButtonPressed(
              buttonEvent: MainButtonEvent.appendToPlaylist)),
          expect: (bloc) {
            var newState = bloc.state
                .copyWith(playlist: notExpandedPlaylist, isLoading: true);
            newState.updatedItemHashCode = null;

            return [
              newState,
              newState.copyWith(
                  playlist: expandedPlaylist,
                  updatedItemHashCode: expandedPlaylist.hashCode),
              newState.copyWith(
                  playlist: expandedPlaylist,
                  isLoading: false,
                  updatedItemHashCode: expandedPlaylist.hashCode)
            ];
          });

      blocTest<MainPageBloc, MainPageState>(
          "ButtonPressed -> Start/Stop recommendation -> Playlist is null",
          setUp: () async {
            playlistFromQuackService = (await QuackService.getInstance()
                    .getPlaylist(qlt: QuackLocationType.beach, playlists: []))
                .quackResponse!
                .result;
            bloc.state.quackLocationType = QuackLocationType.beach;
          },
          build: () => bloc,
          act: (bloc) => bloc.add(const ButtonPressed(
              buttonEvent: MainButtonEvent.startStopRecommendation)),
          expect: () {
            var newState = bloc.state
                .copyWith(isLoading: true, hasJustPerformedAction: false);
            newState.currentTrack = null;
            newState.playlist = null;
            newState.updatedItemHashCode = null;

            return [
              newState,
              newState.copyWith(hasJustPerformedAction: true),
              newState.copyWith(
                  hasJustPerformedAction: true,
                  currentTrack: bloc.state.playlist!.tracks!.first),
              newState.copyWith(
                  hasJustPerformedAction: true,
                  currentTrack: bloc.state.playlist!.tracks!.first,
                  updatedItemHashCode: playlistFromQuackService.hashCode,
                  playlist: playlistFromQuackService),
              newState.copyWith(
                  isLoading: false,
                  hasJustPerformedAction: true,
                  currentTrack: bloc.state.playlist!.tracks!.first,
                  updatedItemHashCode: playlistFromQuackService.hashCode,
                  playlist: playlistFromQuackService),
            ];
          });

      blocTest<MainPageBloc, MainPageState>(
          "ButtonPressed -> Start/Stop recommendation -> Playlist is not null",
          setUp: () => bloc.state.playlist = QuackPlaylist(
              id: "1", tracks: [QuackTrack(id: "1"), QuackTrack(id: "2")]),
          build: () => bloc,
          act: (bloc) => bloc.add(const ButtonPressed(
              buttonEvent: MainButtonEvent.startStopRecommendation)),
          expect: () {
            return [];
          });

      blocTestWidget<MainPage, MainPageBloc, MainPageState>(
          "ButtonPressed -> Start/Stop recommendation -> Playlist is null and QuackLocationType is 'Unknown'",
          buildWidget: () => mainPage,
          setUp: () {
            bloc.state.playlist = null;
            bloc.state.quackLocationType = QuackLocationType.unknown;
          },
          build: (w) => w.bloc,
          act: (bloc) => bloc.add(const ButtonPressed(
              buttonEvent: MainButtonEvent.startStopRecommendation)),
          expect: (bloc) {
            return [];
          });

      blocTest<MainPageBloc, MainPageState>(
          "ButtonPressed -> Resume/Pause player",
          setUp: () =>
              bloc.state.playerState = MockSpotifyService.getMockPlayerState(),
          build: () => bloc,
          act: (bloc) => bloc.add(const ButtonPressed(
              buttonEvent: MainButtonEvent.resumePausePlayer)),
          expect: () {
            return [bloc.state.copyWith(hasJustPerformedAction: true)];
          });

      blocTest<MainPageBloc, MainPageState>("ButtonPressed -> Log out",
          setUp: () async {
            SharedPreferences.setMockInitialValues({});
            var sharedPreferences = await SharedPreferences.getInstance();
            AppValuesHelper.getInstance().sharedPreferences = sharedPreferences;
            AppValuesHelper.getInstance()
                .saveString(AppValuesKey.accessToken, "1234");
          },
          build: () => bloc,
          act: (bloc) => bloc
              .add(const ButtonPressed(buttonEvent: MainButtonEvent.logOut)),
          expect: () {
            expect(
                AppValuesHelper.getInstance()
                    .getString(AppValuesKey.accessToken),
                "");
            return [];
          });

      blocTestWidget<MainPage, MainPageBloc, MainPageState>(
          "ButtonPressed -> Lock/Unlock QuackLocationType -> LockedQuackLocationType is null",
          buildWidget: () => mainPage,
          build: (w) {
            w.bloc.state.quackLocationType = QuackLocationType.nightLife;
            return w.bloc;
          },
          act: (bloc) => bloc.add(const ButtonPressed(
              buttonEvent: MainButtonEvent.lockUnlockQuackLocationType)),
          expect: (bloc) {
            return [
              bloc.state
                  .copyWith(quackLocationType: QuackLocationType.nightLife)
            ];
          });

      blocTestWidget<MainPage, MainPageBloc, MainPageState>(
          "ButtonPressed -> Lock/Unlock QuackLocationType -> LockedQuackLocationType is null and QuackLocationType is 'Unknown'",
          buildWidget: () => mainPage,
          build: (w) {
            w.bloc.state.quackLocationType = QuackLocationType.unknown;
            return w.bloc;
          },
          act: (bloc) => bloc.add(const ButtonPressed(
              buttonEvent: MainButtonEvent.lockUnlockQuackLocationType)),
          expect: (bloc) {
            return [];
          });

      blocTestWidget<MainPage, MainPageBloc, MainPageState>(
          "ButtonPressed -> Lock/Unlock QuackLocationType -> LockedQuackLocationType is not null",
          buildWidget: () => mainPage,
          build: (w) async {
            playlistFromQuackService = (await QuackService.getInstance()
                    .getPlaylist(qlt: QuackLocationType.beach, playlists: []))
                .quackResponse!
                .result;

            w.bloc.state.quackLocationType = QuackLocationType.beach;
            w.bloc.state.lockedQuackLocationType = QuackLocationType.cemetery;
            return w.bloc;
          },
          act: (bloc) => bloc.add(const ButtonPressed(
              buttonEvent: MainButtonEvent.lockUnlockQuackLocationType)),
          expect: (bloc) {
            var newState = bloc.state
                .copyWith(isLoading: false, hasJustPerformedAction: false);
            newState.currentTrack = null;
            newState.playlist = null;
            newState.updatedItemHashCode = null;
            newState.lockedQuackLocationType = null;
            return [
              newState,
              newState.copyWith(isLoading: true),
              newState.copyWith(isLoading: true, hasJustPerformedAction: true),
              newState.copyWith(
                  isLoading: true,
                  hasJustPerformedAction: true,
                  currentTrack: playlistFromQuackService!.tracks!.first),
              newState.copyWith(
                  isLoading: true,
                  hasJustPerformedAction: true,
                  currentTrack: playlistFromQuackService!.tracks!.first,
                  playlist: playlistFromQuackService,
                  updatedItemHashCode: playlistFromQuackService.hashCode),
              newState.copyWith(
                  isLoading: false,
                  hasJustPerformedAction: true,
                  currentTrack: playlistFromQuackService!.tracks!.first,
                  playlist: playlistFromQuackService,
                  updatedItemHashCode: playlistFromQuackService.hashCode)
            ];
          });

      var playerState1 = MockSpotifyService.getMockPlayerState(trackId: "1");
      var playerState2 = MockSpotifyService.getMockPlayerState(trackId: "2");
      var playerState3 = MockSpotifyService.getMockPlayerState(useTrack: false);
      blocTest<MainPageBloc, MainPageState>(
          "SpotifyPlayerStateChanged -> HasJustPerformedAction is set",
          setUp: () {
            bloc.state.playerState = playerState1;
            bloc.state.hasJustPerformedAction = true;
          },
          build: () => bloc,
          act: (bloc) =>
              bloc.add(SpotifyPlayerStateChanged(playerState: playerState1)),
          expect: () {
            return [
              bloc.state.copyWith(
                  playerState: playerState1, hasJustPerformedAction: false)
            ];
          });

      blocTest<MainPageBloc, MainPageState>(
          "SpotifyPlayerStateChanged -> Player state in event is null",
          setUp: () {
            bloc.state.playerState = playerState1;
          },
          build: () => bloc,
          act: (bloc) =>
              bloc.add(const SpotifyPlayerStateChanged(playerState: null)),
          expect: () {
            var newState = bloc.state.copyWith();
            newState.playerState = null;
            return [newState];
          });

      blocTest<MainPageBloc, MainPageState>(
          "SpotifyPlayerStateChanged ->  Current player state is null",
          build: () => bloc,
          act: (bloc) =>
              bloc.add(SpotifyPlayerStateChanged(playerState: playerState1)),
          expect: () {
            return [bloc.state.copyWith(playerState: playerState1)];
          });

      blocTest<MainPageBloc, MainPageState>(
          "SpotifyPlayerStateChanged ->  Same track in current player state and event player state",
          setUp: () => bloc.state.playerState = playerState1,
          build: () => bloc,
          act: (bloc) =>
              bloc.add(SpotifyPlayerStateChanged(playerState: playerState1)),
          expect: () {
            return [
              bloc.state.copyWith(
                  playerState: playerState1, hasJustPerformedAction: false)
            ];
          });

      blocTest<MainPageBloc, MainPageState>(
          "SpotifyPlayerStateChanged ->  Current track is equal to the one in the event player state",
          setUp: () {
            bloc.state.playerState = playerState2;
            bloc.state.currentTrack = QuackTrack(id: "1");
          },
          build: () => bloc,
          act: (bloc) =>
              bloc.add(SpotifyPlayerStateChanged(playerState: playerState1)),
          expect: () {
            return [
              bloc.state.copyWith(
                  playerState: playerState1, hasJustPerformedAction: false)
            ];
          });

      blocTest<MainPageBloc, MainPageState>(
          "SpotifyPlayerStateChanged ->  Playlist is null",
          setUp: () {
            bloc.state.playerState = playerState2;
            bloc.state.currentTrack = QuackTrack(id: "1");
          },
          build: () => bloc,
          act: (bloc) =>
              bloc.add(SpotifyPlayerStateChanged(playerState: playerState2)),
          expect: () {
            return [bloc.state.copyWith(playerState: playerState2)];
          });

      blocTest<MainPageBloc, MainPageState>(
          "SpotifyPlayerStateChanged -> Track is null in the current player state",
          setUp: () async {
            bloc.state.playerState = playerState3;
          },
          build: () => bloc,
          act: (bloc) =>
              bloc.add(SpotifyPlayerStateChanged(playerState: playerState2)),
          expect: () {
            return [bloc.state.copyWith(playerState: playerState2)];
          });

      blocTest<MainPageBloc, MainPageState>(
          "SpotifyPlayerStateChanged -> Playlist is not null",
          setUp: () async {
            bloc.state.playlist = QuackPlaylist(id: "1", tracks: [
              QuackTrack(id: "1"),
              QuackTrack(id: "2"),
              QuackTrack(id: "3")
            ]);
            bloc.state.playerState = playerState1;
          },
          build: () => bloc,
          act: (bloc) =>
              bloc.add(SpotifyPlayerStateChanged(playerState: playerState2)),
          expect: () {
            return [bloc.state.copyWith(playerState: playerState2)];
          });

      blocTest<MainPageBloc, MainPageState>(
          "SpotifyPlayerStateChanged -> Playlist is not null and current track is not null",
          setUp: () async {
            bloc.state.playlist = QuackPlaylist(id: "1", tracks: [
              QuackTrack(id: "1"),
              QuackTrack(id: "2"),
              QuackTrack(id: "3")
            ]);
            bloc.state.currentTrack = QuackTrack(id: "1");
            bloc.state.playerState = playerState1;
          },
          build: () => bloc,
          act: (bloc) =>
              bloc.add(SpotifyPlayerStateChanged(playerState: playerState2)),
          expect: () {
            var newState = bloc.state.copyWith(
                currentTrack: QuackTrack(id: "1"),
                hasJustPerformedAction: true);

            return [
              newState,
              newState.copyWith(currentTrack: QuackTrack(id: "2"))
            ];
          });

      blocTest<MainPageBloc, MainPageState>(
          "SpotifyPlayerStateChanged -> Playlist is not null and current track is not null "
          "-> The next track is the last one in the playlist",
          setUp: () async {
            playlistFromQuackService = (await QuackService.getInstance()
                    .getPlaylist(
                        qlt: QuackLocationType.nightLife, playlists: []))
                .quackResponse!
                .result;

            bloc.state.quackLocationType = QuackLocationType.nightLife;
            bloc.state.playlist = QuackPlaylist(
                id: "1", tracks: [QuackTrack(id: "1"), QuackTrack(id: "2")]);
            bloc.state.currentTrack = QuackTrack(id: "1");
            bloc.state.playerState = playerState1;
          },
          build: () => bloc,
          act: (bloc) =>
              bloc.add(SpotifyPlayerStateChanged(playerState: playerState2)),
          expect: () {
            var expandedPlaylist = QuackPlaylist(
                id: "1", tracks: [QuackTrack(id: "1"), QuackTrack(id: "2")]);
            expandedPlaylist.tracks!.addAll(playlistFromQuackService!.tracks!);

            var newState = bloc.state.copyWith(
                playlist: QuackPlaylist(
                    id: "1",
                    tracks: [QuackTrack(id: "1"), QuackTrack(id: "2")]),
                currentTrack: QuackTrack(id: "1"),
                hasJustPerformedAction: true,
                isLoading: false);
            newState.updatedItemHashCode = null;

            return [
              newState,
              newState.copyWith(currentTrack: QuackTrack(id: "2")),
              newState.copyWith(
                  currentTrack: QuackTrack(id: "2"), isLoading: true),
              newState.copyWith(
                  currentTrack: QuackTrack(id: "2"),
                  isLoading: true,
                  updatedItemHashCode: expandedPlaylist.hashCode,
                  playlist: expandedPlaylist),
              newState.copyWith(
                  currentTrack: QuackTrack(id: "2"),
                  isLoading: false,
                  updatedItemHashCode: expandedPlaylist.hashCode,
                  playlist: expandedPlaylist),
            ];
          });

      blocTest<MainPageBloc, MainPageState>(
          "SpotifyPlayerStateChanged -> Playlist is not null and current track is not null -> Current track is not in the playlist",
          setUp: () async {
            bloc.state.playlist = QuackPlaylist(id: "1", tracks: [
              QuackTrack(id: "1"),
              QuackTrack(id: "2"),
            ]);
            bloc.state.currentTrack = QuackTrack(id: "3");
            bloc.state.playerState = playerState1;
          },
          build: () => bloc,
          act: (bloc) =>
              bloc.add(SpotifyPlayerStateChanged(playerState: playerState2)),
          expect: () {
            return [
              bloc.state.copyWith(
                  hasJustPerformedAction: true,
                  currentTrack: QuackTrack(id: "3")),
              bloc.state.copyWith(
                  hasJustPerformedAction: true,
                  currentTrack: QuackTrack(id: "1"))
            ];
          });
    });

    group("QuackService -> Return error", () {
      setUp(() {
        QuackService.init(MockQuackServiceError());
        bloc = MainPageBloc(
            context: MockBuildContext(), positionHelper: MockPositionHelper());
      });

      blocTestWidget<MainPage, MainPageBloc, MainPageState>(
          "ButtonPressed -> Append to playlist",
          buildWidget: () => MainPage(),
          build: (w) async {
            w.bloc.state.playlist = QuackPlaylist(id: "1");
            w.bloc.state.quackLocationType = QuackLocationType.beach;
            return w.bloc;
          },
          act: (bloc) => bloc.add(const ButtonPressed(
              buttonEvent: MainButtonEvent.appendToPlaylist)),
          expect: (bloc) {
            return [
              bloc.state.copyWith(isLoading: true),
              bloc.state.copyWith(isLoading: false)
            ];
          });

      blocTestWidget<MainPage, MainPageBloc, MainPageState>(
          "ButtonPressed -> Start/Stop recommendation -> Check error states",
          buildWidget: () => MainPage(),
          build: (w) {
            w.bloc.state.quackLocationType = QuackLocationType.nightLife;
            return w.bloc;
          },
          act: (bloc) => bloc.add(const ButtonPressed(
              buttonEvent: MainButtonEvent.startStopRecommendation)),
          expect: (bloc) {
            return [
              bloc.state.copyWith(isLoading: true),
              bloc.state.copyWith(isLoading: false)
            ];
          });

      blocTestWidget<MainPage, MainPageBloc, MainPageState>(
          "PositionReceived method -> Position is not null -> Playlist is not null "
          "and the current QuackLocationType does not match the one from "
          "QuackLocationService and LockedQuackLocationType is null",
          buildWidget: () => mainPage,
          setUp: () async {
            var service = MockQuackLocationService();
            service.locationType = QuackLocationType.urban;
            QuackLocationService.init(service);
          },
          build: (w) {
            w.bloc.state.playlist = QuackPlaylist(
                id: "1", tracks: [QuackTrack(id: "1"), QuackTrack(id: "2")]);
            w.bloc.state.quackLocationType = QuackLocationType.beach;
            w.bloc.state.lockedQuackLocationType = null;
            return w.bloc;
          },
          act: (bloc) => bloc.positionReceived(getMockPosition(0, 0)),
          expect: (bloc) {
            var newState =
                bloc.state.copyWith(quackLocationType: QuackLocationType.urban);

            return [
              newState,
              newState.copyWith(isLoading: true),
              newState.copyWith(isLoading: false)
            ];
          });
    });
  });
}

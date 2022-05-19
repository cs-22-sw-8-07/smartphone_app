import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/pages/history_playlist/history_playlist_page_bloc.dart';
import 'package:smartphone_app/pages/history_playlist/history_playlist_page_events_states.dart';
import 'package:smartphone_app/pages/history_playlist/history_playlist_page_ui.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';

import '../../../helpers/bloc_test_widget.dart';
import '../../../mocks/app_values_helper.dart';
import '../../../mocks/build_context.dart';
import '../../../mocks/spotify_service.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  QuackPlaylist testPlaylist =
      QuackPlaylist(id: "111", locationType: 5, tracks: const []);

  group("HistoryPage", () {
    late HistoryPlaylistPageBloc bloc;

    setUp(() {
      GoogleFonts.config.allowRuntimeFetching = false;
      AppValuesHelper.init(MockAppValuesHelper());
      bloc = HistoryPlaylistPageBloc(
          context: MockBuildContext(), playlist: testPlaylist);
    });

    test("Initial state is correct", () {
      expect(bloc.state, HistoryPlaylistPageState(playlist: testPlaylist));
    });

    blocTestWidget<HistoryPlaylistPage, HistoryPlaylistPageBloc,
            HistoryPlaylistPageState>("ButtonPressed -> Back",
        buildWidget: () => HistoryPlaylistPage(
              playlist: QuackPlaylist(id: "1", tracks: [
                MockSpotifyService.getMockTrack(id: "1").toQuackTrack(),
                MockSpotifyService.getMockTrack(id: "2").toQuackTrack()
              ]),
            ),
        build: (w) => w.bloc,
        act: (bloc) => bloc.add(
            const ButtonPressed(buttonEvent: HistoryPlaylistButtonEvent.back)),
        expect: (bloc) {
          return [];
        });
  });
}

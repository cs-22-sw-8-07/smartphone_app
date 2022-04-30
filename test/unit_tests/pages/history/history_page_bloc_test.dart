import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/pages/history/history_page_bloc.dart';
import 'package:smartphone_app/pages/history/history_page_events_states.dart';
import 'package:smartphone_app/pages/history/history_page_ui.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';

import '../../../helpers/bloc_test_widget.dart';
import '../../../mocks/app_values_helper.dart';
import '../../../mocks/build_context.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  group("HistoryPage", () {
    late HistoryPageBloc bloc;

    setUp(() {
      GoogleFonts.config.allowRuntimeFetching = false;
      AppValuesHelper.init(MockAppValuesHelper());
      bloc = HistoryPageBloc(context: MockBuildContext());
    });

    test("Initial state is correct", () {
      expect(
          bloc.state,
          HistoryPageState(
              playlists: AppValuesHelper.getInstance().getPlaylists()));
    });

    blocTest<HistoryPageBloc, HistoryPageState>(
        "ButtonPressed -> Open with Spotify",
        build: () => bloc,
        act: (bloc) => bloc.add(const ButtonPressed(
            buttonEvent: HistoryButtonEvent.openWithSpotify)),
        expect: () => []);

    blocTestWidget<HistoryPage, HistoryPageBloc, HistoryPageState>(
        "ButtonPressed -> Back",
        buildWidget: () => HistoryPage(),
        build: (w) => w.bloc,
        act: (bloc) =>
            bloc.add(const ButtonPressed(buttonEvent: HistoryButtonEvent.back)),
        expect: (bloc) {
          return [];
        });

    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    blocTestWidget<HistoryPage, HistoryPageBloc, HistoryPageState>(
        "PlaylistSelected",
        buildWidget: () => HistoryPage(),
        build: (w) {
          w.bloc.state.playlists = [
            QuackPlaylist(
                id: "2",
                saveDate: dateFormat.parse("2022-01-01 10:00:00"),
                tracks: const [])
          ];
          return w.bloc;
        },
        act: (bloc) {
          bloc.add(PlaylistSelected(
              playlist: QuackPlaylist(
                  id: "2",
                  saveDate: dateFormat.parse("2022-01-01 10:00:00"),
                  tracks: const [])));
        },
        expect: (bloc) {
          return [];
        });
  });
}

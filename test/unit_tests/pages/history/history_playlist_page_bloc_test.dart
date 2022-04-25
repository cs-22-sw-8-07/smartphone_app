import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/pages/history/history_playlist/history_playlist_page_bloc.dart';
import 'package:smartphone_app/pages/history/history_playlist/history_playlist_page_events_states.dart';
import 'package:smartphone_app/services/webservices/quack/models/quack_classes.dart';

import '../../../mocks/app_values_helper.dart';
import '../../../mocks/build_context.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  QuackPlaylist testPlaylist =
      QuackPlaylist(id: "111", locationType: 5, tracks: const []);

  group("HistoryPage", () {
    late HistoryPlaylistBloc bloc;

    setUp(() {
      AppValuesHelper.init(MockAppValuesHelper());
      bloc = HistoryPlaylistBloc(
          context: MockBuildContext(), playlist: testPlaylist);
    });

    test("Initial state is correct", () {
      expect(bloc.state, HistoryPlaylistState(playlist: testPlaylist));
    });
  });
}

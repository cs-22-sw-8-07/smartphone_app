import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/pages/history/history_page_bloc.dart';
import 'package:smartphone_app/pages/history/history_page_events_states.dart';

import '../../../mocks/app_values_helper.dart';
import '../../../mocks/build_context.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  group("HistoryPage", () {
    late HistoryPageBloc bloc;

    setUp(() {
      AppValuesHelper.init(MockAppValuesHelper());
      bloc = HistoryPageBloc(context: MockBuildContext());
    });

    test("Initial state is correct", () {
      expect(
          bloc.state,
          HistoryPageState(
              playlists: AppValuesHelper.getInstance().getPlaylists()));
    });

    blocTest<HistoryPageBloc, HistoryPageState>("ButtonPressed -> Open with Spotifiy",
        build: () => bloc,
        act: (bloc) => bloc.add(const ButtonPressed(
            buttonEvent: HistoryButtonEvent.openWithSpotify)),
        expect: () => []);
  });
}

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:smartphone_app/pages/settings/settings_page_bloc.dart';
import 'package:smartphone_app/pages/settings/settings_page_events_states.dart';
import 'package:smartphone_app/pages/settings/settings_page_ui.dart';
import 'package:smartphone_app/widgets/question_dialog.dart';

import '../../../mocks/build_context.dart';
import '../../../mocks/question_dialog.dart';
import '../../../helpers/bloc_test_widget.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  group("Settings Page", () {
    late SettingsBloc bloc;

    setUp(() async {
      GoogleFonts.config.allowRuntimeFetching = false;
      bloc = SettingsBloc(context: MockBuildContext());
    });

    test("Initial state is correct", () async {
      expect(bloc.state, const SettingsState());
    });

    blocTestWidget<SettingsPage, SettingsBloc, SettingsState>(
      "ButtonPressed -> Delete account -> Picked yes",
        setUp: () {
          QuestionDialog.setInstance(MockQuestionDialogYes());
        },
        buildWidget: () => SettingsPage(),
        build: (w) => w.bloc,
        act: (bloc) => bloc.add(
            const ButtonPressed(
                buttonEvent: SettingsButtonEvent.deleteAccount)),
        expect: (bloc) => []);

    blocTestWidget<SettingsPage, SettingsBloc, SettingsState>(
        "ButtonPressed -> Delete account -> Picked no",
        setUp: () {
          QuestionDialog.setInstance(MockQuestionDialogNo());
        },
        buildWidget: () => SettingsPage(),
        build: (w) => w.bloc,
        act: (bloc) => bloc.add(
            const ButtonPressed(
                buttonEvent: SettingsButtonEvent.deleteAccount)),
        expect: (bloc) => []);
  });
}

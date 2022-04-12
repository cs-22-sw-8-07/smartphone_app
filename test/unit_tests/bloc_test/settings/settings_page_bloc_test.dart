import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/pages/main/main_page_ui.dart';

import 'package:smartphone_app/pages/settings/settings_page_bloc.dart';
import 'package:smartphone_app/pages/settings/settings_page_events_states.dart';
import 'package:smartphone_app/pages/settings/settings_page_ui.dart';
import 'package:smartphone_app/widgets/question_dialog.dart';

import '../../../mocks/build_context.dart';
import '../../../mocks/question_dialog.dart';
import '../../../tests/widget_bloc_test.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  group("Settings Page", () {
    late SettingsBloc bloc;

    setUp(() async {
      GoogleFonts.config.allowRuntimeFetching = false;
      QuestionDialog.setInstance(MockQuestionDialog());
      bloc = SettingsBloc(context: MockBuildContext());
    });

    test("Initial state is correct", () async {
      expect(bloc.state, SettingsState());
    });

    test("Initial state is correct", () async {

    });

    blocTestWidget<SettingsPage, SettingsBloc, SettingsState>(
      "ButtonPressed -> Delete account",
        buildWidget: () => SettingsPage(),
        build: (w) => w.bloc,
        act: (bloc) => bloc.add(
            const ButtonPressed(
                buttonEvent: SettingsButtonEvent.deleteAccount)),
        expect: (bloc) => []);
  });
}

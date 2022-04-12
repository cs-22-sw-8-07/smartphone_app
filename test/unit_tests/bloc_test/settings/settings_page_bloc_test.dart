import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smartphone_app/pages/settings/settings_page_bloc.dart';
import 'package:smartphone_app/pages/settings/settings_page_events_states.dart';
import 'package:smartphone_app/widgets/question_dialog.dart';

import '../../../mocks/build_context.dart';
import '../../../mocks/question_dialog.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  group("Settings Page", () {
    late SettingsBloc bloc;
    
    setUp(() {
      QuestionDialog.setInstance(MockQuestionDialog());
      bloc = SettingsBloc(context: MockBuildContext());
    });

    test("Initial state is correct", () async {
      expect(bloc.state, const SettingsState());
    });

    blocTest<SettingsBloc, SettingsState>("ButtonPressed -> Delete Account",
        build: () => bloc,
        act: (bloc) => bloc.add(const ButtonPressed(
            buttonEvent: SettingsButtonEvent.deleteAccount)),
        expect: () => []);
  });
}

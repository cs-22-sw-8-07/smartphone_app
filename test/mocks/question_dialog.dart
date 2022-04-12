import 'package:flutter/widgets.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smartphone_app/widgets/question_dialog.dart';

import 'package:flutter_test/flutter_test.dart';



abstract class MockWithExpandedToString extends Mock {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.debug}) {
    super.toString();
    return "";
  }
}

//todo: lav en der også retunerer no
class MockQuestionDialog extends MockWithExpandedToString
    implements QuestionDialog {
  @override
  Future<DialogQuestionResponse> show(
      {required BuildContext context,
      required String question,
      Color? textColor}) async {
    return DialogQuestionResponse.yes;
  }
}

/*

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  group("MainPage", () {
    late MainPageBloc bloc;

    setUp(() {
      QuestionDialog.setInstance(MockQuestionDialog());
      QuackService.init(MockQuackService());
      SpotifyService.init(MockSpotifyService());
      bloc = MainPageBloc(
          context: MockBuildContext(), positionHelper: MockPositionHelper());
    });

    // blocTest<MainPageBloc, MainPageState>("ButtonPressed -> QuestionDialog",
    //     build: () {
    //       bloc.state
    //           .copyWith(playerState: MockSpotifyService.getMockPlayerState());
    //       return bloc;
    //     },
    //     act: (bloc) => bloc.add(
    //         const ButtonPressed(buttonEvent: MainButtonEvent.refreshPlaylist)),
    //     expect: () => []);
  });
}

*/
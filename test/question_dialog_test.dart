import 'package:flutter/widgets.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smartphone_app/widgets/question_dialog.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

abstract class MockWithExpandedToString extends Mock {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.debug}) {
    super.toString();
    return "";
  }
}

class MockQuestionDialog extends MockWithExpandedToString implements QuestionDialog {}


void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  setUp(() async {});

  final mockQD = MockQuestionDialog();

  test("testname", () async {
    when(() => QuestionDialog.getInstance()).thenAnswer((invocation) => QuestionDialog.getInstance() );
  });
}

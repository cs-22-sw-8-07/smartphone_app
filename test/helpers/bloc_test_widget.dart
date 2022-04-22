import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:test/test.dart' as test;
import 'package:diff_match_patch/diff_match_patch.dart';
import 'package:meta/meta.dart';

/// Makes a [child] widget testable:
/// - Adds localization functionality
Widget makeTestableWidget({required Widget child}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('en', ''),
    ],
    home: child,
  );
}

/// Method to check difference between [expected] and [actual]
String _diff({required dynamic expected, required dynamic actual}) {
  final buffer = StringBuffer();
  final differences = diff(expected.toString(), actual.toString());
  buffer
    ..writeln('${"=" * 4} diff ${"=" * 40}')
    ..writeln('')
    ..writeln(differences.toPrettyString())
    ..writeln('')
    ..writeln('${"=" * 4} end diff ${"=" * 36}');
  return buffer.toString();
}

/// Test used widgets are used within a Bloc
///
/// Supply a [description] for the test
///
/// ```dart
/// blocTestWidget<MainPage, MainPageBloc, MainPageState>(
///   'ButtonPressed -> View playlist',
///   buildWidget: () => MainPage(),
///   act: (bloc) => bloc.add(ButtonPressed(buttonEvent: MainButtonEvent.viewPlaylist)),
///   expect: (bloc) => [bloc.state.copyWith(isPlaylistShown: true)],
/// );
/// ```
@isTest
Future<void> blocTestWidget<W extends Widget, B extends BlocBase<State>, State>(
    String description,
    {required W Function() buildWidget,
    required FutureOr<B> Function(W) build,
    required Function(B) act,
    required FutureOr<List<State>> Function(B) expect,
    FutureOr<void> Function()? setUp}) async {
  // Create test
  testWidgets(description, (WidgetTester tester) async {
    if (setUp != null) {
      await setUp();
    }
    var shallowEquality = false;
    final states = <State>[];
    // Build widget
    W widget = buildWidget();
    // Add localization functionality
    final testableWidget = makeTestableWidget(
      child: widget,
    );
    // Mock network images
    await mockNetworkImagesFor(() async {
      // Pump page
      await tester.pumpWidget(testableWidget);
      // Build bloc
      final bloc = await build(widget);
      // Listen on state changes for the bloc
      bloc.stream.listen(
        (event) => states.add(event),
      );
      // Make an action for the bloc
      act(bloc);
      // Wait for UI
      await tester.pump(const Duration(milliseconds: 300));
      // Get expected state changes
      final dynamic expected = await expect(bloc);
      // Check for shadow equality
      shallowEquality = '$states' == '$expected';
      try {
        // Test between expected and actual states
        test.expect(states, test.wrapMatcher(expected));
      } on test.TestFailure catch (e) {
        if (shallowEquality || expected is! List<State>) rethrow;
        final diff = _diff(expected: expected, actual: states);
        final message = '${e.message}\n$diff';
        // ignore: only_throw_errors
        throw test.TestFailure(message);
      }
    });
  }, timeout: const Timeout(Duration(minutes: 1)));
}

extension on List<Diff> {
  String toPrettyString() {
    String identical(String str) => '\u001b[90m$str\u001B[0m';
    String deletion(String str) => '\u001b[31m[-$str-]\u001B[0m';
    String insertion(String str) => '\u001b[32m{+$str+}\u001B[0m';

    final buffer = StringBuffer();
    for (final difference in this) {
      switch (difference.operation) {
        case DIFF_EQUAL:
          buffer.write(identical(difference.text));
          break;
        case DIFF_DELETE:
          buffer.write(deletion(difference.text));
          break;
        case DIFF_INSERT:
          buffer.write(insertion(difference.text));
          break;
      }
    }
    return buffer.toString();
  }
}

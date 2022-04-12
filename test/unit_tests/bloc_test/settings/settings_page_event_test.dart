import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/pages/settings/settings_page_events_states.dart';

void main() {
  group("SettingsPageEvent", () {
    group("ButtonPressed", () {
      test("Events are equal", () {
        expect(
          const ButtonPressed(buttonEvent: SettingsButtonEvent.deleteAccount),
          const ButtonPressed(buttonEvent: SettingsButtonEvent.deleteAccount),
        );
      });
      test("Events are not equal", () {
        expect(
          const ButtonPressed(buttonEvent: SettingsButtonEvent.save),
          isNot(const ButtonPressed(buttonEvent: SettingsButtonEvent.back)),
        );
      });
    });
  });
}

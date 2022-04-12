import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/pages/settings/settings_page_events_states.dart';

void main() {
  group("SettingsPageState", () {
    test("States are equal", () {
      expect(const SettingsState().copyWith(), const SettingsState());
    });
  });
}

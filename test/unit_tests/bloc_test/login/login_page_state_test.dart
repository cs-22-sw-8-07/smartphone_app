import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/pages/login/login_page_events_states.dart';
import 'package:smartphone_app/utilities/general_util.dart';

void main() {
  group("LoginPageState", () {
    test("States are equal", () {
      expect(
          LoginPageState().copyWith(permissionState: PermissionState.granted),
          LoginPageState(permissionState: PermissionState.granted));
    });
    test("States are not equal -> permissionState", () {
      expect(LoginPageState().copyWith(permissionState: PermissionState.denied),
          isNot(LoginPageState(permissionState: PermissionState.granted)));
    });
  });
}

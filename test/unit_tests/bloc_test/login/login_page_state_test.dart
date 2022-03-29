import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/pages/login/login_page_events_states.dart';
import 'package:smartphone_app/utilities/general_util.dart';

void main() {
  group("LoginPageState", () {
    test("Supports value comparisons", () {
      var state = LoginPageState();
      state = state.copyWith(permissionState: PermissionState.granted);
      expect(state, LoginPageState(permissionState: PermissionState.granted));
    });
  });
}

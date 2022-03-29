import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/pages/login/login_page_events_states.dart';
import 'package:smartphone_app/utilities/general_util.dart';

void main() {
  group("LoginPageEvent", () {
    group("ButtonPressed", () {
      test("Supports value comparisons", () {
        expect(
          const ButtonPressed(
              buttonEvent: LoginButtonEvent.continueWithSpotify),
          const ButtonPressed(
              buttonEvent: LoginButtonEvent.continueWithSpotify),
        );
      });
    });

    group("Resumed", () {
      test("Supports value comparisons", () {
        expect(
          const Resumed(),
          const Resumed(),
        );
      });
    });

    group("PermissionStateChanged", () {
      test("Supports value comparisons", () {
        expect(
          const PermissionStateChanged(permissionState: PermissionState.denied),
          const PermissionStateChanged(permissionState: PermissionState.denied),
        );
      });
    });
  });
}

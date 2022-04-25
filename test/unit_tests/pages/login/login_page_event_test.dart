import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/pages/login/login_page_events_states.dart';
import 'package:smartphone_app/utilities/general_util.dart';

void main() {
  group("LoginPageEvent", () {
    group("ButtonPressed", () {
      test("Events are equal", () {
        expect(
          const ButtonPressed(
              buttonEvent: LoginButtonEvent.continueWithSpotify),
          const ButtonPressed(
              buttonEvent: LoginButtonEvent.continueWithSpotify),
        );
      });
      test("Events are not equal", () {
        expect(
          const ButtonPressed(
              buttonEvent: LoginButtonEvent.continueWithSpotify),
          isNot(
              const ButtonPressed(buttonEvent: LoginButtonEvent.goToSettings)),
        );
      });
    });

    group("Resumed", () {
      test("Events are equal", () {
        expect(
          const Resumed(),
          const Resumed(),
        );
      });
      test("Events are not equal", () {
        expect(
          const Resumed(),
          isNot(const ButtonPressed(
              buttonEvent: LoginButtonEvent.continueWithSpotify)),
        );
      });
    });

    group("PermissionStateChanged", () {
      test("Events are equal", () {
        expect(
          const PermissionStateChanged(permissionState: PermissionState.denied),
          const PermissionStateChanged(permissionState: PermissionState.denied),
        );
      });
      test("Events are not equal", () {
        expect(
          const PermissionStateChanged(permissionState: PermissionState.denied),
          isNot(const PermissionStateChanged(
              permissionState: PermissionState.granted)),
        );
      });
    });
  });
}

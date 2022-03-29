import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/helpers/permission_helper.dart';
import 'package:smartphone_app/pages/login/login_page_bloc.dart';
import 'package:smartphone_app/pages/login/login_page_events_states.dart';
import 'package:smartphone_app/services/webservices/spotify/services/spotify_mock_service.dart';
import 'package:smartphone_app/services/webservices/spotify/services/spotify_service.dart';
import 'package:smartphone_app/utilities/general_util.dart';

class MockBuildContext extends Mock implements BuildContext {}

class MockGrantedPermissionHelper extends Mock implements PermissionHelper {
  @override
  Future<PermissionStatus> getStatus(Permission permission) async {
    return PermissionStatus.granted;
  }
}

class MockDeniedPermissionHelper extends Mock implements PermissionHelper {
  @override
  Future<PermissionStatus> getStatus(Permission permission) async {
    return PermissionStatus.denied;
  }
}

class MockAppValuesHelper extends Mock implements AppValuesHelper {
  @override
  Future<bool> saveString(AppValuesKey appValuesKey, String? value) async {
    return true;
  }
}

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  group("LoginPage", () {
    late LoginPageBloc bloc;

    setUp(() {
      AppValuesHelper.init(MockAppValuesHelper());
      SpotifyService.init(MockSpotifyService());
      bloc = LoginPageBloc(
          context: MockBuildContext(),
          permissionHelper: MockGrantedPermissionHelper());
    });

    test("Initial state is correct", () {
      expect(
          bloc.state, LoginPageState(permissionState: PermissionState.denied));
    });

    blocTest<LoginPageBloc, LoginPageState>(
        "ButtonPressed -> Continue with Spotify",
        build: () => bloc,
        act: (bloc) => bloc.add(const ButtonPressed(
            buttonEvent: LoginButtonEvent.continueWithSpotify)),
        expect: () => []);

    blocTest<LoginPageBloc, LoginPageState>("Resumed -> Permissions granted",
        build: () => bloc,
        act: (bloc) => bloc.add(const Resumed()),
        expect: () =>
            [bloc.state.copyWith(permissionState: PermissionState.granted)]);

    blocTest<LoginPageBloc, LoginPageState>("Resumed -> Permissions denied",
        setUp: () {
          bloc = LoginPageBloc(
              context: MockBuildContext(),
              permissionHelper: MockDeniedPermissionHelper());
        },
        build: () => bloc,
        act: (bloc) => bloc.add(const Resumed()),
        expect: () =>
            [bloc.state.copyWith(permissionState: PermissionState.denied)]);

    blocTest<LoginPageBloc, LoginPageState>(
        "PermissionsStateChanged -> Permissions granted",
        build: () => bloc,
        act: (bloc) => bloc.add(const PermissionStateChanged(
            permissionState: PermissionState.granted)),
        expect: () =>
            [bloc.state.copyWith(permissionState: PermissionState.granted)]);
  });
}
